import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/resources/pages/home_search_page.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/default_shipping.dart';
import 'package:flutter_app/app/models/shipping_type.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/env.g.dart';
import 'package:flutter_app/config/toast_notification.dart';
// Both nylo_support and woosignal export a `CurrencyMeta`; the store's
// currency is the woosignal one.
import 'package:nylo_framework/nylo_framework.dart' hide CurrencyMeta;
import 'package:woosignal/models/response/coupon.dart';
import 'package:woosignal/models/response/order.dart' as ws_order;
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'package:woosignal/models/response/shipping_method.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';

/// Fixtures for the test suite.
///
/// The `woosignal` and `wp_json_api` packages build their own Dio clients, so
/// `NyMockApi` cannot intercept them. Everything they would have returned is
/// built here instead and seeded straight into the singletons the app reads:
/// [AppHelper.instance.appConfig], [Cart.getInstance] and
/// [CheckoutSession.getInstance].

/// A store config that stands in for the one WooSignal serves.
///
/// The defaults describe the most common store: US dollars, WordPress logins
/// on, shipping on, prices excluding tax.
WooSignalApp wooSignalAppFixture({
  String currencyCode = "usd",
  String currencySymbol = "\$",
  int wpLoginEnabled = 1,
  int disableShipping = 0,
  int productPricesIncludeTax = 0,
  bool stripeEnabled = false,
  bool paypalEnabled = false,
  bool codEnabled = false,
  bool wishlistEnabled = true,
  bool couponEnabled = true,
  String theme = "mello",
  String? appLogo = "https://example.test/logo.png",
  String? appName = "Test Store",
}) {
  WooSignalApp wooSignalApp = WooSignalApp();
  wooSignalApp.appName = appName;
  wooSignalApp.appLogo = appLogo;
  wooSignalApp.theme = theme;
  wooSignalApp.themeFont = "Poppins";
  wooSignalApp.bannerImages = [];
  wooSignalApp.wpLoginEnabled = wpLoginEnabled;
  wooSignalApp.wpLoginBaseUrl = "https://example.test";
  wooSignalApp.wpLoginWpApiPath = "wp-json";
  wooSignalApp.disableShipping = disableShipping;
  wooSignalApp.productPricesIncludeTax = productPricesIncludeTax;
  wooSignalApp.stripeEnabled = stripeEnabled;
  wooSignalApp.paypalEnabled = paypalEnabled;
  wooSignalApp.codEnabled = codEnabled;
  wooSignalApp.wishlistEnabled = wishlistEnabled;
  wooSignalApp.couponEnabled = couponEnabled;
  wooSignalApp.showProductReviews = true;
  wooSignalApp.showRelatedProducts = false;
  wooSignalApp.showUpsellProducts = false;
  wooSignalApp.firebaseFcmIsEnabled = false;
  wooSignalApp.menuLinks = [];
  wooSignalApp.currencyMeta = CurrencyMeta(
      symbol: currencySymbol,
      symbolNative: currencySymbol,
      code: currencyCode,
      name: currencyCode.toUpperCase(),
      namePlural: currencyCode.toUpperCase(),
      decimalDigits: 2,
      rounding: 0);
  wooSignalApp.themeColors = {
    'light': {
      'background': '0xFFFFFFFF',
      'primary_text': '0xFF000000',
      'button_background': '0xFF529cda',
      'button_text': '0xFFFFFFFF',
      'app_bar_background': '0xFFFFFFFF',
      'app_bar_text': '0xFF3a3d40',
    },
    'dark': {
      'background': '0xFF212121',
      'primary_text': '0xFFE1E1E1',
      'button_background': '0xFFFFFFFF',
      'button_text': '0xFF232c33',
      'app_bar_background': '0xFF2C2C2C',
      'app_bar_text': '0xFFFFFFFF',
    }
  };
  return wooSignalApp;
}

/// Put a store config where every page reads it from.
WooSignalApp seedAppConfig({WooSignalApp? wooSignalApp}) {
  WooSignalApp config = wooSignalApp ?? wooSignalAppFixture();
  AppHelper.instance.appConfig = config;
  return config;
}

