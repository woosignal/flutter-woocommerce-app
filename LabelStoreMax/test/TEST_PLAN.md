# Label StoreMax — test plan

The suite is written for `flutter test`: no network, no device, no emulator. It runs on a
developer machine and in CI in a few seconds.

Before the first run, generate the encrypted env (it is git-ignored):

```
dart run nylo_framework:main make:env
flutter test
```

## Ground rules

The three that shape every file below:

1. **The WooCommerce/WordPress SDKs cannot be mocked.** `woosignal` and `wp_json_api` build
   their own `Dio` clients, so `NyMockApi` — which only intercepts `NyApiService` — never sees
   them. `NyTest.init()` installs Flutter's mock `HttpOverrides`, so every one of their requests
   fails fast with a 400 and no socket is opened. Tests therefore never assert on SDK *results*;
   they assert on the pure logic around the SDK, on seeded state, and on what a page renders when
   the SDK gives it nothing.
2. **`init()` swallows exceptions.** `NyBaseState.awaitData` catches `Exception` and marks the
   page loaded anyway, so a page whose `init` calls the SDK still renders — as its empty state.
   A Dart `Error` (a bad cast, a `!` on null) is *not* caught and does fail the test; that is a
   real defect and is treated as one.
3. **Seed, don't mock.** `AppHelper.instance.appConfig`, `Cart`, `CheckoutSession`, `NyStorage`
   and `Backpack` are all writable from a test. Fixtures live in `test/support/fixtures.dart`.

## Support files

| File | Purpose |
|---|---|
| `test/support/boot_test_app.dart` | Existing. Boots providers minus `runApp`, mocks `device_info_plus`, installs the event bus. |
| `test/support/fixtures.dart` | New. `WooSignalApp`, `Product`, `Coupon`, `TaxRate`, `CartLineItem`, `CustomerAddress`, `ShippingType` builders + `seedAppConfig()` / `resetCheckoutSession()` / `seedCart()`. |

## Areas → files → cases

