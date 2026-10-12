//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/checkout_status_page.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

// CALL THE BELOW ACTIONS TO SHOW AND HIDE THE CHECKOUT PAGE LOADER
// stateAction("payment_started", state: CheckoutConfirmationPage.path);
// stateAction("payment_finished", state: CheckoutConfirmationPage.path);

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
//     assetImage: "payment_logo.png",  E.g. /assets/images/payment_logo.png
//     pay: examplePay,
//   ),

Future<void> examplePay(BuildContext context, {TaxRate? taxRate}) async {
  // HANDLE YOUR PAYMENT INTEGRATION HERE
  // ...
  // ...
  // ...
  // THEN ON SUCCESS OF A PAYMENT YOU CAN DO SOMETHING SIMILAR BELOW

  // CREATES ORDER MODEL
  // PASS THE REFERENCE YOUR GATEWAY RETURNED AS `transactionId` SO THE
  // MERCHANT CAN MATCH THE ORDER BACK TO THE CHARGE
  // E.g. buildOrderWC(taxRate: taxRate, markPaid: true, transactionId: "ch_1")
  OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);

  // CREATES ORDER IN WOOCOMMERCE
  Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

  // CHECK IF ORDER IS NULL
  if (order == null) {
    // THE CHECKOUT PAGE MAY HAVE CLOSED WHILE THE ORDER WAS BEING CREATED
    if (context.mounted) {
      showToastNotification(
        context,
        title: trans("Error"),
        description: trans("Something went wrong, please contact our store"),
      );
    }
    stateAction("payment_finished", state: CheckoutConfirmationPage.path);
    return;
  }
  routeTo(CheckoutStatusPage.path, data: order);
}