/// A complete WooCommerce product payload.
///
/// `Product.fromJson` reads every list key without a null guard, so the map has
/// to be complete - that is what this builds. Pass [overrides] for the fields a
/// test cares about.
Map<String, dynamic> productJson({Map<String, dynamic> overrides = const {}}) {
  Map<String, dynamic> json = {
    'id': 101,
    'name': "Test Product",
    'slug': "test-product",
    'permalink': "https://example.test/product/test-product",
    'type': "simple",
    'status': "publish",
    'featured': false,
    'catalog_visibility': "visible",
    'description': "<p>A description</p>",
    'short_description': "<p>Short</p>",
    'sku': "SKU-101",
    'price': "10.00",
    'regular_price': "12.00",
    'sale_price': "10.00",
    'price_html': r"<span>$10.00</span>",
    'on_sale': true,
    'purchasable': true,
    'total_sales': 3,
    'virtual': false,
    'downloadable': false,
    'downloads': [],
    'download_limit': -1,
    'download_expiry': -1,
    'external_url': "",
    'button_text': "",
    'tax_status': "taxable",
    'tax_class': "",
    'manage_stock': false,
    'stock_quantity': null,
    'stock_status': "instock",
    'backorders': "no",
    'backorders_allowed': false,
    'backordered': false,
    'sold_individually': false,
    'weight': "1",
    'dimensions': {'length': "1", 'width': "1", 'height': "1"},
    'shipping_required': true,
    'shipping_taxable': true,
    'shipping_class': "",
    'shipping_class_id': 0,
    'reviews_allowed': true,
    'average_rating': "4.50",
    'rating_count': 2,
    'related_ids': <int>[],
    'upsell_ids': <int>[],
    'cross_sell_ids': <int>[],
    'parent_id': 0,
    'purchase_note': "",
    'categories': [
      {'id': 15, 'name': "Clothing", 'slug': "clothing"}
    ],
    'tags': [],
    'images': [
      {
        'id': 1,
        'date_created': "2026-01-01T00:00:00",
        'date_created_gmt': "2026-01-01T00:00:00",
        'date_modified': "2026-01-01T00:00:00",
        'date_modified_gmt': "2026-01-01T00:00:00",
        'src': "https://example.test/image.png",
        'name': "image",
        'alt': ""
      }
    ],
    'attributes': [],
    'default_attributes': [],
    'variations': <int>[],
    'grouped_products': <int>[],
    'menu_order': 0,
    'meta_data': [],
    'date_created': "2026-01-01T00:00:00",
    'date_created_gmt': "2026-01-01T00:00:00",
  };
  json.addAll(overrides);
  return json;
}

/// A product built from [productJson].
ws_product.Product productFixture(
        {Map<String, dynamic> overrides = const {}}) =>
    ws_product.Product.fromJson(productJson(overrides: overrides));

/// A cart line as the app stores it.
CartLineItem cartLineItemFixture({
  String name = "Test Product",
  int productId = 101,
  int? variationId,
  int quantity = 1,
  String subtotal = "10.00",
  String? total,
  String taxStatus = "taxable",
  String stockStatus = "instock",
  bool onSale = false,
  bool isManagedStock = false,
  int? stockQuantity,
  String? variationOptions,
  List<ws_product.Category>? categories,
  List<Map<String?, dynamic>> metaData = const [],
  List<Map<String?, dynamic>> appMetaData = const [],
}) {
  CartLineItem cartLineItem = CartLineItem(
    name: name,
    productId: productId,
    variationId: variationId,
    quantity: quantity,
    subtotal: subtotal,
    total: total ?? subtotal,
    taxStatus: taxStatus,
    stockStatus: stockStatus,
    onSale: onSale,
    isManagedStock: isManagedStock,
    stockQuantity: stockQuantity,
    variationOptions: variationOptions,
    shippingClassId: "0",
    taxClass: "",
    shippingIsTaxable: true,
    imageSrc: "https://example.test/image.png",
    salePrice: "10.00",
    regularPrice: "12.00",
    categories:
        categories ?? [ws_product.Category(15, "Clothing", "clothing")],
  );
  cartLineItem.metaData = List.of(metaData);
  cartLineItem.appMetaData = List.of(appMetaData);
  return cartLineItem;
}

/// Write [cartLineItems] into the cart the app reads from storage.
Future<void> seedCart(List<CartLineItem> cartLineItems) async {
  await Cart.getInstance.saveCartToPref(cartLineItems: cartLineItems);
}

/// Empty the cart.
Future<void> clearCart() async => await Cart.getInstance.clear();

