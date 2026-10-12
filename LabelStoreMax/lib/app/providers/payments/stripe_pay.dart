//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/checkout_status_page.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

Future<void> stripePay(BuildContext context, {TaxRate? taxRate}) async {
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
    Map<String, dynamic>? rsp = {};
    //   // CHECKOUT HELPER
    await checkout(taxRate, (total, billingDetails, cart) async {
      String cartShortDesc = await cart.cartShortDesc();

      rsp = await appWooSignal((api) => api.stripePaymentIntentV2(
            amount: total,
            email: billingDetails?.billingAddress?.emailAddress,
            desc: cartShortDesc,
            shipping: billingDetails?.getShippingAddressStripe(),
            customerDetails: billingDetails?.createStripeDetails(),
          ));
    });

    if (rsp == null) {
      if (context.mounted) {
        showToastNotification(context,
            title: trans("Oops!"),
            description: trans("Something went wrong, please try again."),
            id: 'warning');
      }
      stateAction("payment_finished", state: CheckoutConfirmationPage.path);
      return;
    }

    // Nothing has been charged yet, so if the checkout page closed while the
    // payment intent was being created, stop before showing the payment sheet.
    if (!context.mounted) return;

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
          style: Theme.of(context).brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          merchantDisplayName:
              getEnv('APP_NAME', defaultValue: wooSignalApp?.appName),
          customerId: rsp!['customer'],
          paymentIntentClientSecret: rsp!['client_secret'],
          customerEphemeralKeySecret: rsp!['ephemeral_key'],
          setupIntentClientSecret: rsp!['setup_intent_secret']),
    );

    await Stripe.instance.presentPaymentSheet();

    PaymentIntent paymentIntent =
        await Stripe.instance.retrievePaymentIntent(rsp!['client_secret']);

    if (paymentIntent.status == PaymentIntentsStatus.Unknown &&
        context.mounted) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong, please try again."),
        id: 'warning',
      );
    }

    if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
      return;
    }

    stateAction("payment_started", state: CheckoutConfirmationPage.path);

    // The PaymentIntent id is what ties the WooCommerce order back to the
    // charge in Stripe.
    OrderWC orderWC =
        await buildOrderWC(taxRate: taxRate, transactionId: paymentIntent.id);
    Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

    if (order == null) {
      if (context.mounted) {
        showToastNotification(
          context,
          title: trans("Error"),
          description: trans("Something went wrong, please contact our store"),
        );
      }
      stateAction("payment_finished", state: CheckoutConfirmationPage.path);
      return;
    }

    routeTo(CheckoutStatusPage.path,
        navigationType: NavigationType.pushAndForgetAll, data: order);
  } on StripeException catch (e) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(e.error.message!);
    }
    if (context.mounted) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: e.error.localizedMessage!,
        id: 'warning',
      );
    }
    stateAction("payment_finished", state: CheckoutConfirmationPage.path);
  } catch (ex) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(ex.toString());
    }
    if (context.mounted) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong, please try again."),
        id: 'warning',
      );
    }
    stateAction("payment_finished", state: CheckoutConfirmationPage.path);
  }
}
