//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/paypal/paypal_checkout_view.dart';
import '/app/models/cart.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import '/bootstrap/data/order_wc.dart';
import '/resources/pages/checkout_status_page.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Digs the capture reference out of a PayPal execute payment response. The
/// sale id is the one PayPal shows against the transaction, so prefer it and
/// fall back to the payment id when the response isn't shaped as expected.
///
/// It is sent as the order's `transaction_id`: WooSignal looks the sale up
/// with PayPal before it marks the order as paid.
@visibleForTesting
String? payPalTransactionId(Map params) {
  dynamic data = params['data'];
  if (data is! Map) {
    return null;
  }

  dynamic transactions = data['transactions'];
  if (transactions is List) {
    for (Object? transaction in transactions) {
      if (transaction is! Map) {
        continue;
      }
      dynamic relatedResources = transaction['related_resources'];
      if (relatedResources is! List) {
        continue;
      }
      for (Object? relatedResource in relatedResources) {
        if (relatedResource is! Map) {
          continue;
        }
        dynamic sale = relatedResource['sale'];
        if (sale is Map && sale['id'] != null) {
          return sale['id'].toString();
        }
      }
    }
  }

  return data['id']?.toString();
}

Future<void> payPalPay(BuildContext context, {TaxRate? taxRate}) async {
  await checkout(taxRate, (total, billingDetails, cart) async {
    WooSignalApp? wooSignalApp = AppHelper.instance.appConfig;

    List<CartLineItem> cartLineItems = await cart.getCart();
    String taxTotal = await cart.taxAmount(taxRate);
    String subtotal = await Cart.getInstance.getSubtotal();

    String? currencyCode = wooSignalApp?.currencyMeta?.code;

    String shippingTotal =
        CheckoutSession.getInstance.shippingType?.getTotal() ?? "0";
    String description = "({{itemCount}}) items from {{appName}}".tr(
        arguments: {
          "itemCount": cartLineItems.length.toString(),
          "appName": getEnv('APP_NAME')
        });

    if (taxTotal == "") {
      taxTotal = "0";
    }

    if (shippingTotal == "") {
      shippingTotal = "0";
    }

    // Nothing has been charged yet, so if the checkout page closed while the
    // totals were being worked out, stop before opening PayPal.
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: getEnv('PAYPAL_LIVE_MODE') != true,
          clientId: getEnv('PAYPAL_CLIENT_ID'),
          secretKey: getEnv('PAYPAL_SECRET_KEY'),
          note: "Contact us for any questions on your order.".tr(),
          transactions: [
            {
              "amount": {
                "total": total,
                "currency": currencyCode?.toUpperCase(),
                "details": {
                  "subtotal": subtotal,
                  "shipping": shippingTotal,
                  "shipping_discount": 0,
                  "tax": taxTotal
                }
              },
              "description": description,
              "item_list": {
                "items": cartLineItems
                    .map((item) => {
                          "name": item.name,
                          "quantity": item.quantity,
                          "price": item.total,
                          "currency": currencyCode?.toUpperCase()
                        })
                    .toList(),
                "shipping_address": {
                  "recipient_name":
                      "${billingDetails?.shippingAddress?.nameFull()}",
                  "line1": billingDetails?.shippingAddress?.addressLine,
                  "line2": "",
                  "city": billingDetails?.shippingAddress?.city,
                  "country_code": billingDetails
                      ?.shippingAddress?.customerCountry?.countryCode,
                  "postal_code": billingDetails?.shippingAddress?.postalCode,
                  "phone": billingDetails?.shippingAddress?.phoneNumber,
                  "state": billingDetails
                      ?.shippingAddress?.customerCountry?.state?.name
                },
              }
            }
          ],
          onSuccess: (Map params) async {
            String? transactionId = payPalTransactionId(params);
            if (transactionId == null) {
              // The payment went through but PayPal's response had no id, so
              // WooSignal can't verify it. The order is still created (unpaid)
              // so the store can match it up by hand.
              NyLogger.error(
                  "PayPal payment succeeded without a sale or payment id");
            }
            OrderWC orderWC = await buildOrderWC(
                taxRate: taxRate, transactionId: transactionId);
            Order? order =
                await (appWooSignal((api) => api.createOrder(orderWC)));

            if (order == null) {
              stateAction("payment_failed",
                  state: CheckoutConfirmationPage.path,
                  data: {
                    "title": trans("Error"),
                    "description":
                        trans("Something went wrong, please contact our store")
                  });
              return;
            }

            routeTo(CheckoutStatusPage.path, data: order);
          },
          onError: (error) {
            NyLogger.error(error.toString());
            showToastNotification(
              context,
              title: trans("Error"),
              description:
                  trans("Something went wrong, please contact our store"),
            );
            stateAction("payment_finished",
                state: CheckoutConfirmationPage.path);
          },
          onCancel: () {
            showToastNotification(
              context,
              title: trans("Payment Cancelled"),
              description: trans("The payment has been cancelled"),
            );
            stateAction("payment_finished",
                state: CheckoutConfirmationPage.path);
          },
        ),
      ),
    );
  });
}