/// A customer address. [stateCode] follows WooCommerce's `<country>:<state>`
/// form, which is what the app has to strip down for the order payload.
CustomerAddress customerAddressFixture({
  String firstName = "Anthony",
  String lastName = "Gordon",
  String addressLine = "1 Test Street",
  String city = "Birmingham",
  String postalCode = "AL1 1AA",
  String emailAddress = "test@example.test",
  String phoneNumber = "07000000000",
  String countryCode = "US",
  String countryName = "United States",
  String? stateCode = "US:AL",
  String? stateName = "Alabama",
}) {
  return CustomerAddress(
    firstName: firstName,
    lastName: lastName,
    addressLine: addressLine,
    city: city,
    postalCode: postalCode,
    emailAddress: emailAddress,
    phoneNumber: phoneNumber,
    customerCountry: CustomerCountry(
      countryCode: countryCode,
      name: countryName,
      state: stateCode == null
          ? null
          : DefaultShippingState(code: stateCode, name: stateName),
    ),
  );
}

/// A shipping type backed by a flat rate method.
ShippingType flatRateShippingFixture(
        {String cost = "5.00", bool taxable = true, String title = "Flat rate"}) =>
    ShippingType(
      methodId: "flat_rate",
      cost: cost,
      minimumValue: null,
      object: FlatRate(
          id: 1,
          title: title,
          methodId: "flat_rate",
          cost: cost,
          taxable: taxable,
          shippingClasses: []),
    );

/// A shipping type backed by a local pickup method.
ShippingType localPickupShippingFixture(
        {String cost = "2.00", bool taxable = false}) =>
    ShippingType(
      methodId: "local_pickup",
      cost: cost,
      minimumValue: null,
      object: LocalPickup(
          id: 2,
          title: "Local pickup",
          methodId: "local_pickup",
          taxable: taxable,
          cost: cost),
    );

/// A shipping type backed by a free shipping method.
ShippingType freeShippingFixture() => ShippingType(
      methodId: "free_shipping",
      cost: "0",
      minimumValue: null,
      object: FreeShipping(
          id: 3,
          title: "Free shipping",
          methodId: "free_shipping",
          cost: "0",
          minimumOrderAmount: "0"),
    );

/// A coupon with every list field populated, because the coupon rules read
/// them all without a null guard.
Coupon couponFixture({
  String code = "SAVE10",
  String discountType = "percent",
  String amount = "10",
  String minimumAmount = "0",
  String maximumAmount = "0",
  String? dateExpires,
  int usageCount = 0,
  int? usageLimit,
  int? usageLimitPerUser,
  List<int> productIds = const [],
  List<int> excludedProductIds = const [],
  List<int> productCategories = const [],
  List<int> excludedProductCategories = const [],
  bool excludeSaleItems = false,
  List<String> emailRestrictions = const [],
  List<String> usedBy = const [],
}) {
  return Coupon(
    id: 1,
    code: code,
    amount: amount,
    discountType: discountType,
    description: "",
    dateExpires: dateExpires,
    usageCount: usageCount,
    individualUse: false,
    productIds: List.of(productIds),
    excludedProductIds: List.of(excludedProductIds),
    usageLimit: usageLimit,
    usageLimitPerUser: usageLimitPerUser,
    limitUsageToXItems: null,
    freeShipping: false,
    productCategories: List.of(productCategories),
    excludedProductCategories: List.of(excludedProductCategories),
    excludeSaleItems: excludeSaleItems,
    minimumAmount: minimumAmount,
    maximumAmount: maximumAmount,
    emailRestrictions: List.of(emailRestrictions),
    usedBy: List.of(usedBy),
    metaData: [],
  );
}

/// A tax rate.
TaxRate taxRateFixture({
  String rate = "20.0000",
  String name = "VAT",
  String country = "US",
  String state = "AL",
  bool shipping = true,
}) =>
    TaxRate(
        id: 1,
        country: country,
        state: state,
        postcode: "",
        city: "",
        rate: rate,
        name: name,
        priority: 1,
        compound: false,
        shipping: shipping,
        order: 1,
        taxClass: "");

/// Record every toast the app shows so [expectToastShown] can see it.
///
/// The framework only records toasts something feeds it, so this wraps each of
/// the app's own toast styles with a recorder and hands back the real widget -
/// the toast still renders, and the assertion sees the id, title and
/// description the call site used.
void recordToasts() {
  NyToastRecorder.setup();
  ToastNotificationConfig.styles.forEach((String id, dynamic factory) {
    ToastNotificationRegistry.instance.register(id,
        (ToastMeta meta, void Function(ToastMeta) update) {
      NyToastRecorder.record(
          id: id, title: meta.title, description: meta.description);
      return (factory as ToastStyleFactory)(meta, update);
    });
  });
}

