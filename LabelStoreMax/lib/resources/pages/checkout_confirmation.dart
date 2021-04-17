//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  CheckoutConfirmationPage({Key key}) : super(key: key);

  @override
  CheckoutConfirmationPageState createState() =>
      CheckoutConfirmationPageState();
}

class CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  bool _showFullLoader = true, _isProcessingPayment = false;

  List<TaxRate> _taxRates = [];
  TaxRate _taxRate;
  final WooSignalApp _wooSignalApp = AppHelper.instance.appConfig;

  @override
  void initState() {
    super.initState();

    if (CheckoutSession.getInstance.paymentType == null &&
        getPaymentTypes().length > 0) {
      CheckoutSession.getInstance.paymentType = getPaymentTypes().first;
    }
    _getTaxes();
  }

  reloadState({@required bool showLoader}) {
    setState(() {
      _showFullLoader = showLoader ?? false;
    });
  }

  _getTaxes() async {
    int pageIndex = 1;
    bool fetchMore = true;
    while (fetchMore == true) {
      List<TaxRate> tmpTaxRates = await appWooSignal(
          (api) => api.getTaxRates(page: pageIndex, perPage: 100));

      if (tmpTaxRates != null && tmpTaxRates.length > 0) {
        _taxRates.addAll(tmpTaxRates);
      }
      if (tmpTaxRates.length >= 100) {
        pageIndex += 1;
      } else {
        fetchMore = false;
      }
    }

    if (_taxRates == null || _taxRates.length == 0) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }

    if (CheckoutSession.getInstance.billingDetails == null ||
        CheckoutSession.getInstance.billingDetails.shippingAddress == null) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }
    CustomerCountry shippingCountry = CheckoutSession
        .getInstance.billingDetails.shippingAddress.customerCountry;
    String postalCode =
        CheckoutSession.getInstance.billingDetails.shippingAddress.postalCode;

    if (shippingCountry == null) {
      _showFullLoader = false;
      setState(() {});
      return;
    }

    TaxRate taxRate;
    if (shippingCountry.hasState()) {
      taxRate = _taxRates.firstWhere((t) {
        if (shippingCountry == null ||
            (shippingCountry?.state?.code ?? "") == "") {
          return false;
        }

        List<String> stateElements = shippingCountry.state.code.split(":");
        String state = stateElements.last;

        if (t.country == shippingCountry.countryCode &&
            t.state == state &&
            t.postcode == postalCode) {
          return true;
        }

        if (t.country == shippingCountry.countryCode && t.state == state) {
          return true;
        }
        return false;
      }, orElse: () => null);
    }

    if (taxRate == null) {
      taxRate = _taxRates.firstWhere(
        (t) =>
            t.country == shippingCountry.countryCode &&
            t.postcode == postalCode,
        orElse: () => null,
      );

      if (taxRate == null) {
        taxRate = _taxRates.firstWhere(
          (t) => t.country == shippingCountry.countryCode,
          orElse: () => null,
        );
      }
    }

    if (taxRate != null) {
      _taxRate = taxRate;
    }
    setState(() {
      _showFullLoader = false;
    });
  }

  _actionCheckoutDetails() {
    Navigator.pushNamed(context, "/checkout-details").then((e) {
      setState(() {
        _showFullLoader = true;
      });
      _getTaxes();
    });
  }

  _actionPayWith() {
    Navigator.pushNamed(context, "/checkout-payment-type")
        .then((value) => setState(() {}));
  }

  _actionSelectShipping() {
    CustomerAddress shippingAddress =
        CheckoutSession.getInstance.billingDetails.shippingAddress;
    if (shippingAddress == null || shippingAddress.customerCountry == null) {
      showToastNotification(context,
          title: trans(context, "Oops"),
          description: trans(context, "Add your shipping details first"),
          icon: Icons.local_shipping);
      return;
    }
    Navigator.pushNamed(context, "/checkout-shipping-type").then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveThemeMode = AdaptiveTheme.of(context).mode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(context, "Checkout"),
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: !_showFullLoader
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: adaptiveThemeMode.isLight
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow:
                            adaptiveThemeMode.isLight ? wsBoxShadow() : null,
                      ),
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                  boxShadow: adaptiveThemeMode.isLight
                                      ? wsBoxShadow(blurRadius: 10)
                                      : null,
                                  color: Colors.transparent,
                                ),
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.only(top: 16),
                                child: ClipRRect(
                                  child: StoreLogo(height: 65),
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            ((CheckoutSession.getInstance.billingDetails != null &&
                                    CheckoutSession.getInstance.billingDetails
                                            .billingAddress !=
                                        null)
                                ? wsCheckoutRow(context,
                                    heading: trans(
                                        context, "Billing/shipping details"),
                                    leadImage: Icon(Icons.home),
                                    leadTitle:
                                        (CheckoutSession.getInstance.billingDetails == null ||
                                                CheckoutSession.getInstance
                                                    .billingDetails.billingAddress
                                                    .hasMissingFields()
                                            ? trans(
                                                context, "Billing address is incomplete")
                                            : CheckoutSession.getInstance
                                                .billingDetails.billingAddress
                                                .addressFull()),
                                    action: _actionCheckoutDetails,
                                    showBorderBottom: true)
                                : wsCheckoutRow(context,
                                    heading:
                                        trans(context, "Billing/shipping details"),
                                    leadImage: Icon(Icons.home),
                                    leadTitle: trans(context, "Add billing & shipping details"),
                                    action: _actionCheckoutDetails,
                                    showBorderBottom: true)),
                            (CheckoutSession.getInstance.paymentType != null
                                ? wsCheckoutRow(context,
                                    heading: trans(context, "Payment method"),
                                    leadImage: Image.asset(
                                      getImageAsset(CheckoutSession
                                          .getInstance.paymentType.assetImage),
                                      width: 70,
                                      color: adaptiveThemeMode.isLight
                                          ? null
                                          : Colors.white,
                                    ),
                                    leadTitle: CheckoutSession
                                        .getInstance.paymentType.desc,
                                    action: _actionPayWith,
                                    showBorderBottom: true)
                                : wsCheckoutRow(context,
                                    heading: trans(context, "Pay with"),
                                    leadImage: Icon(Icons.payment),
                                    leadTitle: trans(
                                        context, "Select a payment method"),
                                    action: _actionPayWith,
                                    showBorderBottom: true)),
                            _wooSignalApp.disableShipping == 1
                                ? null
                                : (CheckoutSession.getInstance.shippingType !=
                                        null
                                    ? wsCheckoutRow(context,
                                        heading:
                                            trans(context, "Shipping selected"),
                                        leadImage: Icon(Icons.local_shipping),
                                        leadTitle: CheckoutSession
                                            .getInstance.shippingType
                                            .getTitle(),
                                        action: _actionSelectShipping)
                                    : wsCheckoutRow(
                                        context,
                                        heading:
                                            trans(context, "Select shipping"),
                                        leadImage: Icon(Icons.local_shipping),
                                        leadTitle: trans(context,
                                            "Select a shipping option"),
                                        action: _actionSelectShipping,
                                      )),
                          ].where((e) => e != null).toList()),
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
                        title: trans(context, "Subtotal"),
                      ),
                      _wooSignalApp.disableShipping == 1
                          ? null
                          : widgetCheckoutMeta(context,
                              title: trans(context, "Shipping fee"),
                              amount:
                                  CheckoutSession.getInstance.shippingType ==
                                          null
                                      ? trans(context, "Select shipping")
                                      : CheckoutSession.getInstance.shippingType
                                          .getTotal(withFormatting: true)),
                      (_taxRate != null
                          ? wsCheckoutTaxAmountWidgetFB(taxRate: _taxRate)
                          : null),
                      wsCheckoutTotalWidgetFB(
                          title: trans(context, "Total"), taxRate: _taxRate),
                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                    ].where((e) => e != null).toList(),
                  ),
                  PrimaryButton(
                    title: _isProcessingPayment
                        ? "PROCESSING..."
                        : trans(context, "CHECKOUT"),
                    action: _isProcessingPayment ? null : _handleCheckout,
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppLoaderWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        "${trans(context, "One moment")}...",
                        style: Theme.of(context).textTheme.subtitle1,
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
      showToastNotification(
        context,
        title: trans(context, "Oops"),
        description: trans(context,
            "Please select add your billing/shipping address to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (CheckoutSession.getInstance.billingDetails.billingAddress
        .hasMissingFields()) {
      showToastNotification(
        context,
        title: trans(context, "Oops"),
        description:
            trans(context, "Your billing/shipping details are incomplete"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (_wooSignalApp.disableShipping == 1 &&
        CheckoutSession.getInstance.shippingType == null) {
      showToastNotification(
        context,
        title: trans(context, "Oops"),
        description:
            trans(context, "Please select a shipping method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (CheckoutSession.getInstance.paymentType == null) {
      showToastNotification(
        context,
        title: trans(context, "Oops"),
        description:
            trans(context, "Please select a payment method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.payment,
      );
      return;
    }

    if (_wooSignalApp.disableShipping != 1 &&
        CheckoutSession.getInstance.shippingType?.minimumValue != null) {
      String total = await Cart.getInstance.getTotal();
      if (total == null) {
        return;
      }
      double doubleTotal = double.parse(total);
      double doubleMinimumValue =
          double.parse(CheckoutSession.getInstance.shippingType?.minimumValue);

      if (doubleTotal < doubleMinimumValue) {
        showToastNotification(context,
            title: trans(context, "Sorry"),
            description:
                "${trans(context, "Spend a minimum of")} ${formatDoubleCurrency(total: doubleMinimumValue)} ${trans(context, "for")} ${CheckoutSession.getInstance.shippingType.getTitle()}",
            style: ToastNotificationStyleType.INFO,
            duration: Duration(seconds: 3));
        return;
      }
    }

    bool appStatus = await appWooSignal((api) => api.checkAppStatus());

    if (!appStatus) {
      showToastNotification(context,
          title: trans(context, "Sorry"),
          description: "${trans(context, "Retry later")}",
          style: ToastNotificationStyleType.INFO,
          duration: Duration(seconds: 3));
      return;
    }

    if (_isProcessingPayment == true) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    CheckoutSession.getInstance.paymentType
        .pay(context, state: this, taxRate: _taxRate);

    Future.delayed(Duration(milliseconds: 5000), () {
      setState(() {
        _isProcessingPayment = false;
      });
    });
  }
}
