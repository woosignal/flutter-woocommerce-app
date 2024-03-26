//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import '/resources/pages/checkout_status_page.dart';
import '/app/models/cart.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';

razorPay(context, {TaxRate? taxRate}) async {
  Razorpay razorpay = Razorpay();

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);

    Order? order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      showToastNotification(
        context,
        title: "Error".tr(),
        description: trans("Something went wrong, please contact our store"),
      );
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      return;
    }
    Cart.getInstance.clear();
    routeTo(CheckoutStatusPage.path, data: order);
  });

  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    showToastNotification(context,
        title: trans("Error"),
        description: response.message ?? "",
        style: ToastNotificationStyleType.WARNING);
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
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

    updateState(CheckoutConfirmationPage.path, data: {"reloadState": true});

    razorpay.open(options);
  });
}

void _handleExternalWallet(ExternalWalletResponse response) {}