/// Let a toast live out its five seconds and animate away.
///
/// A toast schedules a dismiss timer, and `flutter_test` fails a test whose
/// widget tree is torn down with a timer still pending. Call this at the end
/// of any test that shows one.
Future<void> settleToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettleGracefully(timeout: const Duration(seconds: 2));
}

/// Pump a widget whose `init` reaches the WooCommerce or WordPress SDK.
///
/// Those clients cast their response body without a null guard, so a request
/// that cannot reach the store throws a `TypeError` - an Error, not an
/// Exception, so the `on Exception` guard Nylo wraps `init` in does not catch
/// it and it surfaces as an unhandled zone error that fails the test outright.
/// Catching it here is the test-side equivalent of the page falling back to its
/// empty state, which is what these tests are about. Returns whatever was
/// caught, so a test can assert on it.
Future<List<Object>> pumpOffline(WidgetTester tester, Widget widget) async {
  List<Object> unreachable = [];
  await runZonedGuarded(() async {
    await tester.pumpNyWidgetSimple(widget);
  }, (Object error, StackTrace stack) => unreachable.add(error));
  // The error cuts the pump chain short, so finish the frames out here.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettleGracefully(timeout: const Duration(seconds: 2));
  return unreachable;
}

/// Pump a minimal app wired to the real router.
///
/// The push notification events navigate with `routeTo`, which needs a live
/// navigator, so without this they run into nothing and there is nothing to
/// assert. The search page is the starting point because it has no `init` and
/// reaches nothing.
Future<List<Object>> pumpAppRouter(WidgetTester tester) async {
  List<Object> unreachable = [];
  await runZonedGuarded(() async {
    Nylo nylo = Backpack.instance.nylo();
    await tester.pumpWidget(MaterialApp(
      theme: NyWidgetTest.simpleTestTheme,
      navigatorKey: NyNavigator.instance.router.navigatorKey,
      onGenerateRoute: nylo.router!.generator(),
      onUnknownRoute: nylo.router!.unknownRoute(),
      navigatorObservers: nylo.getNavigatorObservers(),
      initialRoute: HomeSearchPage.path.name,
    ));
    await tester.pump();
  }, (Object error, StackTrace stack) => unreachable.add(error));
  return unreachable;
}

/// Pump [widget], holding back framework assertions whose message contains
/// [ignoring], and report how many were held back.
///
/// For a known, recorded defect that raises a debug-only assertion: anything
/// else still fails the test.
Future<int> pumpIgnoringAssertion(
    WidgetTester tester, Widget widget, String ignoring) async {
  int held = 0;
  void Function(FlutterErrorDetails)? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains(ignoring)) {
      held += 1;
      return;
    }
    previous?.call(details);
  };
  try {
    await tester.pumpNyWidgetSimple(widget);
    await tester.pump(const Duration(milliseconds: 300));
  } finally {
    FlutterError.onError = previous;
  }
  return held;
}

/// Fire something that ends by navigating, then let the app settle.
///
/// `routeTo` and `routeToInitial` hand back the pushed route's result, which
/// only arrives when that page is popped - so awaiting an event whose listener
/// navigates would hang for ever.
Future<List<Object>> fireAndSettle(
    WidgetTester tester, Future<void> Function() fire) async {
  List<Object> unreachable = [];
  await runZonedGuarded(() async {
    unawaited(fire());
  }, (Object error, StackTrace stack) => unreachable.add(error));
  unreachable.addAll(await settleOffline(tester));
  return unreachable;
}

/// Navigate to [route] the way the app does, and let the page settle.
///
/// [pumpAppRouter] has to have run first. Returns whatever the arriving page
/// ran into with no network.
Future<List<Object>> visitRoute(WidgetTester tester, RouteView route,
    {dynamic data}) async {
  List<Object> unreachable = [];
  await runZonedGuarded(() async {
    // Deliberately not awaited: `routeTo` hands back the pushed route's
    // result, which only arrives when the page is popped.
    unawaited(routeTo(route, data: data));
  }, (Object error, StackTrace stack) => unreachable.add(error));
  unreachable.addAll(await settleOffline(tester));
  return unreachable;
}

