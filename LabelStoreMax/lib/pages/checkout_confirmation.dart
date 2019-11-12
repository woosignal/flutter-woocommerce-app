//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2019 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal_stripe/woosignal_stripe.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart' as WS;
import 'package:woosignal/woosignal.dart';
import 'dart:io';
import 'package:label_storemax/app_country_options.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  CheckoutConfirmationPage();

  @override
  _CheckoutConfirmationPageState createState() =>
      _CheckoutConfirmationPageState();
}

class _CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  _CheckoutConfirmationPageState();

  bool _showFullLoader;

  List<TaxRate> _taxRates;
  TaxRate _taxRate;

  @override
  void initState() {
    super.initState();

    _showFullLoader = true;
    if (CheckoutSession.getInstance.paymentType == null) {
      CheckoutSession.getInstance.paymentType = arrPaymentMethods.first;
    }

    _getTaxes();
  }

  _getTaxes() async {
    WooSignal wooSignal = await WooSignal.getInstance(config: wsConfig);
    _taxRates = await wooSignal.getTaxRates(page: 1, perPage: 100);
    if (CheckoutSession.getInstance.billingDetails.shippingAddress == null) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }
    String country =
        CheckoutSession.getInstance.billingDetails.shippingAddress.country;
    Map<String, dynamic> countryMap = appCountryOptions
        .firstWhere((c) => c['name'] == country, orElse: () => null);
    if (countryMap == null) {
      _showFullLoader = false;
      setState(() {});
      return;
    }
    String countryCode = countryMap["code"];

    TaxRate taxRate = _taxRates.firstWhere((t) => t.country == countryCode,
        orElse: () => null);

    if (taxRate != null) {
      _taxRate = taxRate;
    }
    setState(() {
      _showFullLoader = false;
    });
  }

  _actionCheckoutDetails() {
    Navigator.pushNamed(context, "/checkout-details").then((e) {
      _showFullLoader = true;
      _getTaxes();
    });
  }

  _actionPayWith() {
    Navigator.pushNamed(context, "/checkout-payment-type");
  }

  _actionSelectShipping() {
    CustomerAddress shippingAddress =
        CheckoutSession.getInstance.billingDetails.shippingAddress;
    if (shippingAddress == null || shippingAddress.country == "") {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Add your shipping details first"),
          icon: Icons.local_shipping);
      return;
    }
    Navigator.pushNamed(context, "/checkout-shipping-type");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: storeLogo(height: 50),
        centerTitle: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: !_showFullLoader
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(trans(context, "Checkout"),
                        style: Theme.of(context).primaryTextTheme.subhead),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: wsBoxShadow()),
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ((CheckoutSession.getInstance.billingDetails
                                      .billingAddress !=
                                  null)
                              ? wsCheckoutRow(context,
                                  heading: trans(
                                      context, "Billing/shipping details"),
                                  leadImage: Icon(Icons.home),
                                  leadTitle: (CheckoutSession.getInstance
                                          .billingDetails.billingAddress
                                          .hasMissingFields()
                                      ? "Billing address is incomplete"
                                      : truncateWithEllipsis(
                                          30,
                                          CheckoutSession.getInstance
                                              .billingDetails.billingAddress
                                              .addressFull())),
                                  action: _actionCheckoutDetails,
                                  showBorderBottom: true)
                              : wsCheckoutRow(context,
                                  heading: trans(
                                      context, "Billing/shipping details"),
                                  leadImage: Icon(Icons.home),
                                  leadTitle: trans(context,
                                      "Add billing & shipping details"),
                                  action: _actionCheckoutDetails,
                                  showBorderBottom: true)),
                          (CheckoutSession.getInstance.paymentType != null
                              ? wsCheckoutRow(context,
                                  heading: trans(context, "Payment method"),
                                  leadImage: Image(
                                      image: AssetImage("assets/images/" +
                                          CheckoutSession.getInstance
                                              .paymentType.assetImage),
                                      width: 70),
                                  leadTitle: CheckoutSession
                                      .getInstance.paymentType.name,
                                  action: _actionPayWith,
                                  showBorderBottom: true)
                              : wsCheckoutRow(context,
                                  heading: trans(context, "Pay with"),
                                  leadImage: Icon(Icons.payment),
                                  leadTitle:
                                      trans(context, "Select a payment method"),
                                  action: _actionPayWith,
                                  showBorderBottom: true)),
                          (CheckoutSession.getInstance.shippingType != null
                              ? wsCheckoutRow(context,
                                  heading: trans(context, "Shipping selected"),
                                  leadImage: Icon(Icons.local_shipping),
                                  leadTitle: CheckoutSession
                                      .getInstance.shippingType
                                      .getTitle(),
                                  action: _actionSelectShipping)
                              : wsCheckoutRow(context,
                                  heading: trans(context, "Select shipping"),
                                  leadImage: Icon(Icons.local_shipping),
                                  leadTitle: trans(
                                      context, "Select a shipping option"),
                                  action: _actionSelectShipping)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                      widgetCheckoutMeta(context,
                          title: trans(context, "Shipping fee"),
                          amount:
                              CheckoutSession.getInstance.shippingType == null
                                  ? trans(context, "Select shipping")
                                  : CheckoutSession.getInstance.shippingType
                                      .getTotal(withFormatting: true)),
                      (_taxRate != null
                          ? wsCheckoutTaxAmountWidgetFB(taxRate: _taxRate)
                          : Container()),
                      wsCheckoutSubtotalWidgetFB(
                          title: trans(context, "Subtotal")),
                      wsCheckoutTotalWidgetFB(
                          title: trans(context, "Total"), taxRate: _taxRate),
                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                    ],
                  ),
                  wsPrimaryButton(context,
                      title: trans(context, "CHECKOUT"),
                      action: _handleCheckout),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showAppLoader(),
                    Text(trans(context, "One moment") + "...",
                        style: Theme.of(context).primaryTextTheme.subhead)
                  ],
                ),
              ),
      ),
    );
  }

  _handleCheckout() async {
    if (CheckoutSession.getInstance.billingDetails.billingAddress == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context,
              "Please select add your billing/shipping address to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.billingDetails.billingAddress
        .hasMissingFields()) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Your billing/shipping details are incomplete"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.shippingType == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Please select a shipping method to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.paymentType == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Please select a payment method to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.payment);
      return;
    }

    _pay();
  }

  Future<OrderWC> _buildOrderWC() async {
    OrderWC orderWC = OrderWC();
    if (Platform.isAndroid) {
      orderWC.paymentMethod = "Stripe - Android App";
      orderWC.paymentMethodTitle = "stripe";
    } else if (Platform.isIOS) {
      orderWC.paymentMethod = "Stripe - IOS App";
      orderWC.paymentMethodTitle = "stripe";
    }

    orderWC.setPaid = true;
    orderWC.status = "pending";
    orderWC.currency = app_currency_iso.toUpperCase();

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

      tmpLineItem.total = cartItem.total;
      tmpLineItem.subtotal = cartItem.subtotal;

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

    orderWC.billing = billing;

    Shipping shipping = Shipping();
    shipping.firstName = billingDetails.shippingAddress.firstName;
    shipping.lastName = billingDetails.shippingAddress.lastName;
    shipping.address1 = billingDetails.shippingAddress.addressLine;
    shipping.city = billingDetails.shippingAddress.city;
    shipping.postcode = billingDetails.shippingAddress.postalCode;
    shipping.country = billingDetails.shippingAddress.country;

    orderWC.shipping = shipping;

    orderWC.shippingLines = [];
    Map<String, dynamic> shippingLineFeeObj =
        CheckoutSession.getInstance.shippingType.toShippingLineFee();
    if (shippingLineFeeObj != null) {
      ShippingLines shippingLine = ShippingLines();
      shippingLine.methodId = shippingLineFeeObj['method_id'];
      shippingLine.methodTitle = shippingLineFeeObj['method_title'];
      shippingLine.total = shippingLineFeeObj['total'];
      orderWC.shippingLines.add(shippingLine);
    }

    if (_taxRate != null) {
      orderWC.feeLines = [];
      FeeLines feeLines = FeeLines();
      feeLines.name = _taxRate.name;
      feeLines.total = await Cart.getInstance.taxAmount(_taxRate);
      feeLines.taxClass = "";
      feeLines.taxStatus = "taxable";
      orderWC.feeLines.add(feeLines);
    }

    return orderWC;
  }

  _pay() async {
    WooSignal wsStore = await WooSignal.getInstance(config: wsConfig);

    String cartTotal = await CheckoutSession.getInstance
        .total(withFormat: false, taxRate: _taxRate);

    FlutterStripePayment.setStripeSettings(
        stripeAccount: app_stripe_account, liveMode: app_stripe_live_mode);

    var paymentResponse = await FlutterStripePayment.addPaymentMethod();

    if (paymentResponse.status == PaymentResponseStatus.succeeded) {
      setState(() {
        _showFullLoader = true;
      });

      BillingDetails checkoutDetails =
          CheckoutSession.getInstance.billingDetails;

      Map<String, dynamic> address = {
        "name": checkoutDetails.billingAddress.nameFull(),
        "line1": checkoutDetails.shippingAddress.addressLine,
        "city": checkoutDetails.shippingAddress.city,
        "postal_code": checkoutDetails.shippingAddress.postalCode,
        "country": checkoutDetails.shippingAddress.country
      };

      String cartShortDesc = await Cart.getInstance.cartShortDesc();

      dynamic rsp = await wsStore.stripePaymentIntent(
          amount: cartTotal,
          email: checkoutDetails.billingAddress.emailAddress,
          desc: cartShortDesc,
          shipping: address);

      if (rsp == null) {
        showToastNetworkError();
        setState(() {
          _showFullLoader = false;
        });
        return false;
      }

      String clientSecret = rsp["client_secret"];
      var intentResponse = await FlutterStripePayment.confirmPaymentIntent(
          clientSecret,
          paymentResponse.paymentMethodId,
          (double.parse(cartTotal) * 100));

      if (intentResponse.status == PaymentResponseStatus.succeeded) {
        OrderWC orderWC = await _buildOrderWC();
        WS.Order order = await wsStore.createOrder(orderWC);

        if (order != null) {
          Cart.getInstance.clear();
          Navigator.pushNamed(context, "/checkout-status", arguments: order);
        } else {
          showEdgeAlertWith(context,
              title: trans(context, "Error"),
              desc: trans(
                  context, "Something went wrong, please contact our store"));
          setState(() {
            _showFullLoader = false;
          });
        }
      } else if (intentResponse.status == PaymentResponseStatus.failed) {
        if (app_debug) {
          print(intentResponse.errorMessage);
        }
        showEdgeAlertWith(context,
            title: trans(context, "Error"), desc: intentResponse.errorMessage);
        setState(() {
          _showFullLoader = false;
        });
      } else {
        setState(() {
          _showFullLoader = false;
        });
      }
    }
  }
}
