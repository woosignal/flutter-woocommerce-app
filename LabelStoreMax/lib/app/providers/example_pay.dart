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
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

// CALL THE BELOW METHOD TO SHOW AND HIDE LOADER
// state.reloadState(showLoader: false);

// CHECKOUT HELPER
// IT WILL RETURN THE ORDER TOTAL, BILLING DETAILS AND CART
// await checkout(taxRate, (total, billingDetails, cart) async {
//
// });

// REMEMBER TO ADD THIS METHOD E.G. "examplePay" TO THE APP_PAYMENT_METHODS
// AS THE PAY METHOD

examplePay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  // HANDLE YOUR PAYMENT INTEGRATION HERE
  // ...
  // ...
  // ...
  // THEN ON SUCCESS OF A PAYMENT YOU CAN DO SOMETHING SIMILAR BELOW

  // CREATES ORDER MODEL
  OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);

  // CREATES ORDER IN WOOCOMMERCE
  Order order = await appWooSignal((api) => api.createOrder(orderWC));

  // CHECK IF ORDER IS NULL
  if (order != null) {
    Navigator.pushNamed(context, "/checkout-status", arguments: order);
  } else {
    showToastNotification(
      context,
      title: trans(context, "Error"),
      description: trans(context, "Something went wrong, please contact our store"),
    );
    state.reloadState(showLoader: false);
  }
}