/// A completed WooCommerce order, as the checkout status page receives it.
ws_order.Order orderFixture(
        {int id = 900,
        String status = "processing",
        String total = "25.00",
        String currency = "USD"}) =>
    ws_order.Order.fromJson({
      'id': id,
      'number': "$id",
      'status': status,
      'currency': currency,
      'total': total,
      'date_created': "2026-01-01T00:00:00",
      'customer_note': "",
      'payment_method': "stripe",
      'payment_method_title': "Stripe (iOS App)",
      'billing': {'first_name': "Anthony", 'last_name': "Gordon"},
      'shipping': {'first_name': "Anthony", 'last_name': "Gordon"},
      'line_items': [
        {
          'id': 1,
          'name': "Test Product",
          'product_id': 101,
          'quantity': 1,
          'subtotal': "10.00",
          'total': "10.00",
          'price': "10.00",
          // `LineItems.fromJson` casts both of these without a null guard.
          'taxes': [],
          'meta_data': [],
        }
      ],
    });

/// Pump frames after a navigation, absorbing what the arriving page runs into
/// with no network. See [pumpOffline] for why that is necessary.
Future<List<Object>> settleOffline(WidgetTester tester) async {
  List<Object> unreachable = [];
  await runZonedGuarded(() async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettleGracefully(timeout: const Duration(seconds: 2));
  }, (Object error, StackTrace stack) => unreachable.add(error));
  return unreachable;
}

/// Run [body] with some env values replaced.
///
/// `env.g.dart` is generated from `.env` and encrypted, so a test cannot edit
/// it. Swapping the getter Nylo reads through is the supported way in - it is
/// the same call `main.dart` makes - and the real getter is put back afterwards
/// however [body] ends.
Future<T> withEnv<T>(
    Map<String, dynamic> overrides, Future<T> Function() body) async {
  NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) =>
          overrides.containsKey(key)
              ? overrides[key]
              : Env.get(key, defaultValue: defaultValue));
  try {
    return await body();
  } finally {
    NyEnvRegistry.register(getter: Env.get);
  }
}

/// Sign a WordPress user in for the duration of a test.
///
/// `WPJsonAPI.instance.init` only runs when the store config says WordPress
/// logins are on, and that config never arrives in a test, so the package
/// keeps the session in secure storage - which `NyMockChannels` backs with an
/// in-memory map. Writing through [WPJsonAPI.wpLogin] uses the same path the
/// app does.
///
/// wp_json_api 5 tokens always expire, so the session is valid for a day
/// unless [expiresAt] (Unix seconds) says otherwise. Pass [legacySession] to
/// store a session the way wp_json_api 4.x did - with no expiry - which 5.x
/// treats as logged out.
Future<WpUser> seedWpUser(
    {int id = 42,
    String token = "test-token",
    String email = "test@example.test",
    String firstName = "Anthony",
    String lastName = "Gordon",
    int? expiresAt,
    bool legacySession = false}) async {
  WpUser wpUser = WpUser(
      id: id,
      token: token,
      expiresAt: legacySession
          ? null
          : expiresAt ??
              DateTime.now()
                      .add(const Duration(days: 1))
                      .millisecondsSinceEpoch ~/
                  1000,
      email: email,
      username: email,
      firstName: firstName,
      lastName: lastName);
  await WPJsonAPI.wpLogin(wpUser);
  return wpUser;
}

/// Sign the WordPress user out again.
Future<void> clearWpUser() async => await WPJsonAPI.wpLogout();

/// Put the checkout session back to the state a fresh app has.
///
/// [CheckoutSession] is a singleton with mutable fields, so a test that leaves
/// a coupon or a shipping type on it changes the next test's answer.
void resetCheckoutSession() {
  CheckoutSession checkoutSession = CheckoutSession.getInstance;
  checkoutSession.clear();
  checkoutSession.customerNote = null;
  checkoutSession.shipToDifferentAddress = false;
}

/// A checkout session ready to build an order from: billing and shipping
/// addresses, a shipping type and a payment type name.
void seedCheckoutSession({
  CustomerAddress? billingAddress,
  CustomerAddress? shippingAddress,
  ShippingType? shippingType,
  Coupon? coupon,
  String? customerNote,
}) {
  CheckoutSession checkoutSession = CheckoutSession.getInstance;
  checkoutSession.initSession();
  checkoutSession.billingDetails!.billingAddress =
      billingAddress ?? customerAddressFixture();
  checkoutSession.billingDetails!.shippingAddress =
      shippingAddress ?? billingAddress ?? customerAddressFixture();
  checkoutSession.shippingType = shippingType ?? flatRateShippingFixture();
  checkoutSession.coupon = coupon;
  checkoutSession.customerNote = customerNote;
}
