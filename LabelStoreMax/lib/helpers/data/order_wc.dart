//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:io';

import 'package:label_storemax/helpers/shared_pref/sp_user_id.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/billing_details.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/tax_rate.dart';

Future<OrderWC> buildOrderWC({TaxRate taxRate, bool markPaid = true}) async {
  OrderWC orderWC = OrderWC();

  String paymentMethodName = CheckoutSession.getInstance.paymentType.name ?? "";

  orderWC.paymentMethod = Platform.isAndroid
      ? "$paymentMethodName - Android App"
      : "$paymentMethodName - IOS App";

  orderWC.paymentMethodTitle = paymentMethodName.toLowerCase();

  orderWC.setPaid = markPaid;
  orderWC.status = "pending";
  orderWC.currency = app_currency_iso.toUpperCase();
  orderWC.customerId =
      (use_wp_login == true) ? int.parse(await readUserId()) : 0;

  List<LineItems> lineItems = [];
  List<CartLineItem> cartItems = await Cart.getInstance.getCart();
  cartItems.forEach((cartItem) {
    LineItems tmpLineItem = LineItems();
    tmpLineItem.quantity = cartItem.quantity;
    tmpLineItem.name = cartItem.name;
    tmpLineItem.productId = cartItem.productId;
    if (cartItem.variationId != null && cartItem.variationId != 0) {
      tmpLineItem.variationId = cartItem.variationId;
    }

    tmpLineItem.total =
        (cartItem.quantity > 1 ? cartItem.getCartTotal() : cartItem.subtotal);
    tmpLineItem.subtotal = (parseWcPrice(cartItem.subtotal) * cartItem.quantity).toString();

    lineItems.add(tmpLineItem);
  });

  orderWC.lineItems = lineItems;

  BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;

  Billing billing = Billing();
  billing.firstName = billingDetails.billingAddress.firstName;
  billing.lastName = billingDetails.billingAddress.lastName;
  billing.address1 = billingDetails.billingAddress.addressLine;
  billing.city = billingDetails.billingAddress.city;
  billing.postcode = billingDetails.billingAddress.postalCode;
  billing.country = billingDetails.billingAddress.country;
  billing.email = billingDetails.billingAddress.emailAddress;
  if (billingDetails.billingAddress.country == "United States") {
    billing.state = billingDetails.billingAddress.state;
  }

  orderWC.billing = billing;

  Shipping shipping = Shipping();

  shipping.firstName = billingDetails.shippingAddress.firstName;
  shipping.lastName = billingDetails.shippingAddress.lastName;
  shipping.address1 = billingDetails.shippingAddress.addressLine;
  shipping.city = billingDetails.shippingAddress.city;
  shipping.postcode = billingDetails.shippingAddress.postalCode;
  if (billingDetails.shippingAddress.country == "United States") {
    shipping.state = billingDetails.shippingAddress.state;
  }
  shipping.country = billingDetails.shippingAddress.country;

  orderWC.shipping = shipping;

  orderWC.shippingLines = [];
  if (app_disable_shipping == false) {
    Map<String, dynamic> shippingLineFeeObj =
        CheckoutSession.getInstance.shippingType.toShippingLineFee();
    if (shippingLineFeeObj != null) {
      ShippingLines shippingLine = ShippingLines();
      shippingLine.methodId = shippingLineFeeObj['method_id'];
      shippingLine.methodTitle = shippingLineFeeObj['method_title'];
      shippingLine.total = shippingLineFeeObj['total'];
      orderWC.shippingLines.add(shippingLine);
    }
  }

  if (taxRate != null) {
    orderWC.feeLines = [];
    FeeLines feeLines = FeeLines();
    feeLines.name = taxRate.name;
    feeLines.total = await Cart.getInstance.taxAmount(taxRate);
    feeLines.taxClass = "";
    feeLines.taxStatus = "taxable";
    orderWC.feeLines.add(feeLines);
  }

  return orderWC;
}
