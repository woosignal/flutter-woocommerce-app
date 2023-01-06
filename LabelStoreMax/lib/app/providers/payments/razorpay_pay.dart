//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/widgets.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';

razorPay(context,
    {required CheckoutConfirmationPageState state, TaxRate? taxRate}) async {
  Razorpay razorpay = Razorpay();

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);

    Order? order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      Cart.getInstance.clear();
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showToastNotification(
        context,
        title: "Error".tr(),
        description: trans("Something went wrong, please contact our store"),
      );
      state.reloadState(showLoader: false);
    }
  });

  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    showToastNotification(context,
        title: trans("Error"),
        description: response.message ?? "",
        style: ToastNotificationStyleType.WARNING);
    state.reloadState(showLoader: false);
  });

  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  // CHECKOUT HELPER
  await checkout(taxRate, (total, billingDetails, cart) async {
    var options = {
      'key': getEnv('RAZORPAY_API_KEY'),
      'amount': (double.parse(total) * 100).toInt(),
      'name': getEnv('APP_NAME'),
      'description': await cart.cartShortDesc(),
      'prefill': {
        "name": [
          billingDetails!.billingAddress?.firstName,
          billingDetails.billingAddress?.lastName
        ].where((t) => t != null || t != "").toList().join(" "),
        "method": "card",
        'email': billingDetails.billingAddress?.emailAddress ?? ""
      }
    };

    state.reloadState(showLoader: true);

    razorpay.open(options);
  });
}

void _handleExternalWallet(ExternalWalletResponse response) {}
