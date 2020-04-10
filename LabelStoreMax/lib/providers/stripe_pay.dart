//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/data/order_wc.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/pages/checkout_confirmation.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal_stripe/woosignal_stripe.dart';

stripePay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  // CONFIGURE STRIPE
  FlutterStripePayment.setStripeSettings(
      stripeAccount: app_stripe_account, liveMode: app_stripe_live_mode);

  var paymentResponse = await FlutterStripePayment.addPaymentMethod();

  // CHECK STATUS FROM STRIPE
  if (paymentResponse.status == PaymentResponseStatus.succeeded) {
    state.reloadState(showLoader: true);

    // CHECKOUT HELPER
    await checkout(taxRate, (total, billingDetails, cart) async {
      Map<String, dynamic> address = {
        "name": billingDetails.billingAddress.nameFull(),
        "line1": billingDetails.shippingAddress.addressLine,
        "city": billingDetails.shippingAddress.city,
        "postal_code": billingDetails.shippingAddress.postalCode,
        "country": billingDetails.shippingAddress.country
      };

      String cartShortDesc = await cart.cartShortDesc();

      dynamic rsp = await appWooSignal((api) {
        return api.stripePaymentIntent(
          amount: total,
          email: billingDetails.billingAddress.emailAddress,
          desc: cartShortDesc,
          shipping: address,
        );
      });

      if (rsp == null) {
        showEdgeAlertWith(context,
            title: "Oops!",
            desc: "Something went wrong, please try again.",
            icon: Icons.payment,
            style: EdgeAlertStyle.WARNING);
        state.reloadState(showLoader: false);
        return;
      }

      String clientSecret = rsp["client_secret"];
      var intentResponse = await FlutterStripePayment.confirmPaymentIntent(
        clientSecret,
        paymentResponse.paymentMethodId,
        (double.parse(total) * 100),
      );

      if (intentResponse.status == PaymentResponseStatus.succeeded) {
        OrderWC orderWC = await buildOrderWC(taxRate: taxRate);
        Order order = await appWooSignal((api) {
          return api.createOrder(orderWC);
        });

        if (order != null) {
          Cart.getInstance.clear();
          Navigator.pushNamed(context, "/checkout-status", arguments: order);
        } else {
          showEdgeAlertWith(
            context,
            title: trans(context, "Error"),
            desc: trans(
                context, "Something went wrong, please contact our store"),
          );
          state.reloadState(showLoader: false);
        }
      } else if (intentResponse.status == PaymentResponseStatus.failed) {
        if (app_debug) {
          print(intentResponse.errorMessage);
        }
        showEdgeAlertWith(
          context,
          title: trans(context, "Error"),
          desc: intentResponse.errorMessage,
        );
        state.reloadState(showLoader: false);
      } else {
        state.reloadState(showLoader: false);
      }
    });
  }
}
