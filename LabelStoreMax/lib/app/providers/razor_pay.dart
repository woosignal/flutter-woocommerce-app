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

import 'package:flutter/widgets.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';

razorPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  Razorpay razorPay = Razorpay();

  razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);

    Order order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      razorPay.clear();
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showEdgeAlertWith(context,
          title: trans(context, "Error"),
          desc: trans(
            context,
            trans(context, "Something went wrong, please contact our store"),
          ),
          style: EdgeAlertStyle.WARNING);
      razorPay.clear();
      state.reloadState(showLoader: false);
    }
  });

  razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    showEdgeAlertWith(context,
        title: trans(context, "Error"),
        desc: response.message,
        style: EdgeAlertStyle.WARNING);
    razorPay.clear();
    state.reloadState(showLoader: false);
  });

  razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {
    showEdgeAlertWith(context,
        title: trans(context, "Error"),
        desc: trans(context, "Not supported, try a card payment"),
        style: EdgeAlertStyle.WARNING);
    razorPay.clear();
    state.reloadState(showLoader: false);
  });

  // CHECKOUT HELPER
  await checkout(taxRate, (total, billingDetails, cart) async {
    var options = {
      'key': getEnv('RAZORPAY_ID'),
      'amount': (parseWcPrice(total) * 100).toInt(),
      'name': AppHelper.instance.appConfig.appName,
      'description': await cart.cartShortDesc(),
      'prefill': {
        "name": [
          billingDetails.billingAddress.firstName,
          billingDetails.billingAddress.lastName
        ].where((t) => t != null || t != "").toList().join(" "),
        "method": "card",
        'email': billingDetails.billingAddress.emailAddress
      }
    };

    state.reloadState(showLoader: true);

    razorPay.open(options);
  });
}