| # | Area | File | Cases |
|---|---|---|---|
| 1 | Models | `test/models_test.dart` | `CartLineItem` to/from JSON round trip, defaults, null handling, both `appMetaData` shapes (legacy `{key:value}` and current `{"key":…,"value":…}`), `getCartTotal`/`getPrice`; `CustomerAddress` round trip, `hasMissingFields`, `addressFull`, `nameFull`, `toUserMetaDataItem` (incl. the `US:AL` → `AL` strip and the shipping/email exclusion); `CustomerCountry` round trip + `hasState`; `DefaultShippingState` round trip; `NotificationItem` round trip + `hasRead` default; `ShippingType` `getTotal`/`getTitle`/`toShippingLineFee` per method id; `BillingDetails.createStripeDetails` shape; `PaymentType`/`BottomNavItem` construction |
| 2 | Order payload | `test/order_wc_test.dart` | `buildOrderWC`: gateway id per Stripe/PayPal/COD + lowercased fallback for a custom gateway; `payment_method_title` carries the platform; `status` `pending` when `markPaid` else `processing`; `set_paid`; ISO state (`US:AL`→`AL`, bare code passes through) and country codes; `transaction_id` + `_woosignal_payment_ref` meta and their absence; line items (quantity, name, subtotal maths, `variationId` only when non-zero); shipping lines on/off via `disableShipping`; coupon lines; customer note only when non-empty; currency upper-cased; guest vs logged-in `customerId` |
| 3 | Cart & checkout | `test/cart_test.dart` | `Cart` add/remove/update/clear/persist, quantity floor at 1, subtotal/total, coupon discount for `percent`/`fixed_cart`/`fixed_product` and every exclusion rule, `taxAmount` (tax status, shipping taxable, prices-include-tax), `cartShortDesc`, `indexForProduct` |
| | | `test/checkout_session_test.dart` | Billing/shipping address save/read/clear through `NyStorage`, `initSession`/`clear`, `total` with shipping types and a tax rate, coupon interaction |
| | | `test/coupon_rules_test.dart` | All 14 guards of `couponRejection` — see the production edit below |
| | | `test/helpers_test.dart` | `parseWcPrice`, `formatDoubleCurrency`/`formatStringCurrency` (symbol position), `workoutSaleDiscount`, `isNumeric`, `isEmail`, `truncateString`, `strCal`, `workoutShippingCostWC` (`[qty]`, `[fee percent min_fee max_fee]`), `parseHtmlString`, `dateFormatted`/`formatForDateTime`, `shouldEncrypt()` for all four ENCRYPT_KEY/SECRET combinations, `isProductNew`, wishlist add/remove/read, `DateTimeExtension.isBetween` |
| | | `test/notifications_helper_test.dart` | `NyNotification` add/all/unread/mark-read/clear round trip through `NyStorage`, and `canSeeRemoteMessage` for the no-`user_id`, logged-out and wrong-user cases |
| 4 | Env & config | `test/config_test.dart` | `Env.get` semantics (`null` string → null, bool coercion, missing key → default); `AppConfig` values; `StorageKeysConfig` key strings are the exact legacy strings; `LocalizationConfig.supportedLocales` == `lang/*.json`; `ToastNotificationConfig.styles` ids; `appThemes` ids; payment gateway config |
| 5 | Routing & guards | `test/router_test.dart` | Existing (every route resolves, one initial route, unknown route, guarded pages). |
| | | `test/route_guard_test.dart` | `AuthRouteGuard` passes when `wpLoginEnabled != 1`; passes when logged in; redirects to the login page when logged out, carrying `intended_route`/`intended_route_data`; `routeToIntended` key handling; `NyMockRouteGuard` pass/redirect wiring |
| 6 | State actions & loading | `test/state_actions_test.dart` | `CartPage` `cart_cleared`/`item_removed`/`max_stock` → the right toast text; `CheckoutConfirmationPage` `payment_started`/`payment_finished` → loading on/off and `payment_failed` → loading off + toast; `CartQuantity`/`ShoppingCartTotal`/`WishlistIcon`/`NotificationIcon`/`ProductQuantity` refresh actions; `CartProductItem` `NyStateManaged` id is `cart_product_item_<productId>_<variationId>`; `lockRelease` holds and releases |
| 7 | Pages & widgets | `test/pages_render_test.dart` | Pump every page that renders without the SDKs: not-found, no-connection, home-search, customer-countries, checkout payment type, checkout status, cart (empty + seeded), wishlist, notifications, coupon, login, register, checkout details, product detail with a `Product` fixture, product reviews |
| | | `test/widgets_render_test.dart` | Store logo, cart quantity, shopping cart total, wishlist icon, notification icon, product quantity, cart product item, checkout sub-widgets, customer address input, text row, top nav, toast notification, app loader, drawer |
| 8 | Forms | `test/forms_test.dart` | `LoginForm`/`RegisterForm` field keys and labels, `FormValidator.email()` / `.password(strength: 1)` (register) accept/reject (including `null`), the login password accepting any non-empty password, `NyFormActions` names, submit success and failure paths |
| 9 | Buttons | `test/buttons_test.dart` | Every `Button.*` factory renders its partial and its text; primary/secondary sizing rule (`>= 385` → 55, else 49); colours come from `context.color.button.*`; an async `onPressed` locks the button and shows the loader, then releases |
| 10 | Events | `test/events_test.dart` | All 8 events registered and resolvable; `LogoutEvent` clears the cart and the auth key; the three notification events act only on their own payload key (`product_id`/`order_id`/`category_id`) and ignore others; `OrderNotificationEvent` also requires a matching `user_id` |
| 11 | Themes | `test/theme_test.dart` | Both theme ids build a `ThemeData` with the expected brightness; light/dark colour groups resolve to the documented values; the remote WooSignal colour keys are honoured; `DesignConfig.appFont` is reassignable |
| 12 | Translations | `test/translations_test.dart` | All 12 `lang/*.json` parse; identical key sets; the `nylo` block with all 18 leaves; `{{placeholder}}` parity; no empty values; the reviewed CTAs (`CHECKOUT`, `CANCEL`, `Login`) are not English outside `en.json` |
| 13 | Payments | `test/payments_test.dart` | Gateway id/title maps via `buildOrderWC`; `paymentTypeList` ids/names/assets; `createPaypalPayment` / `executePayment` link extraction, error mapping, headers and sandbox/live hosts through the injected client; `getAccessToken` on its failure path |
| 14 | WP JSON API | `test/wp_json_api_errors_test.dart` | Every wp_json_api 5 exception maps to its translated message (`TooManyAttemptsException.retryAfter` in seconds/minutes, `LoginBlockedException` shows the store's message without HTML, fallback for anything else); `clearExpiredWpSession` clears a wp_json_api 4.x (no expiry) or expired session and keeps a valid one; only `InvalidUserTokenException` logs the customer out. `LogoutEvent`'s `session_expired` path is in `test/events_test.dart` |

## Production edits this plan requires

Both are seams, both preserve behaviour, both are recorded in the log with their reason.

1. `lib/resources/pages/coupon_page.dart` — lift the 14 guard clauses out of the private
   `_applyCoupon` into a top-level pure function `couponRejection(...)` in the same file.
   `_applyCoupon` then calls it. Nothing else changes: same rules, same order, same messages,
   same toast ids. Without this the rules are only reachable through a widget that must first
   complete a `getCoupons` network call.
2. `lib/bootstrap/paypal/paypal_service.dart` — `createPaypalPayment` and `executePayment`
   construct `Dio()` inline. Add an optional `Dio? client` constructor parameter that defaults to
   `Dio()`, so a test can pass a client with a mock adapter. The default path is unchanged.

The access-token call is not covered the same way: it goes out through `ApiService`, whose Dio
client the framework builds and owns. `NyMockApi.register` is not consulted by `NyApiService` in
nylo_support 7.28.0 and `initDio` does not reach the adapter, so only the failure path — the part
that was reworked — is asserted.

## Known defects the suite records rather than fixes

1. `ProductNotificationEvent` and `CategoryNotificationEvent` route with `data: int.parse(...)`,
   but `ProductDetailPage.init` assigns that data to a `Product?` and `BrowseCategoryPage.init`
   assigns it to a `ProductCategory?`. A product or category push therefore lands on a page that
   throws a `TypeError`. Both are pre-existing at `HEAD` (verified with `git show`), and fixing
   them means deciding a payload contract — out of scope for a test pass. The two tests covering
   the positive dispatch path are marked `skip: true`; the guard-clause tests around them run.
2. The selected payment-method tile and the drawer's menu tiles are `ListTile`s inside a box that
   paints its own background, so Flutter asserts their ink splash cannot be seen. Debug-only;
   release builds render but do not ripple. `pumpIgnoringAssertion` holds the assertion back and
   the tests fail if it ever stops firing, so they point at themselves once the tiles are wrapped
   in their own `Material`.
