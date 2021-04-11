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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:flutter_app/resources/widgets/checkout_paypal.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

payPalPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  await checkout(taxRate, (total, billingDetails, cart) async {
    List<CartLineItem> cartLineItems = await cart.getCart();
    String description = await cart.cartShortDesc();
    state.reloadState(showLoader: true);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PayPalCheckout(
                description: description,
                amount: total,
                cartLineItems: cartLineItems))).then((value) async {
      if (value is Map<String, dynamic>) {
        if (value.containsKey("status") && value["status"] == "success") {
          OrderWC orderWC =
              await buildOrderWC(taxRate: taxRate, markPaid: true);
          Order order = await appWooSignal((api) => api.createOrder(orderWC));

          if (order != null) {
            Navigator.pushNamed(context, "/checkout-status", arguments: order);
          } else {
            showToastNotification(
              context,
              title: trans(context, "Error"),
              description: trans(
                  context,
                  trans(context,
                      "Something went wrong, please contact our store")),
            );
            state.reloadState(showLoader: false);
          }
        } else {
          showToastNotification(
            context,
            title: trans(context, "Payment Cancelled"),
            description: trans(
                context, trans(context, "The payment has been cancelled")),
          );
          state.reloadState(showLoader: false);
        }
      } else {
        showToastNotification(
          context,
          title: trans(context, "Payment Cancelled"),
          description:
              trans(context, trans(context, "The payment has been cancelled")),
        );
        state.reloadState(showLoader: false);
      }
    });
  });
}
