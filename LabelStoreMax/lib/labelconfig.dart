//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

/*
 Developer Notes

 SUPPORT EMAIL - support@woosignal.com
 VERSION - 2.0.1
 https://woosignal.com
 */

/*<! ------ CONFIG ------!>*/

const app_name = "MyApp";

const app_key = "your app key";
// Your App key from WooSignal
// link: https://woosignal.com/dashboard/apps

const app_logo_url = "https://is5-ssl.mzstatic.com/image/thumb/Purple115/v4/4b/e8/9a/4be89a5a-607e-1fb3-c45a-3261e84a061b/source/512x512bb.jpg";

const app_terms_url = "https://yourdomain.com/terms";
const app_privacy_url = "https://yourdomain.com/privacy";

/*<! ------ WP LOGIN (OPTIONAL) ------!>*/

// Allows customers to login/register, view account, purchase items as a user.
// #1 Install the "WP JSON API" plugin on WordPress via https://woosignal.com/plugins/wordpress/wpapp-json-api
// #2 Next activate the plugin on your WordPress and enable "use_wp_login = true"
// link: https://woosignal.com/dashboard/plugins

const use_wp_login = false;
const app_base_url = "https://mysite.com"; // change to your url
const app_forgot_password_url = "https://mysite.com/my-account/lost-password"; // change to your forgot password url
const app_wp_api_path = "/wp-json"; // By default "/wp-json" should work

/*<! ------ STRIPE (OPTIONAL) ------!>*/

// Your StripeAccount key from WooSignal
// link: https://woosignal.com/dashboard

const app_stripe_account = "Stripe Key from WooSignal";

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
