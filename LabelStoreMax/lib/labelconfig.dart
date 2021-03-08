//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:ui';

/*
 Developer Notes

 SUPPORT EMAIL - support@woosignal.com
 VERSION - 3.0.0
 https://woosignal.com
 */

/*<! ------ CONFIG ------!>*/

const app_name = "MyApp";

const app_key = "Your app key from WooSignal";

// Your App key from WooSignal
// link: https://woosignal.com/dashboard/apps

/*<! ------ APP SETTINGS ------!>*/

const Locale app_locale = Locale('en');

const List<Locale> app_locales_supported = [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hi'),
  Locale('it'),
  Locale('pt'),
];
// If you want to localize the app, add the locale above
// then create a new lang json file using keys from en.json
// e.g. lang/es.json

const app_product_placeholder_image =
    "https://woosignal.com/images/woocommerce-placeholder.png";

/*<! ------ PAYMENT GATEWAYS ------!>*/

// Available: "Stripe", "CashOnDelivery", "RazorPay"
// Add the method to the array below e.g. ["Stripe", "CashOnDelivery"]

const app_payment_methods = ["Stripe"];

/*<! ------ STRIPE (OPTIONAL) ------!>*/

// Your StripeAccount key from WooSignal
// link: https://woosignal.com/dashboard

const app_stripe_account = "Your Stripe Key from WooSignal";

const app_stripe_live_mode = false; // set to true for live Stripe payments
// For Live Payments follow the below steps
// #1 SET the above to true for live payments
// #2 Next visit https://woosignal.com/dashboard
// #3 Then change "Environment for Stripe" to Live mode

/*<! ------ Razor Pay (OPTIONAL) ------!>*/
// https://razorpay.com/

const app_razor_id = "Your Razor ID from RazorPay";

/*<! ------ DEBUGGER ENABLED ------!>*/

const app_debug = true;
