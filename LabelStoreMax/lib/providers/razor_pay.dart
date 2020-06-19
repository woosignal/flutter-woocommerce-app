//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/widgets.dart';
import 'package:label_storemax/helpers/data/order_wc.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/pages/checkout_confirmation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';

razorPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  Razorpay _razorpay = Razorpay();

  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);

    Order order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      _razorpay.clear();
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showEdgeAlertWith(context,
          title: trans(context, "Error"),
          desc: trans(
            context,
            trans(context, "Something went wrong, please contact our store"),
          ),
          style: EdgeAlertStyle.WARNING);
      _razorpay.clear();
      state.reloadState(showLoader: false);
    }
  });

  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    showEdgeAlertWith(context,
        title: trans(context, "Error"),
        desc: response.message,
        style: EdgeAlertStyle.WARNING);
    _razorpay.clear();
    state.reloadState(showLoader: false);
  });

  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {
    showEdgeAlertWith(context,
        title: trans(context, "Error"),
        desc: trans(context, "Not supported, try a card payment"),
        style: EdgeAlertStyle.WARNING);
    _razorpay.clear();
    state.reloadState(showLoader: false);
  });

  // CHECKOUT HELPER
  await checkout(taxRate, (total, billingDetails, cart) async {
    var options = {
      'key': app_razor_id,
      'amount': (parseWcPrice(total) * 100).toInt(),
      'name': app_name,
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

    _razorpay.open(options);
  });
}
