//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/resources/widgets/checkout_customer_note_widget.dart';
import '/app/models/cart.dart';
import '/app/models/checkout_session.dart';
import '/app/models/customer_country.dart';
import '/app/models/payment_type.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/checkout_coupon_amount_widget.dart';
import '/resources/widgets/checkout_payment_type_widget.dart';
import '/resources/widgets/checkout_select_coupon_widget.dart';
import '/resources/widgets/checkout_shipping_type_widget.dart';
import '/resources/widgets/checkout_store_heading_widget.dart';
import '/resources/widgets/checkout_user_details_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CheckoutConfirmationPage extends NyStatefulWidget {
  static RouteView path = ("/checkout", (_) => CheckoutConfirmationPage());

  CheckoutConfirmationPage({super.key})
      : super(child: () => _CheckoutConfirmationPageState());
}

class _CheckoutConfirmationPageState extends NyPage<CheckoutConfirmationPage> {
  List<TaxRate> _taxRates = [];
  TaxRate? _taxRate;
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  bool get stateManaged => true;

  /// Shown while `init` runs and while a payment gateway is working.
  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal(
        child: Scaffold(
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
        ),
      );

  /// Actions the payment gateways send to this page.
  @override
  Map<String, Function> get stateActions => {
        "payment_started": () => setLoading(true),
        "payment_finished": () => setLoading(false),
        "payment_failed": (data) {
          setLoading(false);
          showToast(
            title: data['title'],
            description: data['description'],
          );
        },
      };

  @override
  get init => () async {
        CheckoutSession.getInstance.coupon = null;
        List<PaymentType?> paymentTypes = await getPaymentTypes();

        if (CheckoutSession.getInstance.paymentType == null &&
            paymentTypes.isNotEmpty) {
          CheckoutSession.getInstance.paymentType = paymentTypes.firstWhere(
              (paymentType) => paymentType?.id == 20,
              orElse: () => paymentTypes.first);
        }
        _getTaxes();
      };

  Future<void> _getTaxes() async {
    _taxRates = [];
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
  }

  void _getUserTax() {
    if (_taxRates.isEmpty) {
      return;
    }

    if (CheckoutSession.getInstance.billingDetails == null ||
        CheckoutSession.getInstance.billingDetails!.shippingAddress == null) {
      return;
    }
    CustomerCountry? shippingCountry = CheckoutSession
        .getInstance.billingDetails!.shippingAddress!.customerCountry;
    String? postalCode =
        CheckoutSession.getInstance.billingDetails!.shippingAddress!.postalCode;

    if (shippingCountry == null) {
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
  }

  @override
  Widget view(BuildContext context) {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(trans("Checkout")).onTap(() {
              StateAction.refreshPage(CheckoutConfirmationPage.path,
                  setState: () {});
            }),
            Text(_wooSignalApp?.appName ?? getEnv('APP_NAME')).bodySmall(),
          ],
        ),
        centerTitle: false,
        leading: Container(
          margin: EdgeInsets.only(left: 0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              CheckoutSession.getInstance.coupon = null;
              Navigator.pop(context);
            },
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CheckoutStoreHeadingWidget(),
                CheckoutUserDetailsWidget(
                  checkoutSession: checkoutSession,
                ),
                CheckoutPaymentTypeWidget(
                  checkoutSession: checkoutSession,
                ),
                CheckoutShippingTypeWidget(
                  checkoutSession: checkoutSession,
                  wooSignalApp: _wooSignalApp,
                ),
                if (_wooSignalApp?.couponEnabled == true)
                  CheckoutSelectCouponWidget(
                    checkoutSession: checkoutSession,
                  ),
                CheckoutCustomerNote(checkoutSession: checkoutSession),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: wsBoxShadow(),
                    color: Colors.white,
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
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                            ),
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
                          if (_wooSignalApp?.disableShipping != 1)
                            CheckoutMetaLine(
                                title: trans("Shipping fee"),
                                amount: CheckoutSession
                                            .getInstance.shippingType ==
                                        null
                                    ? trans("Select shipping")
                                    : CheckoutSession.getInstance.shippingType!
                                        .getTotal(withFormatting: true)),
                          if (_taxRate != null)
                            CheckoutTaxTotal(taxRate: _taxRate),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 8, left: 8, right: 8)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text:
                                    '${trans('By completing this order, I agree to all')} ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 12,
                                    ),
                                children: <TextSpan>[
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _openTermsLink,
                                    text: trans("Terms and conditions")
                                        .toLowerCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: context.color.general.primaryAccent,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  CheckoutTotal(title: trans("Total"), taxRate: _taxRate),
                  Padding(padding: EdgeInsets.only(bottom: 8)),
                  Button.primary(
                    text: trans("CHECKOUT"),
                    onPressed: () async {
                      await lockRelease('payment', perform: () async {
                        await _handleCheckout();
                      });
                    }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _openTermsLink() =>
      openUrl(AppHelper.instance.appConfig?.appTermsLink ?? "");

  Future<void> _handleCheckout() async {
    _getUserTax();

    CheckoutSession checkoutSession = CheckoutSession.getInstance;
    if (checkoutSession.billingDetails!.billingAddress == null) {
      showToast(
        title: trans("Oops"),
        description:
            trans("Please select add your billing/shipping address to proceed"),
        id: 'warning',
      );
      return;
    }

    if (checkoutSession.billingDetails?.billingAddress?.hasMissingFields() ??
        true) {
      showToast(
        title: trans("Oops"),
        description: trans("Your billing/shipping details are incomplete"),
        id: 'warning',
      );
      return;
    }

    if (_wooSignalApp!.disableShipping == 0 &&
        checkoutSession.shippingType == null) {
      showToast(
        title: trans("Oops"),
        description: trans("Please select a shipping method to proceed"),
        id: 'warning',
      );
      return;
    }

    if (checkoutSession.paymentType == null) {
      showToast(
        title: trans("Oops"),
        description: trans("Please select a payment method to proceed"),
        id: 'warning',
      );
      return;
    }

    if (_wooSignalApp.disableShipping == 0 &&
        checkoutSession.shippingType?.minimumValue != null) {
      String total = await Cart.getInstance.getTotal();

      double doubleTotal = double.parse(total);

      double doubleMinimumValue =
          double.parse(checkoutSession.shippingType!.minimumValue!);

      if (doubleTotal < doubleMinimumValue) {
        showToast(
            title: trans("Sorry"),
            description:
                "${trans("Spend a minimum of")} ${formatDoubleCurrency(total: doubleMinimumValue)} ${trans("for")} ${checkoutSession.shippingType!.getTitle()}",
            id: 'info',
            duration: Duration(seconds: 3));
        return;
      }
    }

    bool appStatus = await (appWooSignal((api) => api.checkAppStatus()));

    if (!appStatus) {
      showToast(
          title: trans("Sorry"),
          description: trans("Retry later"),
          id: 'info',
          duration: Duration(seconds: 3));
      return;
    }

    try {
      if (!mounted) return;
      await checkoutSession.paymentType!.pay(context, taxRate: _taxRate);
    } on Exception catch (e) {
      printError(e.toString());
    }
  }
}
