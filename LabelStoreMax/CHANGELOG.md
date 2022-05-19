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
