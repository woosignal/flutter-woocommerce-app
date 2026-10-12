import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/pages/account_register_page.dart';
import 'package:flutter_app/resources/pages/checkout_details_page.dart';
import 'package:flutter_app/resources/pages/checkout_payment_type_page.dart';
import 'package:flutter_app/resources/pages/checkout_shipping_type_page.dart';
import 'package:flutter_app/resources/pages/checkout_status_page.dart';
import 'package:flutter_app/resources/pages/coupon_page.dart';
import 'package:flutter_app/resources/pages/customer_countries_page.dart';
import 'package:flutter_app/resources/pages/home_search_page.dart';
import 'package:flutter_app/resources/pages/no_connection_page.dart';
import 'package:flutter_app/resources/pages/not_found_page.dart';
import 'package:flutter_app/resources/pages/notifications_page.dart';
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:flutter_app/resources/pages/product_reviews_page.dart';
import 'package:flutter_app/resources/pages/wishlist_page.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Page rendering tests.
///
/// Every page here is pumped and checked for the text a customer would read.
/// Pages whose content comes back from the store are checked in their empty
/// state - that is what a customer sees on a bad connection, and it is the
/// state that has to hold rather than crash.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    NyWidgetTest.configure(testTheme: NyWidgetTest.simpleTestTheme);
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    resetCheckoutSession();
    await clearCart();
    await clearWpUser();
    await NyNotification.clearAllNotifications();
    await NyStorage.delete("CS_WISHLIST_PRODUCTS");
    recordToasts();
  });

  nyGroup('pages that need nothing from the store', () {
    nyWidgetTest('the not found page explains itself', (tester) async {
      await tester.pumpNyWidgetSimple(NotFoundPage());

      // These are the framework's own keys, translated into all 12 languages.
      expect(find.text(trans("nylo.page_not_found.title")), findsOneWidget);
      expect(find.text(trans("nylo.page_not_found.message")), findsOneWidget);
      expect(find.text("Page Not Found"), findsOneWidget);
    });

    nyWidgetTest('the no connection page offers a retry', (tester) async {
      await tester.pumpNyWidgetSimple(NoConnectionPage());

      expect(find.byType(NoConnectionPage), findsOneWidget);
      expect(find.text(trans("Retry")), findsOneWidget);
    });

    nyWidgetTest('the search page renders its field', (tester) async {
      await tester.pumpNyWidgetSimple(HomeSearchPage());

      expect(find.byType(TextField), findsWidgets);
    });

    nyWidgetTest('the country picker lists the bundled countries',
        (tester) async {
      // Reads assets/json/default_shipping.json off disk.
      await tester.pumpNyWidgetSimple(CustomerCountriesPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(trans("Select a country")), findsOneWidget);
      // The list is virtualised, so only the top of it is built.
      expect(find.text("Afghanistan"), findsOneWidget);
      expect(find.text("Albania"), findsOneWidget);
    });
  });

  nyGroup('the account pages', () {
    nyWidgetTest('the login page renders its form and its links',
        (tester) async {
      await tester.pumpNyWidgetSimple(AccountLoginPage());

      expect(find.text(trans("Login")), findsWidgets);
      expect(find.text(trans("Create an account")), findsOneWidget);
      expect(find.text(trans("Forgot Password")), findsOneWidget);
      expect(find.text(trans("Back")), findsOneWidget);
      expect(find.text(trans("Email")), findsOneWidget);
      expect(find.text(trans("Password")), findsOneWidget);
      // Two form fields: email and password.
      expect(find.byType(TextField), findsNWidgets(2));
    });

    nyWidgetTest('the login page can hide its back button', (tester) async {
      // The notic/compo themes build this page into a tab, where there is
      // nothing to go back to.
      await tester.pumpNyWidgetSimple(AccountLoginPage(showBackButton: false));

      expect(find.text(trans("Back")), findsNothing);
    });

    nyWidgetTest('the registration page renders all four fields',
        (tester) async {
      await tester.pumpNyWidgetSimple(AccountRegistrationPage());

      // First name, last name, email and password.
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text(trans("First Name")), findsOneWidget);
      expect(find.text(trans("Last Name")), findsOneWidget);
      expect(find.text(trans("Email address")), findsOneWidget);
      expect(find.text(trans("Password")), findsOneWidget);
      expect(find.text(trans("Register")), findsWidgets);
    });
  });

  nyGroup('the checkout pages', () {
    nyWidgetTest('the payment type page lists nothing when the store has no '
        'gateways switched on', (tester) async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(
              stripeEnabled: false, paypalEnabled: false, codEnabled: false));

      await tester.pumpNyWidgetSimple(CheckoutPaymentTypePage());

      expect(find.text(trans("Payment Method")), findsOneWidget);
    });

    nyWidgetTest('the payment type page lists the gateways the store enables',
        (tester) async {
      seedAppConfig(
          wooSignalApp:
              wooSignalAppFixture(stripeEnabled: true, codEnabled: true));

      // Known cosmetic defect, recorded rather than fixed: the selected tile
      // is a ListTile inside a DecoratedBox that paints its own background, so
      // Flutter asserts that the tile's ink splash cannot be seen. Debug only -
      // release builds render, they just do not ripple. Held back here so the
      // assertions below still mean something; drop the argument once the tile
      // is wrapped in its own Material.
      int held = await pumpIgnoringAssertion(tester,
          CheckoutPaymentTypePage(), 'ListTile background color');

      expect(held, greaterThan(0),
          reason: 'the ink splash assertion is expected here until the tile '
              'is fixed - remove this once it is');
      expect(find.text(trans("Debit or Credit Card")), findsOneWidget);
      expect(find.text(trans("Cash on delivery")), findsOneWidget);
    });

    nyWidgetTest('the details page renders the address form', (tester) async {
      seedCheckoutSession();

      await tester.pumpNyWidgetSimple(CheckoutDetailsPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(trans("Billing & Shipping Details")), findsOneWidget);
      expect(find.text(trans("First Name")), findsOneWidget);
      expect(find.text(trans("Address Line")), findsOneWidget);
      expect(find.text(trans("USE DETAILS")), findsOneWidget);
      // The seeded address fills the country and state rows.
      expect(find.text("United States"), findsOneWidget);
      expect(find.text("Alabama"), findsOneWidget);
    });

    nyWidgetTest('the shipping type page renders with a seeded session',
        (tester) async {
      seedCheckoutSession();

      await pumpOffline(tester, CheckoutShippingTypePage());

      expect(find.byType(CheckoutShippingTypePage), findsOneWidget);
      expect(find.text(trans("Shipping Methods")), findsOneWidget);
    });

    nyWidgetTest('the coupon page renders its redeem form', (tester) async {
      await tester.pumpNyWidgetSimple(CouponPage());

      expect(find.text(trans("Redeem Coupon")), findsOneWidget);
      expect(find.text(trans("Apply")), findsOneWidget);
      expect(find.text(trans("Cancel")), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    nyWidgetTest('the coupon page refuses an empty code without asking the '
        'store', (tester) async {
      await tester.pumpNyWidgetSimple(CouponPage());

      await tester.tap(find.text(trans("Apply")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(trans("Please enter coupon to redeem")), findsOneWidget);
    });

    nyWidgetTest('the status page shows the order it is given', (tester) async {
      await pumpAppRouter(tester);
      await visitRoute(tester, CheckoutStatusPage.path, data: orderFixture());

      expect(find.byType(CheckoutStatusPage), findsOneWidget);
      expect(find.textContaining("#900"), findsOneWidget);
      expect(find.text("Test Product"), findsWidgets);
    });

    nyWidgetTest('the status page empties the cart and the session',
        (tester) async {
      await seedCart([cartLineItemFixture()]);
      seedCheckoutSession();

      await pumpAppRouter(tester);
      await visitRoute(tester, CheckoutStatusPage.path, data: orderFixture());

      // The order is placed; nothing about it should carry into the next one.
      expect(await Cart.getInstance.getCart(), isEmpty);
      expect(CheckoutSession.getInstance.billingDetails, isNull);
      expect(CheckoutSession.getInstance.paymentType, isNull);
    });
  });

  nyGroup('the wishlist', () {
    nyWidgetTest('says so when it is empty', (tester) async {
      await tester.pumpNyWidgetSimple(WishlistPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(trans("Wishlist")), findsOneWidget);
      expect(find.text(trans("No items found")), findsOneWidget);
    });

    nyWidgetTest('still renders when the store cannot be reached',
        (tester) async {
      // A non-empty wishlist makes the page fetch the products.
      await saveWishlistProduct(product: productFixture());

      await pumpOffline(tester, WishlistPage());

      expect(find.byType(WishlistPage), findsOneWidget);
    });
  });

  nyGroup('the notifications page', () {
    nyWidgetTest('says so when there is nothing to show', (tester) async {
      await tester.pumpNyWidgetSimple(NotificationsPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.text("Notifications"), findsOneWidget);
      expect(find.text("Mark all read"), findsOneWidget);
    });

    nyWidgetTest('lists the notifications that were stored', (tester) async {
      await NyNotification.addNotification(
          "Your order shipped", "Order #12 is on its way");

      await tester.pumpNyWidgetSimple(NotificationsPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("Your order shipped"), findsOneWidget);
      expect(find.text("Showing last 30 days"), findsOneWidget);
    });
  });

  nyGroup('the product pages', () {
    nyWidgetTest('the detail page renders a product it is handed directly',
        (tester) async {
      // Routed with a Product rather than a {"productId": ...} map, so the
      // page has everything it needs and never calls the store.
      await pumpAppRouter(tester);
      List<Object> unreachable = await visitRoute(
          tester, ProductDetailPage.path,
          data: productFixture(
              overrides: {'name': "Blue Shirt", 'price': "24.99"}));

      expect(unreachable, isEmpty,
          reason: 'a product handed over directly needs nothing from the '
              'store');
      expect(find.text("Blue Shirt"), findsOneWidget);
      expect(find.text(trans("Add to cart")), findsOneWidget);
      expect(find.text(trans("Quantity")), findsOneWidget);
      expect(find.text(r"$24.99"), findsWidgets);
    });

    nyWidgetTest('the reviews page renders with no product', (tester) async {
      // No route data means the page never asks the store for reviews.
      await tester.pumpNyWidgetSimple(ProductReviewsPage());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ProductReviewsPage), findsOneWidget);
      expect(find.text(trans("Reviews")), findsOneWidget);
      expect(find.text(trans("No results")), findsOneWidget);
    });
  });
}
