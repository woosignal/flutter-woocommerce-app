//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/app_payment_methods.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:label_storemax/app_country_options.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  CheckoutConfirmationPage({Key key}) : super(key: key);

  @override
  CheckoutConfirmationPageState createState() =>
      CheckoutConfirmationPageState();
}

class CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  GlobalKey<CheckoutConfirmationPageState> _key =
      GlobalKey<CheckoutConfirmationPageState>();

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

  void reloadState({bool showLoader}) {
    setState(() {
      _showFullLoader = showLoader ?? false;
    });
  }

  _getTaxes() async {
    _taxRates = await appWooSignal((api) {
      return api.getTaxRates(page: 1, perPage: 100);
    });

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
                                              .addressFull(),
                                        )),
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
                                      .getInstance.paymentType.desc,
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
                      wsCheckoutSubtotalWidgetFB(
                          title: trans(context, "Subtotal")),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        trans(context, "One moment") + "...",
                        style: Theme.of(context).primaryTextTheme.subhead,
                      ),
                    )
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

    CheckoutSession.getInstance.paymentType
        .pay(context, state: this, taxRate: _taxRate);
  }
}
