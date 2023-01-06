//
//  LabelCore
//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/widgets.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
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

// TO USE A PAYMENT GATEWAY, FIRST OPEN /config/payment_gateways.dart.
// THEN ADD A NEW PAYMENT LIKE IN THE BELOW EXAMPLE
//
// addPayment(
//     id: 6,
//     name: "My Payment",
//     description: trans("Debit or Credit Card"),
//     assetImage: "payment_logo.png",  E.g. /public/assets/images/payment_logo.png
//     pay: examplePay,
//   ),

examplePay(context,
    {required CheckoutConfirmationPageState state, TaxRate? taxRate}) async {
  // HANDLE YOUR PAYMENT INTEGRATION HERE
  // ...
  // ...
  // ...
  // THEN ON SUCCESS OF A PAYMENT YOU CAN DO SOMETHING SIMILAR BELOW

  // CREATES ORDER MODEL
  OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);

  // CREATES ORDER IN WOOCOMMERCE
  Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

  // CHECK IF ORDER IS NULL
  if (order != null) {
    Navigator.pushNamed(context, "/checkout-status", arguments: order);
  } else {
    showToastNotification(
      context,
      title: trans("Error"),
      description: trans("Something went wrong, please contact our store"),
    );
    state.reloadState(showLoader: false);
  }
}
