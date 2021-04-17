//
//  LabelCore
//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal_stripe/woosignal_stripe.dart';

stripePay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  try {
    WooSignalApp wooSignalApp = AppHelper.instance.appConfig;
    bool liveMode = getEnv('STRIPE_LIVE_MODE') == null
        ? wooSignalApp.stripeLiveMode
        : getEnv('STRIPE_LIVE_MODE', defaultValue: false);

    // CONFIGURE STRIPE
    FlutterStripePayment.setStripeSettings(
        stripeAccount: getEnv('STRIPE_ACCOUNT'), liveMode: liveMode);

    PaymentResponse paymentResponse =
        await FlutterStripePayment.addPaymentMethod();

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
          "country":
              (billingDetails.shippingAddress?.customerCountry?.name ?? "")
        };

        String cartShortDesc = await cart.cartShortDesc();

        dynamic rsp = await appWooSignal((api) => api.stripePaymentIntent(
              amount: total,
              email: billingDetails.billingAddress.emailAddress,
              desc: cartShortDesc,
              shipping: address,
            ));

        if (rsp == null) {
          showToastNotification(context,
              title: trans(context, "Oops!"),
              description:
                  trans(context, "Something went wrong, please try again."),
              icon: Icons.payment,
              style: ToastNotificationStyleType.WARNING);
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
          Order order = await appWooSignal((api) => api.createOrder(orderWC));

          if (order != null) {
            Navigator.pushNamed(context, "/checkout-status", arguments: order);
          } else {
            showToastNotification(
              context,
              title: trans(context, "Error"),
              description: trans(context,
                  "Something went wrong, please contact our store"),
            );
            state.reloadState(showLoader: false);
          }
        } else if (intentResponse.status == PaymentResponseStatus.failed) {
          if (getEnv('APP_DEBUG', defaultValue: true)) {
            NyLogger.error(intentResponse.errorMessage);
          }
          showToastNotification(
            context,
            title: trans(context, "Error"),
            description: intentResponse.errorMessage,
          );
          state.reloadState(showLoader: false);
        } else {
          state.reloadState(showLoader: false);
        }
      });
    } else {
      state.reloadState(showLoader: false);
    }
  } catch (ex) {
    showToastNotification(
      context,
      title: trans(context, "Oops!"),
      description: trans(context, "Something went wrong, please try again."),
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    state.reloadState(showLoader: false);
  }
}
