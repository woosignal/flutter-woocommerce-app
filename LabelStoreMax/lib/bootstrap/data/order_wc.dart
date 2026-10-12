//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:io';

import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';

import '/app/models/billing_details.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

/// WooCommerce gateway ids, keyed by the lowercased payment names used in
/// config/payment_gateways.dart. `payment_method` has to match a registered
/// gateway id, otherwise the admin cannot refund through it and any plugin
/// branching on get_payment_method() never fires. Gateways that aren't listed
/// fall back to the lowercased name, so name custom ones after their id.
const Map<String, String> _wcPaymentMethodIds = {
  "stripe": "stripe",
  "cashondelivery": "cod",
  "paypal": "paypal",
};

/// Human readable labels for the same gateways, used for
/// `payment_method_title`.
const Map<String, String> _wcPaymentMethodTitles = {
  "stripe": "Stripe",
  "cashondelivery": "Cash on delivery",
  "paypal": "PayPal",
};

/// `DefaultShippingState.code` is stored as `<country>:<state>` (e.g. `US:AL`),
/// but WooCommerce wants the state on its own. Mirrors the split the tax rate
/// lookup does in checkout_confirmation_page.dart, so the order records the
/// same identifiers the tax was worked out from.
String? _wcStateCode(String? stateCode) {
  if (stateCode == null || stateCode == "") {
    return null;
  }
  return stateCode.split(":").last;
}

