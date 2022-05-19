//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/checkout_coupon_amount_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_payment_type_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_select_coupon_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_shipping_type_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_store_heading_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_user_details_widget.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  CheckoutConfirmationPage({Key? key}) : super(key: key);

  @override
  CheckoutConfirmationPageState createState() =>
      CheckoutConfirmationPageState();
}

class CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  bool _showFullLoader = true, _isProcessingPayment = false;

  final List<TaxRate> _taxRates = [];
  TaxRate? _taxRate;
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  void initState() {
    super.initState();
    CheckoutSession.getInstance.coupon = null;
    List<PaymentType?> paymentTypes = getPaymentTypes();
    if (CheckoutSession.getInstance.paymentType == null &&
        paymentTypes.isNotEmpty) {
      CheckoutSession.getInstance.paymentType = paymentTypes.first;
    }
    _getTaxes();
  }

  reloadState({required bool showLoader}) {
    setState(() {
      _showFullLoader = showLoader;
    });
  }

  _getTaxes() async {
    int pageIndex = 1;
    bool fetchMore = true;
    while (fetchMore == true) {
      List<TaxRate> tmpTaxRates = await (appWooSignal(
          (api) => api.getTaxRates(page: pageIndex, perPage: 100)));

      if (tmpTaxRates.isNotEmpty) {
        _taxRates.addAll(tmpTaxRates);
      }
      if (tmpTaxRates.length >= 100) {
        pageIndex += 1;
      } else {
        fetchMore = false;
      }
    }

    if (_taxRates.isEmpty) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }

    if (CheckoutSession.getInstance.billingDetails == null ||
        CheckoutSession.getInstance.billingDetails!.shippingAddress == null) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }
    CustomerCountry? shippingCountry = CheckoutSession
        .getInstance.billingDetails!.shippingAddress!.customerCountry;
    String? postalCode =
        CheckoutSession.getInstance.billingDetails!.shippingAddress!.postalCode;

    if (shippingCountry == null) {
      _showFullLoader = false;
      setState(() {});
      return;
    }

    TaxRate? taxRate;
    if (shippingCountry.hasState()) {
      taxRate = _taxRates.firstWhereOrNull((t) {
        if ((shippingCountry.state?.code ?? "") == "") {
          return false;
        }

        List<String> stateElements = shippingCountry.state!.code!.split(":");
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
      });
    }

    if (taxRate == null) {
      taxRate = _taxRates.firstWhereOrNull(
        (t) =>
            t.country == shippingCountry.countryCode &&
            t.postcode == postalCode,
      );

      taxRate ??= _taxRates.firstWhereOrNull(
        (t) => t.country == shippingCountry.countryCode,
      );
    }

    if (taxRate != null) {
      _taxRate = taxRate;
    }
    setState(() {
      _showFullLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;

    if (_showFullLoader == true) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppLoaderWidget(),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "${trans("One moment")}...",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trans("Checkout")),
        centerTitle: true,
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              CheckoutSession.getInstance.coupon = null;
              Navigator.pop(context);
            },
          ),
          margin: EdgeInsets.only(left: 0),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: ThemeColor.get(context)!.backgroundContainer,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: (Theme.of(context).brightness == Brightness.light)
                      ? wsBoxShadow()
                      : null,
                ),
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CheckoutStoreHeadingWidget(),
                      CheckoutUserDetailsWidget(
                        context: context,
                        checkoutSession: checkoutSession,
                        resetState: () {
                          setState(() {
                            _showFullLoader = true;
                          });
                          _getTaxes();
                        },
                      ),
                      CheckoutPaymentTypeWidget(
                        context: context,
                        checkoutSession: checkoutSession,
                        resetState: () => setState(() {}),
                      ),
                      CheckoutShippingTypeWidget(
                        context: context,
                        checkoutSession: checkoutSession,
                        resetState: () => setState(() {}),
                        wooSignalApp: _wooSignalApp,
                      ),
                    ]),
              ),
            ),
            if (_wooSignalApp!.couponEnabled == true)
              CheckoutSelectCouponWidget(
                context: context,
                checkoutSession: checkoutSession,
                resetState: () => setState(() {}),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                CheckoutSubtotal(
                  title: trans("Subtotal"),
                ),
                CheckoutCouponAmountWidget(checkoutSession: checkoutSession),
                if (_wooSignalApp!.disableShipping != 1)
                  CheckoutMetaLine(
                      title: trans("Shipping fee"),
                      amount: CheckoutSession.getInstance.shippingType == null
                          ? trans("Select shipping")
                          : CheckoutSession.getInstance.shippingType!
                              .getTotal(withFormatting: true)),
                if (_taxRate != null) CheckoutTaxTotal(taxRate: _taxRate),
                CheckoutTotal(title: trans("Total"), taxRate: _taxRate),
                Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
              ],
            ),
            PrimaryButton(
              title: _isProcessingPayment
                  ? "${trans("PROCESSING")}..."
                  : trans("CHECKOUT"),
              action: _isProcessingPayment ? null : _handleCheckout,
            ),
          ],
        ),
      ),
    );
  }

  _handleCheckout() async {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;
    if (checkoutSession.billingDetails!.billingAddress == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description:
            trans("Please select add your billing/shipping address to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (checkoutSession.billingDetails!.billingAddress!.hasMissingFields()) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Your billing/shipping details are incomplete"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (_wooSignalApp!.disableShipping == 0 &&
        checkoutSession.shippingType == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Please select a shipping method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (checkoutSession.paymentType == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Please select a payment method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.payment,
      );
      return;
    }

    if (_wooSignalApp!.disableShipping == 0 &&
        checkoutSession.shippingType?.minimumValue != null) {
      String total = await Cart.getInstance.getTotal();

      double doubleTotal = double.parse(total);

      double doubleMinimumValue =
          double.parse(checkoutSession.shippingType!.minimumValue!);

      if (doubleTotal < doubleMinimumValue) {
        showToastNotification(context,
            title: trans("Sorry"),
            description:
                "${trans("Spend a minimum of")} ${formatDoubleCurrency(total: doubleMinimumValue)} ${trans("for")} ${checkoutSession.shippingType!.getTitle()}",
            style: ToastNotificationStyleType.INFO,
            duration: Duration(seconds: 3));
        return;
      }
    }

    bool appStatus = await (appWooSignal((api) => api.checkAppStatus()));

    if (!appStatus) {
      showToastNotification(context,
          title: trans("Sorry"),
          description: trans("Retry later"),
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

    await checkoutSession.paymentType!
        .pay(context, state: this, taxRate: _taxRate);

    setState(() {
      _isProcessingPayment = false;
    });
  }
}
