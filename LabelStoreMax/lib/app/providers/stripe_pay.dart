//
//  LabelCore
//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

stripePay(context,
    {required CheckoutConfirmationPageState state, TaxRate? taxRate}) async {
  WooSignalApp? wooSignalApp = AppHelper.instance.appConfig;

  bool liveMode = getEnv('STRIPE_LIVE_MODE') == null
      ? !wooSignalApp!.stripeLiveMode!
      : getEnv('STRIPE_LIVE_MODE', defaultValue: false);

  // CONFIGURE STRIPE
  Stripe.stripeAccountId =
      getEnv('STRIPE_ACCOUNT') ?? wooSignalApp!.stripeAccount;

  Stripe.publishableKey = liveMode
      ? "pk_live_IyS4Vt86L49jITSfaUShumzi"
      : "pk_test_0jMmpBntJ6UkizPkfiB8ZJxH"; // Don't change this value
  await Stripe.instance.applySettings();

  if (Stripe.stripeAccountId == '') {
    NyLogger.error(
        'You need to connect your Stripe account to WooSignal via the dashboard https://woosignal.com/dashboard');
    return;
  }

  try {
    dynamic rsp = {};
    //   // CHECKOUT HELPER
    await checkout(taxRate, (total, billingDetails, cart) async {
      Map<String, dynamic> address = {
        "name": billingDetails!.billingAddress?.nameFull(),
        "line1": billingDetails.shippingAddress!.addressLine,
        "city": billingDetails.shippingAddress!.city,
        "postal_code": billingDetails.shippingAddress!.postalCode,
        "country": (billingDetails.shippingAddress?.customerCountry?.name ?? "")
      };

      String cartShortDesc = await cart.cartShortDesc();

      rsp = await appWooSignal((api) => api.stripePaymentIntent(
            amount: total,
            email: billingDetails.billingAddress?.emailAddress,
            desc: cartShortDesc,
            shipping: address,
          ));
    });

    if (rsp == null) {
      showToastNotification(context,
          title: trans("Oops!"),
          description: trans("Something went wrong, please try again."),
          icon: Icons.payment,
          style: ToastNotificationStyleType.WARNING);
      state.reloadState(showLoader: false);
      return;
    }

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
      applePay: false,
      googlePay: false,
      style: Theme.of(state.context).brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      testEnv: liveMode,
      merchantCountryCode: envVal('STRIPE_COUNTRY_CODE',
          defaultValue: wooSignalApp!.stripeCountryCode),
      merchantDisplayName:
          envVal('APP_NAME', defaultValue: wooSignalApp.appName),
      paymentIntentClientSecret: rsp['client_secret'],
    ));

    await Stripe.instance.presentPaymentSheet();

    state.reloadState(showLoader: true);

    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);
    Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

    if (order == null) {
      showToastNotification(
        context,
        title: trans("Error"),
        description: trans("Something went wrong, please contact our store"),
      );
      state.reloadState(showLoader: false);
      return;
    }

    Navigator.pushNamed(context, "/checkout-status", arguments: order);
  } on StripeException catch (e) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(e.error.message!);
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: e.error.localizedMessage!,
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    state.reloadState(showLoader: false);
  } catch (ex) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(ex.toString());
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: trans("Something went wrong, please try again."),
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    state.reloadState(showLoader: false);
  }
}