Future<OrderWC> buildOrderWC(
    {TaxRate? taxRate, bool markPaid = true, String? transactionId}) async {
  CheckoutSession checkoutSession = CheckoutSession.getInstance;
  OrderWC orderWC = OrderWC();
  WooSignalApp wooSignalApp = AppHelper.instance.appConfig!;

  String paymentMethodName = checkoutSession.paymentType!.name;
  String paymentMethodKey = paymentMethodName.toLowerCase();
  String paymentMethodTitle =
      _wcPaymentMethodTitles[paymentMethodKey] ?? paymentMethodName;
  String platformName = Platform.isAndroid ? "Android App" : "iOS App";

  orderWC.paymentMethod =
      _wcPaymentMethodIds[paymentMethodKey] ?? paymentMethodKey;

  orderWC.paymentMethodTitle = "$paymentMethodTitle ($platformName)";

  // Order level meta, assigned once at the end so everything can contribute.
  List<MetaData> metaData = [];

  if (transactionId != null && transactionId != "") {
    orderWC.transactionId = transactionId;
    // Kept under our own key as well as the core `transaction_id` field.
    // Gateway plugins write that field freely, so reconciliation needs a copy
    // that stays put.
    metaData.add(MetaData(key: "_woosignal_payment_ref", value: transactionId));
  }

  orderWC.setPaid = markPaid;
  // Paid orders start as `pending` with `set_paid`, which WooCommerce itself
  // advances to processing/completed. Unpaid orders (Cash on Delivery) are
  // created as `processing`, matching WooCommerce's own COD gateway: stock is
  // reduced and the order is ready to fulfil. Use "on-hold" instead if you
  // want to confirm COD orders manually before fulfilment (`pending` would
  // send no new-order email, reduce no stock and be auto-cancelled).
  orderWC.status = markPaid ? "pending" : "processing";
  orderWC.currency = wooSignalApp.currencyMeta!.code!.toUpperCase();
  // Only attribute the order to a customer whose session is still valid
  // (wpUserLoggedIn is false once the token has expired).
  if (wooSignalApp.wpLoginEnabled == 1 && await WPJsonAPI.wpUserLoggedIn()) {
    WpUser? wpUser = await WPJsonAPI.wpUser();
    if (wpUser?.id != null) {
      orderWC.customerId = wpUser!.id;
    }
  }

  List<LineItems> lineItems = [];
  List<CartLineItem> cartItems = await Cart.getInstance.getCart();
  for (var cartItem in cartItems) {
    LineItems tmpLineItem = LineItems();
    tmpLineItem.quantity = cartItem.quantity;
    tmpLineItem.name = cartItem.name;
    tmpLineItem.productId = cartItem.productId;
    if (cartItem.variationId != null && cartItem.variationId != 0) {
      tmpLineItem.variationId = cartItem.variationId;
    }

    tmpLineItem.subtotal = (parseWcPrice(cartItem.subtotal) *
            parseWcPrice(cartItem.quantity.toString()))
        .toString();
    lineItems.add(tmpLineItem);
  }

  orderWC.lineItems = lineItems;

  BillingDetails billingDetails = checkoutSession.billingDetails!;

  Billing billing = Billing();
  billing.firstName = billingDetails.billingAddress?.firstName;
  billing.lastName = billingDetails.billingAddress?.lastName;
  billing.address1 = billingDetails.billingAddress?.addressLine;
  billing.city = billingDetails.billingAddress?.city;
  billing.postcode = billingDetails.billingAddress?.postalCode;
  billing.email = billingDetails.billingAddress?.emailAddress;
  if (billingDetails.billingAddress?.phoneNumber != "") {
    billing.phone = billingDetails.billingAddress?.phoneNumber;
  }
  if (billingDetails.billingAddress?.customerCountry?.hasState() ?? false) {
    billing.state = _wcStateCode(
        billingDetails.billingAddress?.customerCountry?.state?.code);
  }
  billing.country = billingDetails.billingAddress?.customerCountry?.countryCode;

  orderWC.billing = billing;

  Shipping shipping = Shipping();

  shipping.firstName = billingDetails.shippingAddress?.firstName;
  shipping.lastName = billingDetails.shippingAddress?.lastName;
  shipping.address1 = billingDetails.shippingAddress?.addressLine;
  shipping.city = billingDetails.shippingAddress?.city;
  shipping.postcode = billingDetails.shippingAddress?.postalCode;
  if (billingDetails.shippingAddress?.customerCountry?.hasState() ?? false) {
    shipping.state = _wcStateCode(
        billingDetails.shippingAddress?.customerCountry?.state?.code);
  }
  shipping.country =
      billingDetails.shippingAddress?.customerCountry?.countryCode;

  orderWC.shipping = shipping;

  orderWC.shippingLines = [];
  if (wooSignalApp.disableShipping != 1) {
    // `?.`, not `!`: the customer can reach the confirmation page with no
    // shipping method chosen - the shipping methods call failed, the store
    // enabled shipping after they started, or nothing matched their address.
    // The order is still placeable, it just carries no shipping line, which is
    // what the null check below already handles.
    Map<String, dynamic>? shippingLineFeeObj =
        checkoutSession.shippingType?.toShippingLineFee();
    if (shippingLineFeeObj != null) {
      ShippingLines shippingLine = ShippingLines();
      shippingLine.methodId = shippingLineFeeObj['method_id'];
      shippingLine.methodTitle = shippingLineFeeObj['method_title'];
      shippingLine.total = shippingLineFeeObj['total'];
      orderWC.shippingLines!.add(shippingLine);
    }
  }

  if (taxRate != null) {
    orderWC.feeLines = [];
    FeeLines feeLines = FeeLines();
    feeLines.name = taxRate.name;
    feeLines.total = await Cart.getInstance.taxAmount(taxRate);
    feeLines.taxClass = "";
    feeLines.taxStatus = "taxable";
    orderWC.feeLines!.add(feeLines);
  }

  if (checkoutSession.coupon != null) {
    orderWC.couponLines = [];
    CouponLines couponLine = CouponLines(code: checkoutSession.coupon!.code);
    orderWC.couponLines!.add(couponLine);
  }

  if (checkoutSession.customerNote?.isNotEmpty ?? false) {
    orderWC.customerNote = checkoutSession.customerNote;
  }

  if (metaData.isNotEmpty) {
    orderWC.metaData = metaData;
  }

  return orderWC;
}
