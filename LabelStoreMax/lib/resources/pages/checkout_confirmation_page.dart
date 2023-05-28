//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/gestures.dart';
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

class CheckoutConfirmationPageState extends NyState<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  bool _showFullLoader = true, _isProcessingPayment = false;
  final List<TaxRate> _taxRates = [];
  TaxRate? _taxRate;
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  init() async {
    super.init();
    CheckoutSession.getInstance.coupon = null;
    List<PaymentType?> paymentTypes = await getPaymentTypes();

    if (CheckoutSession.getInstance.paymentType == null &&
        paymentTypes.isNotEmpty) {
      CheckoutSession.getInstance.paymentType = paymentTypes.firstWhere(
          (paymentType) => paymentType?.id == 20,
          orElse: () => paymentTypes.first);
      print(CheckoutSession.getInstance.paymentType?.name);
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(trans("Checkout")),
            Text(_wooSignalApp?.appName ?? getEnv('APP_NAME')).bodySmall(context),
          ],
        ),
        centerTitle: false,
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
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
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
                    if (_wooSignalApp!.couponEnabled == true)
                      CheckoutSelectCouponWidget(
                        context: context,
                        checkoutSession: checkoutSession,
                        resetState: () => setState(() {}),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: wsBoxShadow(),
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(16)
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Icon(Icons.receipt),
                                Padding(padding: EdgeInsets.only(right: 8),),
                                Text(trans("Order Summary")).fontWeightBold()
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(padding: EdgeInsets.only(top: 16)),
                              CheckoutSubtotal(
                                title: trans("Subtotal"),
                              ),
                              CheckoutCouponAmountWidget(
                                  checkoutSession: checkoutSession),
                              if (_wooSignalApp!.disableShipping != 1)
                                CheckoutMetaLine(
                                    title: trans("Shipping fee"),
                                    amount: CheckoutSession
                                                .getInstance.shippingType ==
                                            null
                                        ? trans("Select shipping")
                                        : CheckoutSession
                                            .getInstance.shippingType!
                                            .getTotal(withFormatting: true)),
                              if (_taxRate != null)
                                CheckoutTaxTotal(taxRate: _taxRate),
                              Padding(padding: EdgeInsets.only(top: 8, left: 8, right: 8)),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text:
                                  '${trans('By completing this order, I agree to all')} ',
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 12,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()..onTap = _openTermsLink,
                                      text: trans("Terms and conditions").toLowerCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                        color: ThemeColor.get(context)
                                            .primaryAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ".",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                  children: [
                    CheckoutTotal(title: trans("Total"), taxRate: _taxRate),
                    Padding(padding: EdgeInsets.only(bottom: 8)),
                    PrimaryButton(
                      title: _isProcessingPayment
                          ? "${trans("PROCESSING")}..."
                          : trans("CHECKOUT"),
                      action: _isProcessingPayment ? null : _handleCheckout,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _openTermsLink() => openBrowserTab(url: AppHelper.instance.appConfig?.appTermsLink ?? "");

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

    if (checkoutSession.billingDetails?.billingAddress?.hasMissingFields() ??
        true) {
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

    try {
      await checkoutSession.paymentType!
          .pay(context, state: this, taxRate: _taxRate);
    } on Exception catch (e) {
      print(e.toString());
    }

    setState(() {
      _isProcessingPayment = false;
    });
  }
}
