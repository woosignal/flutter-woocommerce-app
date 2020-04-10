//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

/*
 Developer Notes

 SUPPORT EMAIL - support@woosignal.com
 VERSION - 2.0
 https://woosignal.com
 */

/*<! ------ CONFIG ------!>*/

const app_name = "MyApp";

const app_key = "Your App Key";
// Your App key from WooSignal
// link: https://woosignal.com/dashboard/apps

const app_logo_url = "https://woosignal.com/images/120x120_woosignal.png";

const app_terms_url = "https://yourdomain.com/terms";
const app_privacy_url = "https://yourdomain.com/privacy";

/*<! ------ STRIPE (OPTIONAL) ------!>*/

const app_stripe_account = "Your Stripe Key";
// Your StripeAccount key from WooSignal
// link: https://woosignal.com/dashboard

const app_stripe_live_mode = false;
// For Live Payments follow the below steps
// #1 SET the above to true for live payments
// #2 Next visit https://woosignal.com/dashboard
// #3 Then change "Environment for Stripe" to Live mode

/*<! ------ APP CURRENCY ------!>*/

const app_currency_symbol = "\£";
const app_currency_iso = "gbp";
const app_locales_supported = ['en'];

const app_payment_methods = ["Stripe"];

/*<! ------ DEBUGGER ENABLED ------!>*/

const app_debug = true;
