<p align="center">
  <img width="200" height="125" src="https://woosignal.com/images/woosignal_logo_stripe_blue.png" alt="WooSignal logo">
</p>

# WooCommerce App: Label StoreMax

### Label StoreMax


[Official WooSignal WooCommerce App](https://woosignal.com)

![alt text](https://woosignal.com/images/woocommerce_app_preview_2.png "WooCommerce app checkout experience")

![alt text](https://woosignal.com/images/woocommerce_app_preview_3.png "WooCommerce app Login/Register for customers via WordPress")

![alt text](https://woosignal.com/images/woocommerce_app_preview_1.png "Full integration with WooCommerce")

![alt text](https://woosignal.com/images/mock_dark_light_mode.png "Dark and light mode shopping")

### About Label StoreMax

Label StoreMax is an App Template for WooCommerce stores. Your customers will be able to browse products, make orders and login via WordPress. You can also customise the look and feel of the app in the WooSignal dashboard.

You can also upload the app to the IOS app store and Google play store using Flutter.

### Requirements

- WooCommerce Store 3.5+
- Flutter 3.44+ / Dart 3.12+
- Android Studio/VSCode (for running the app)

Label StoreMax is built on [Nylo](https://nylo.dev) - the framework
documentation is at [nylo.dev/docs/7.x](https://nylo.dev/docs/7.x).

### Getting Started

1. Download/Clone this repository
2. Sign up for free on [WooSignal](https://woosignal.com) and link your WooCommerce store
3. Copy your app key from the WooSignal dashboard into **WOOSIGNAL_APP_KEY** in the **.env** file
4. Build the encrypted environment file:

```bash
dart run nylo_framework:main make:env
```

   This generates `lib/bootstrap/env.g.dart`, which is not committed to git.
   **Re-run this command after every change you make to `.env`**, or the app
   will keep using the previous values.

5. Hit play (with Android Studio) to build the app 🥳

Full documentation this available [here](https://woosignal.com/docs/app/ios/label-storemax)

## Some features integrated

- App Store Ready
- Simple configuration
- Browse products, make orders, customer login (via WordPress)
- Change app name, logo, customize default language, currency + more
- Light and dark mode
- Theme customization
- Stripe, Cash On Delivery and PayPal (RazorPay ships disabled - see `pubspec.yaml`)
- Localized for en, es, pt, it, hi, fr, zh, tr, nl, de, id, th
- Orders show as normal in WooCommerce

## Security Vulnerabilities
If you discover a security vulnerability within WooSignal, please send an e-mail support@woosignal.com

## Uploading to the app stores

- [IOS - Deployment](https://flutter.dev/docs/deployment/ios)
- [Android - Deployment](https://flutter.dev/docs/deployment/android)

## Licence
The Label StoreMax framework is open-sourced software licensed under the MIT license.
