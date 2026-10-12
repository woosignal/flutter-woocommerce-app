## Unreleased

Label StoreMax now runs on **Nylo 7** and requires the **WP JSON API WordPress
plugin 5.0 or later** (`wp_json_api` 5.x). This release contains breaking
changes - read the steps below before upgrading an existing project.

### Breaking - you must do this

* **Update the WP JSON API plugin on your store to 5.0 or later before you
  release this version.** The app now uses `wp_json_api: ^5.0.2`, which talks to
  the plugin's new `wpapp/v4` API (the plugin's security release). With an
  older plugin, customer login, registration and the account pages stop
  working. Get it from
  [woosignal.com](https://woosignal.com/plugins/wordpress/wpapp-json-api).
* **Customers have to log in once after they update the app.** Sessions saved
  by earlier versions can't be used with the v4 API, so they are cleared when
  the app starts. Login sessions now expire (90 days by default, set on your
  store), and one that has expired or been revoked logs the customer out and
  takes them to the login page - their cart is kept.
* **Razorpay has been removed.** The (already disabled) `razorpay_pay.dart`
  provider, the commented-out `RazorPay` entry in `config/payment_gateways.dart`,
  the `razorpay` gateway ids in `bootstrap/data/order_wc.dart`,
  `assets/images/razorpay.png` and `RAZORPAY_API_KEY` in `.env` /
  `.env-example` are gone. Remove `RAZORPAY_API_KEY` from your own `.env` and
  re-run `dart run nylo_framework:main make:env`. A WooSignal app config that
  still reports Razorpay as active is ignored, so it is never offered at
  checkout.
* **Deleting an account now asks for the customer's password**, which the store
  checks before it deletes anything.
* Administrators and shop managers can't log in through the app unless the
  store allows it (WP JSON API filter
  `wpapp_json_api_allow_privileged_users`); they see "This account can't be
  used in the app".

* **Your WooSignal app key moved to `WOOSIGNAL_APP_KEY`.** Nylo 7 reserves
  `APP_KEY` for environment encryption, so `.env` now holds your WooSignal key
  under `WOOSIGNAL_APP_KEY`.
* **New build step: `dart run nylo_framework:main make:env`.** The `.env` file is
  compiled into `lib/bootstrap/env.g.dart` (git-ignored). Run it once after
  adding your key, and again after **every** change to `.env`.
* **`public/` was renamed to `assets/`.** Move any images or JSON you added, and
  update `ASSET_PATH` if you changed it.
* **The `PrimaryButton`, `SecondaryButton`, `LinkButton` and `WooSignalButton`
  widgets are gone.** Use `Button.primary(...)`, `Button.secondary(...)` and
  `Button.textOnly(...)` from `resources/widgets/buttons/buttons.dart`. They take
  `text:`/`onPressed:` instead of `title:`/`action:`, and manage their own
  loading state, so `isLoading:` is no longer needed.
* `openBrowserTab(url: ...)` was replaced by Nylo's `openUrl(...)`.
* `UserAuth` and `navigatorPush()` were removed. The account pages are protected
  by `AuthRouteGuard` (`lib/routes/guards/auth_route_guard.dart`), which sends
  signed-out customers to the login page and returns them to where they were
  going once they sign in.
* The `BuildContext context` constructor field was removed from
  `CheckoutUserDetailsWidget`, `CheckoutPaymentTypeWidget`,
  `CheckoutShippingTypeWidget` and `CheckoutSelectCouponWidget`.
* `WishListPageWidget` is now `WishlistPage`
  (`lib/resources/pages/wishlist_page.dart`). Its `/wishlist` route is unchanged.
* Registration is now a Nylo form (`lib/app/forms/register_form.dart`). New
  passwords must be at least 8 characters with an uppercase letter and a digit,
  matching the login form.

### Fixed

* Category push notifications from the WooSignal dashboard now open the right
  category. They were dropped before, because the handler required an `order_id`
  that a category push never carries.
* `ENCRYPT_SECRET` is read from the environment instead of `ENCRYPT_KEY` being
  read twice, so encrypted app config works again.
* The home screen no longer waits 4 seconds before its first frame.
* Firebase failing to initialize (a store with no `firebase_options.dart` set up)
  no longer takes the whole app down - push notifications are simply disabled
  for that session.
* Push notification listeners moved from `HomePage` to `FirebaseProvider`, so
  they are registered once instead of once per visit to the home screen. An
  order push used to fire its event once for every time home had been opened.
* A mistyped deep link now lands on a not-found page instead of falling through
  to the framework default.
* Placing an order no longer fails when no shipping method has been chosen.
  Whenever the store had shipping enabled, the order builder required a
  shipping method and crashed without one - which a customer could hit if the
  shipping methods could not be loaded, if no method matched their address, or
  if shipping was switched on in the dashboard mid-session. The order is now
  placed with no shipping line, as it already was for stores with shipping
  disabled.
* An order note typed at checkout is no longer kept after the order is placed.
  It was left on the checkout session, so it was pre-filled into the next
  checkout and sent to WooCommerce with the next order.
* A product with no creation date no longer takes down the product grid.
* A product or category whose name is empty no longer throws when its title is
  rendered.
* Chinese: the checkout button read 查看 ("view") instead of 结账.
* Password fields built with `TextEditingRow` (e.g. the delete account
  confirmation) no longer auto-capitalise or suggest words, so the password goes
  in exactly as typed.
* A profile with no first or last name no longer fails to load on the "Update
  details" page.

### Changed

* Upgraded to `nylo_framework: ^7.1.28`; dropped `flutter_dotenv`,
  `pretty_dio_logger` and the direct `url_launcher` dependency.
* Upgraded to `wp_json_api: ^5.0.2` and `woosignal: ^4.5.0`. The temporary
  `device_meta` dependency override is no longer needed and was removed.
* Login, registration and account errors now tell the customer what went wrong
  instead of a generic message: wrong login details, too many attempts (with
  how long to wait), a login blocked by a security plugin on the store
  (showing that plugin's message), registration switched off, email already
  registered, password too short, wrong password, details the store would not
  save, no connection, and an expired session. All 12 languages are updated.
  The mapping lives in `lib/bootstrap/wp_json_api_errors.dart`.
* Logging out now also revokes the login token on the store. The customer is
  always logged out on the device, even if the store can't be reached.
* Registration no longer sends a username; the store creates one from the
  email address.
* An order is only linked to the customer's account while their login session
  is still valid.
* Translation keys added: "Too many attempts, please try again later", "Too
  many attempts, please try again in seconds seconds", "Too many attempts,
  please try again in minutes minutes", "Login is not available right now,
  please try again later", "This account can't be used in the app",
  "Registration is currently disabled for this store", "Password must be at
  least minLength characters", "That username is taken, try another", "Some of
  your details could not be saved, please contact our store", "Unable to
  connect, please check your connection and try again", "Your session has
  expired, please login again" and "Enter your password to confirm". Removed
  (no longer used): "Invalid details", "Please check your email and password",
  "That email does not match our records", "That username does not match our
  records", "A user already exists" and "Username taken, try another."
* Framework files moved to the Nylo 7 layout: `lib/bootstrap/` holds
  `boot`, `decoders`, `events`, `providers` and `theme`; `lib/config/` holds
  `app`, `design`, `localization`, `storage_keys` and `toast_notification`;
  themes live under `resources/themes/{light,dark}/`.
* `MaterialApp` now advertises all 12 shipped locales, and every `lang/*.json`
  carries the framework's own `nylo` translations.
* `test/` now has a working suite - `flutter test` runs a router smoke test that
  proves every registered route still resolves to a page.
* `flutter analyze` is clean: all deprecated API use has been updated.

#### Orders created in WooCommerce look different

The order payload the app sends to WooCommerce was corrected to match the REST
API's order schema. Nothing needs to change on your side, but orders placed by
the app will look different in WooCommerce admin from this release on:

* **`payment_method` is now a real gateway id** - `stripe`, `cod` or
  `paypal` - instead of a label like `Stripe - Android App`. WooCommerce can
  now match the order to the gateway, so gateway-specific refunds and any
  plugin that branches on the payment method work on app orders. Custom
  gateways fall back to their lowercased `name`, so name yours after its
  WooCommerce gateway id.
* **`payment_method_title` is now the readable label plus the platform** -
  e.g. `Stripe (Android App)` - instead of the lowercased gateway name. This
  is the text shown on the order screen and on customer emails and invoices.
* **Cash on Delivery orders are created as `processing` instead of `pending`.**
  This matches what WooCommerce's own COD gateway does at web checkout: stock
  is reduced, the new-order and processing emails go out, and the order is
  ready to fulfil (a `pending` order sends no email, reduces no stock and is
  auto-cancelled by "Hold stock (minutes)"). Prefer to confirm COD orders by
  hand first? Change the status in `lib/bootstrap/data/order_wc.dart` to
  `on-hold`. Paid orders are unchanged: still created as `pending` with
  `set_paid`, which WooCommerce moves on to processing/completed itself.
* **Billing and shipping now send ISO codes, not display names** - `US`/`AL`
  rather than `United States`/`Alabama`. WooCommerce expects codes here, so
  shipping zones, tax rates and address formatting now match app orders the
  same way they match orders placed on the website.
* **The gateway's transaction reference is recorded.** Stripe sends its
  PaymentIntent id and PayPal its sale id in the order's `transaction_id`
  (WooSignal verifies the payment before it marks an app order as paid), and a
  copy is kept in order meta under `_woosignal_payment_ref`. (That key starts
  with an underscore, so it is hidden meta - you will not see it on the order
  screen, but it is readable via the REST API and by plugins.)

## [8.2.7] - 2026-05-23

* Update copyright year
* Dependency updates

## [8.2.6] - 2025-12-13

* Update Android Project config
* Update IOS Project config
* Remove RazorPay dependency
* Dependency updates

## [8.2.4] - 2025-09-06

* Dependency updates

## [8.2.3] - 2025-07-17

* Dependency updates

## [8.2.2] - 2025-05-28

* Upgrade Project
* Dependency updates

## [8.2.1] - 2025-03-27

* Dependency updates

## [8.2.0] - 2025-02-07

* Dependency updates

## [8.1.0] - 2025-01-05

* Update copyright year
* Dependency updates

## [8.0.1] - 2024-12-16

* Add status alerts into the project
* Dependency updates

## [8.0.0] - 2024-12-01

* Update project for Nylo 6.x
* Pubspec.yaml dependency updates

## [7.5.7] - 2024-07-31

* Update order_wc.dart class
* Pubspec.yaml dependency updates

## [7.5.6] - 2024-07-18

* Pubspec.yaml dependency updates 

## [7.5.5] - 2024-06-21

* Update default payment gateways
* Pubspec.yaml dependency updates
 
## [7.5.4] - 2024-06-15

* Pubspec.yaml dependency updates
* Remove pubspec.lock

## [7.5.3] - 2024-05-24

* Pubspec.yaml dependency updates

## [7.5.2] - 2024-05-14

* Pubspec.yaml dependency updates

## [7.5.1] - 2024-05-11

* Pubspec.yaml dependency updates

## [7.4.2] - 2024-05-02

* ErrorStack added to the project
* Pubspec.yaml dependency updates

## [7.4.1] - 2024-04-27

* Pubspec.yaml dependency updates

## [7.4.0] - 2024-04-23

* Ability to add order notes
* Add new translations
* Pubspec.yaml dependency updates

## [7.3.2] - 2024-04-12

* Update env file
* Pubspec.yaml dependency updates

## [7.3.1] - 2024-04-09

* Pubspec.yaml dependency updates

## [7.3.0] - 2024-04-06

* Update Android config
* Pubspec.yaml dependency updates

## [7.2.0] - 2024-04-03

* Update Base ApiService
* Pubspec.yaml dependency updates

## [7.1.0] - 2024-03-31

* Fix PayPal payment issue
* Update Related Products widget
* Update Checkout shipping widget
* Pubspec.yaml dependency updates

## [7.0.2] - 2024-03-28

* Small refactor to project

## [7.0.1] - 2024-03-27

* Pubspec.yaml dependency updates

## [7.0.0] - 2024-03-26

* Refactor project
* New Notifications page
* Pubspec.yaml dependency updates

## [6.15.0] - 2024-03-08

* Increase minimum ios version to 14.0
* Ability to deep link notifications on new products or orders using wp notify
* Ability to order product categories from WooSignal dashboard
* Update android config that fixes https://github.com/nylo-core/nylo/issues/112
* Pubspec.yaml dependency updates

## [6.14.0] - 2024-03-04

* Refactor project
* Add new translations for id and th
* Pubspec.yaml dependency updates

## [6.13.5] - 2024-02-28

* Pubspec.yaml dependency updates

## [6.13.4] - 2024-02-28

* Pubspec.yaml dependency updates

## [6.13.3] - 2024-02-19

* Pubspec.yaml dependency updates

## [6.13.2] - 2024-02-15

* Pubspec.yaml dependency updates

## [6.13.1] - 2024-02-13

* Update .env

## [6.13.0] - 2024-02-12

* Update PayPal integration
* Pubspec.yaml dependency updates
 
## [6.12.7] - 2024-02-11

* Pubspec.yaml dependency updates

## [6.12.6] - 2024-01-28

* Update default themes
* Pubspec.yaml dependency updates

## [6.12.5] - 2023-12-28

* Pubspec.yaml dependency updates

## [6.12.4] - 2023-12-12

* Fix `BrowseCategoryPage`
* Pubspec.yaml dependency updates

## [6.12.3] - 2023-12-09

* Migrate code to Nylo v5.15.0
* Pubspec.yaml dependency updates

## [6.12.2] - 2023-12-02

* Pubspec.yaml dependency updates

## [6.12.1] - 2023-12-01

* Migrate code to Nylo v5.11.1
* Update `CartLineItem` model
* Dart format in /resources/pages
* Pubspec.yaml dependency updates

## [6.12.0] - 2023-10-31

* Update design for Toast Notifications
* Refactor project config for Nylo 5.7.1.
* Update minimum sdk requirements to 3.1.3
* Pubspec.yaml dependency updates

## [6.11.1] - 2023-10-08

* Pubspec.yaml dependency updates

## [6.11.0] - 2023-10-08

* Add `eventBus()` to provider
* Add state managed widget `CartQuantity` and `ProductQuantity`
* Pubspec.yaml dependency updates

## [6.10.4] - 2023-10-05

* Update README

## [6.10.4] - 2023-10-05

* Update IOS directory to include RunnerTests
* Pubspec.yaml dependency updates

## [6.10.2] - 2023-09-22

* Pubspec.yaml dependency updates

## [6.10.1] - 2023-08-28

* Refactor project for Nylo 5.x.
* Fix AndroidManifest splash screen
* Pubspec.yaml dependency updates

## [6.10.0] - 2023-08-21

* Small refactor to project
* Pubspec.yaml dependency updates

## [6.9.0] - 2023-07-13

* Pull firebase config via woosignal api
* New encrypt key and secret added to .env
* fix fetchRelated to return "publish" products
* Pubspec.yaml dependency updates

## [6.8.2] - 2023-07-04

* Update gradle + kotlin versions.
* Pubspec.yaml dependency updates.

## [6.8.1] - 2023-07-03

* Fix auth bug.
* Pubspec.yaml dependency updates.

## [6.8.0] - 2023-07-03

* UI fixes.
* Fix price on coupon page error alerts.
* Fix issue where IOS builds were not using the correct build version.
* Small refactor to the project.
* Pubspec.yaml dependency updates.

## [6.7.0] - 2023-06-20

* Refactor project for Nylo 5.x.
* New Firebase provider for FCM.
* Pubspec.yaml dependency updates.

## [6.6.2] - 2023-06-14

* Page bug fixes
* Pubspec.yaml dependency updates.

## [6.6.1] - 2023-05-28

* Refactor widgets + bug fixes
* Refactor extensions.dart
* Pubspec.yaml dependency updates.

## [6.6.0] - 2023-05-18

* Nylo v5.0.0 migration
* Refactor project
* Flutter v3.10.0 compatibility

## [6.5.1] - 2023-03-04

* New translation added.

## [6.5.0] - 2023-03-04

* When making payments via Stripe, it will now save the card for later.
* Small UI changes to the checkout confirmation page. 
* New translation added.
* Pubspec.yaml dependency updates.

## [6.4.1] - 2023-02-23

* Upgrade to Nylo v4.1.3
* Small refactor to TextStyle
* Fix the ThemeColor.get helper method to support ColorStyles.
* Pubspec.yaml dependency updates

## [6.4.0] - 2023-01-06

* Upgrade to Nylo v4.0.0
* Update copyright
* Refactor wp_json_api metadata
* Pubspec.yaml dependency updates

## [6.3.1] - 2022-11-04

* Fix email address bug in customer_address_input.dart

## [6.3.0] - 2022-11-03

* Ability to add Menu Links to the drawer widget through the WooSignal dashboard
* Fix wording when a shipping zone cannot be found to "Shipping is not supported for your location, sorry"
* Update account shipping widget to be uniform with the checkout shipping widget
* When logged in, the `CheckoutDetailsPage` will now populate shipping info from the users account
* Small refactor to resources/pages
* Pubspec.yaml dependency updates

## [6.2.0] - 2022-09-23

* Migration to use Nylo v3.4.0
* Pubspec.yaml dependency updates
* Increase the minimum targetSdkVersion to 31
* Merge #51, #50, #47, #40, #39 and #38 by @jeanmatthieud
* UI changes to the search page for a nicer experience
* More translations added throughout the app

## [6.1.0] - 2022-07-09

* Add RazorPay
* Null safety tweaks to widgets
* Ability for users to delete their accounts using WP_JSON
* Pubspec.yaml dependency updates

## [6.0.0] - 2022-05-19

* Migrate to Nylo 3.x
* Null safety
* Min dart version 2.17
* Refactor product detail screen
* Pubspec.yaml dependency updates

## [5.8.0] - 2022-03-29

* Add phone number to customer input form
* Gradle version bump
* Pubspec.yaml dependency updates

## [5.7.3] - 2022-02-21

* Fix builds for Flutter 2.10.2
* Fix setState for product upsells
* ext.kotlin_version version bump

## [5.7.2] - 2022-02-12

* Button UI loading state added
* Fix payments on Android for Stripe
* v2 embedding for Android

## [5.7.1] - 2022-02-07

* Refactor account order detail page
* Fix continuous loading if a user has no orders
* New styling for tabs in the account order detail page
* Small refactor to controller loading
* Handle invalid tokens on the account page
* Pubspec.yaml dependency updates

## [5.7.0] - 2022-01-29

* Refactor product detail page
* View HTML in description on the product detail page
* Allow upsell products to be viewed on the Product detail page (if enabled)
* Allow related products to be viewed on the Product detail page (if enabled)
* Allow product reviews to be view on the product page (if enabled)
* Flutter format in /resources
* Pubspec.yaml dependency updates

## [5.6.2] - 2022-01-07

* Fix null return in CheckoutShippingTypeWidget
* Add resizeToAvoidBottomInset: false to notic and compo themes

## [5.6.1] - 2022-01-05

* Fix bug with bottom navigation bar in Notic theme

## [5.6.0] - 2022-01-03

* Fix bug with banner in Mello theme
* Support new languages - Dutch (nl) and Turkish (tr)
* Refactor as per dart analysis
* Ability to add coupons
* Wishlist
* New theme "Compo"
* Analysis options added
* Code cleanup
* Pubspec.yaml dependency updates

## [5.5.2] - 2021-12-18

* Fix continuous loading on categories screen
* Add theme color to buttons
* Code cleanup

## [5.5.1] - 2021-12-18

* Fix bug if store connection fails
* Minify default_shipping.json
* Pubspec.yaml dependency updates

## [5.5.0] - 2021-12-17

* Change font from WooSignal dashboard
* Change font colors from WooSignal dashboard
* Add social media links from WooSignal dashboard
* Notification stubs added to boot.dart
* Upgrade WooSignal API to v3.0.0
* Pubspec.yaml dependency updates

## [5.4.0] - 2021-12-10

* New localization keys added
* Refactor as per Dart Analysis
* Upgrade to latest Nylo version
* Pubspec.yaml dependency updates

## [5.3.1] - 2021-11-17

* Fix shipping method not handling async call
* Update UI for customer_countries page
* Pubspec.yaml dependency updates

## [5.3.0] - 2021-11-02

* Ability to update payment providers via WooSignal Dashboard
* Pubspec.yaml dependency updates

## [5.2.1] - 2021-10-13

* Bug fixes

## [5.2.0] - 2021-10-12

* Migrate to Nylo 2.1.0
* Use flutter_stripe library for payments
* Remove RazorPay for build fails
* Pubspec.yaml dependency updates
* Android compileSdkVersion 30
* Bug fixes

## [5.1.0] - 2021-07-19

* Add support for simplified Chinese locale (zh)
* Add ability to change language from WooSignal dashboard

## [5.0.7] - 2021-07-08

* Pubspec.yaml dependency updates

## [5.0.6] - 2021-07-08

* Refactor project to use Nylo v1.0.0
* Pubspec.yaml dependency updates

## [5.0.5] - 2021-05-03

* Add NSCameraUsageDescription meta to plist for IOS

## [5.0.4] - 2021-04-30

* Fix IOS build failing with Stripe
* Pubspec.yaml dependency updates

## [5.0.3] - 2021-04-27

* Fix issue account page when logged in for Notic theme
* Small tweak to helpers.dart
* Pubspec.yaml dependency updates

## [5.0.2] - 2021-04-17

* Fix issue with PayPal checkout when using different locales
* Fix nested `trans` methods
* PAYPAL_LOCALE added to .env file

## [5.0.1] - 2021-04-13

* Update to app_payment_gateways
* Pubspec.yaml dependency updates

## [5.0.0] - 2021-04-11

* Major release
* Null safety libraries added
* PayPal Payment Gateway Added
* New theme customization
* Fixed Drawer Widget when using Light/Dark mode
* New config file for currency
* Pubspec.yaml dependency updates
* Bug fixes

## [4.0.0] - 2021-03-28

* Major release
* New config structure
* Dark mode added
* Menu drawer added
* Project refactor to use Nylo Framework
* Performance boost
* Bug fixes
* Dart code formatted
* Pubspec.yaml dependency updates

## [3.0.0] - 2021-03-08

* Major release
* Flutter 2.0.0+ support
* Manage app from WooSignal
* Code tidy up
* Bug fixes

## [2.6.0] - 2021-02-24

* Ability to manage affiliate products
* Refreshed design for checkout details screen
* New logic to manage shipping better
* Bug fixes

## [2.5.1] - 2021-02-21

* Pubspec.yaml dependency updates
* Bug fixes

## [2.5.0] - 2020-12-23

* Ability to add image placeholders on products
* Dart code formatted
* Pubspec.yaml dependency updates

## [2.4.1] - 2020-12-20

* Fix subtotal bug on order creation
* Pubspec.yaml dependency updates

## [2.4.0] - 2020-11-19

* Option to disable shipping in config

## [2.3.0] - 2020-11-18

* Option to set if prices include tax
* Pubspec.yaml dependency updates
* Bug fixes

## [2.2.2] - 2020-10-30

* Bug fix for Android build
* Pubspec.yaml dependency updates

## [2.2.1] - 2020-10-22

* Minimum IOS deployment now IOS13
* Pubspec.yaml dependency updates

## [2.2.0] - 2020-10-07

* Flutter 1.22.0 update
* Android MainActivity.kt migration
* Pubspec.yaml dependency updates
* Bug fix for strange "billingAddress" error on checkout
* flutter_application_id.yaml for updating package name and display name of the app in one command
* Minor code format

## [2.1.1] - 2020-07-23

* Bug fix for categories
* Changes to FreeShipping

## [2.1.0] - 2020-07-22

* Pubspec.yaml update for RazorPay
* FreeShipping minimum value feature
* New grid collection layout

## [2.0.9] - 2020-06-19

* New UI for home products
* Added pull to refresh to user orders
* Pubspec.yaml updates
* Flutter v1.17.3 support
* Bug fixes

## [2.0.8] - 2020-06-04

* Added pull to refresh
* Pubspec.yaml updates
* Bug fixes

## [2.0.7] - 2020-05-26

* New default locales added for Spanish, German, French, Hindi, Italian, Portuguese
* Handle managed stock better in product detail
* Removed unused pubspec dependencies
* Pubspec updates
* Bug fixes

## [2.0.6] - 2020-05-17

* New product view
* Improved product sale appearance
* Bug fixes

## [2.0.5] - 2020-05-16

* RazorPay checkout added
* Option to use shipping address
* Config update
* Pubspec.yaml change
* Bug fixes

## [2.0.4] - 2020-05-13

* Added Flexible widget for checkout details
* Bug fixes

## [2.0.3] - 2020-05-12

* New state options for taxes/shipping
* Handle variations better
* Code clean up
* Bug fixes

## [2.0.2] - 2020-05-08

* Flutter 1.17.0 support
* Sort by feature
* Cash on delivery added
* Login/register flow change for Apple user guidelines
* Bug fixes
* Pubspec.yaml update
* AndroidManifest.xml bug fix

## [2.0.1] - 2020-04-30

* Login/register with WordPress
* Updated product view
* New account area
* pubspec.yaml update
* Bug fixes

## [2.0.0] - 2020-04-10

* Flutter v1.12.13+hotfix.9 support
* UI changes
* Xcode 11.4 support
* pubspec.yaml update
* Code Refactor
* Bug fixes

## [1.0.1] - 2020-02-12

* Bug fixes, pubspec.yaml update, rm podfile

## [1.0.0] - 2019-11-01

* Initial Release
