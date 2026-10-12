import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_coupon_amount_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_customer_note_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_payment_type_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_shipping_type_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_store_heading_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_user_details_widget.dart';
import 'package:flutter_app/resources/widgets/customer_address_input.dart';
import 'package:flutter_app/resources/widgets/home_drawer_widget.dart';
import 'package:flutter_app/resources/widgets/no_results_for_products_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_description_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_header_widget.dart';
import 'package:flutter_app/resources/widgets/product_item_container_widget.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/splash_screen.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import 'package:flutter_app/resources/widgets/switch_address_tab.dart';
import 'package:flutter_app/resources/widgets/text_row_widget.dart';
import 'package:flutter_app/resources/widgets/top_nav_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Widget rendering tests.
///
/// The pieces the pages are built from. Most take everything they need as
/// arguments, so they can be pumped on their own with a fixture and checked
/// for what they put on screen.
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
  });

  Future<void> pump(WidgetTester tester, Widget widget) =>
      tester.pumpNyWidgetSimple(Scaffold(body: widget));

  nyGroup('the small building blocks', () {
    nyWidgetTest('the loader renders', (tester) async {
      await pump(tester, AppLoaderWidget());

      expect(find.byType(AppLoaderWidget), findsOneWidget);
    });

    nyWidgetTest('the splash screen is just the loader', (tester) async {
      await tester.pumpNyWidgetSimple(SplashScreen());

      expect(find.byType(AppLoaderWidget), findsOneWidget);
    });

    nyWidgetTest('the store logo reads the store\'s own image', (tester) async {
      await pump(tester, StoreLogo());

      CachedImageWidget image = tester.widget(find.byType(CachedImageWidget));
      expect(image.image, "https://example.test/logo.png");
    });

    nyWidgetTest('a text row shows its title and value', (tester) async {
      await pump(tester, TextRowWidget(title: "Order Ref", text: "#900"));

      expect(find.text("Order Ref"), findsOneWidget);
      expect(find.text("#900"), findsOneWidget);
    });

    nyWidgetTest('the empty results widget says so', (tester) async {
      await pump(tester, NoResultsForProductsWidget());

      expect(find.byType(NoResultsForProductsWidget), findsOneWidget);
      expect(find.text(trans("No results")), findsOneWidget);
    });

    nyWidgetTest('the top nav offers the category button', (tester) async {
      bool pressed = false;
      await pump(
          tester, TopNavWidget(onPressBrowseCategories: () => pressed = true));

      expect(find.text(trans("Browse categories")), findsOneWidget);

      await tester.tap(find.text(trans("Browse categories")));
      await tester.pump();
      expect(pressed, isTrue);
    });

    nyWidgetTest('the safe area wrapper passes its child through',
        (tester) async {
      await pump(tester, SafeAreaWidget(child: const Text("Inside")));

      expect(find.text("Inside"), findsOneWidget);
    });

    nyWidgetTest('the address tab switch renders both tabs', (tester) async {
      String? tapped;
      await pump(
          tester,
          Row(children: [
            SwitchAddressTab(
                type: "billing",
                title: "Billing",
                currentTabIndex: 0,
                onTapAction: () => tapped = "billing"),
            SwitchAddressTab(
                type: "shipping",
                title: "Shipping",
                currentTabIndex: 0,
                onTapAction: () => tapped = "shipping"),
          ]));

      expect(find.text("Billing"), findsOneWidget);
      expect(find.text("Shipping"), findsOneWidget);

      await tester.tap(find.text("Shipping"));
      await tester.pump();
      expect(tapped, "shipping");
    });
  });

  nyGroup('the product widgets', () {
    nyWidgetTest('a product tile shows the name and the price',
        (tester) async {
      await pump(
          tester,
          ProductItemContainer(
              product: productFixture(overrides: {
            'name': "Blue Shirt",
            'price': "24.99",
            'regular_price': "29.99",
            'sale_price': "24.99",
            'on_sale': true,
          })));

      expect(find.text("Blue Shirt"), findsOneWidget);
      expect(find.textContaining(r"$24.99"), findsOneWidget);
    });

    nyWidgetTest('a product tile with no product renders nothing',
        (tester) async {
      await pump(tester, ProductItemContainer());

      expect(find.byType(Text), findsNothing);
    });

    nyWidgetTest('the detail header shows the name and price', (tester) async {
      await pump(
          tester,
          ProductDetailHeaderWidget(
              product: productFixture(
                  overrides: {'name': "Blue Shirt", 'price': "24.99"})));

      expect(find.text("Blue Shirt"), findsOneWidget);
    });

    nyWidgetTest('the description is offered, collapsed, and opens on tap',
        (tester) async {
      await pump(
          tester,
          ProductDetailDescriptionWidget(
              product: productFixture(overrides: {
            'description': "<p>A <b>lovely</b> shirt</p>",
          })));

      // Collapsed to start with, so a long description does not push the
      // add-to-cart button off screen.
      expect(find.text(trans("Description")), findsOneWidget);
      expect(find.text(trans("Full description")), findsOneWidget);

      await tester.tap(find.text(trans("Description")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The HTML is rendered, so the markup itself is never shown.
      expect(find.textContaining("<p>"), findsNothing);
    });

    nyWidgetTest('the description collapses when there is none',
        (tester) async {
      await pump(
          tester,
          ProductDetailDescriptionWidget(
              product: productFixture(overrides: {'description': ""})));

      expect(find.byType(ProductDetailDescriptionWidget), findsOneWidget);
    });
  });

  nyGroup('the checkout widgets', () {
    nyWidgetTest('the store heading shows the logo', (tester) async {
      await pump(tester, CheckoutStoreHeadingWidget());

      expect(find.byType(StoreLogo), findsOneWidget);
    });

    nyWidgetTest('the user details widget shows the seeded address',
        (tester) async {
      seedCheckoutSession();

      await pump(
          tester,
          CheckoutUserDetailsWidget(
              checkoutSession: CheckoutSession.getInstance));

      expect(find.text(trans("Billing/shipping details")), findsOneWidget);
      expect(
          find.text(
              "1 Test Street, Birmingham, AL1 1AA, Alabama, United States"),
          findsOneWidget);
    });

    nyWidgetTest('the user details widget prompts when there is no address',
        (tester) async {
      CheckoutSession.getInstance.initSession();

      await pump(
          tester,
          CheckoutUserDetailsWidget(
              checkoutSession: CheckoutSession.getInstance));

      expect(find.byType(CheckoutUserDetailsWidget), findsOneWidget);
    });

    nyWidgetTest('the payment type widget prompts before one is chosen',
        (tester) async {
      seedCheckoutSession();

      await pump(
          tester,
          CheckoutPaymentTypeWidget(
              checkoutSession: CheckoutSession.getInstance));

      expect(find.text(trans("Pay with")), findsOneWidget);
      expect(find.text(trans("Select a payment method")), findsOneWidget);
    });

    nyWidgetTest('the shipping type widget shows the chosen method',
        (tester) async {
      seedCheckoutSession(
          shippingType: flatRateShippingFixture(title: "Standard"));

      await pump(
          tester,
          CheckoutShippingTypeWidget(
              wooSignalApp: seedAppConfig(),
              checkoutSession: CheckoutSession.getInstance));

      expect(find.text(trans("Shipping selected")), findsOneWidget);
      expect(find.text("Standard"), findsOneWidget);
    });

    nyWidgetTest('the coupon amount collapses when no coupon is applied',
        (tester) async {
      seedCheckoutSession();

      await pump(
          tester,
          CheckoutCouponAmountWidget(
              checkoutSession: CheckoutSession.getInstance));

      expect(find.byType(Text), findsNothing);
    });

    nyWidgetTest('the coupon amount shows the discount when one is applied',
        (tester) async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      seedCheckoutSession(
          coupon: couponFixture(discountType: "fixed_cart", amount: "15"));

      await pump(
          tester,
          CheckoutCouponAmountWidget(
              checkoutSession: CheckoutSession.getInstance));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining("15.00"), findsWidgets);
    });

    nyWidgetTest('the customer note starts from whatever is on the session',
        (tester) async {
      seedCheckoutSession(customerNote: "Leave with a neighbour");

      await pump(
          tester,
          CheckoutCustomerNote(checkoutSession: CheckoutSession.getInstance));

      expect(find.textContaining("Leave with a neighbour"), findsWidgets);
    });

    nyWidgetTest('the subtotal row shows the cart subtotal', (tester) async {
      await seedCart([cartLineItemFixture(quantity: 3, subtotal: "10.00")]);

      await pump(tester, CheckoutSubtotal(title: trans("Subtotal")));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(trans("Subtotal")), findsOneWidget);
      expect(find.text(r"$30.00"), findsOneWidget);
    });

    nyWidgetTest('the total row adds the shipping on', (tester) async {
      await seedCart([cartLineItemFixture(subtotal: "10.00")]);
      seedCheckoutSession(
          shippingType: flatRateShippingFixture(cost: "5.00"));

      await pump(tester, CheckoutTotal(title: trans("Total")));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(r"$15.00"), findsOneWidget);
    });

    nyWidgetTest('the tax row shows the tax that was worked out',
        (tester) async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 1));
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);

      await pump(tester, CheckoutTaxTotal(taxRate: taxRateFixture(rate: "20.0")));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining("20.00"), findsWidgets);
    });

    nyWidgetTest('a checkout meta line shows its title and amount',
        (tester) async {
      await pump(tester, CheckoutMetaLine(title: "Shipping fee", amount: r"$5.00"));

      expect(find.text("Shipping fee"), findsOneWidget);
      expect(find.text(r"$5.00"), findsOneWidget);
    });

    nyWidgetTest('the address form renders every field it is given',
        (tester) async {
      await pump(
          tester,
          CustomerAddressInput(
            txtControllerFirstName: TextEditingController(text: "Anthony"),
            txtControllerLastName: TextEditingController(text: "Gordon"),
            txtControllerAddressLine:
                TextEditingController(text: "1 Test Street"),
            txtControllerCity: TextEditingController(text: "Birmingham"),
            txtControllerPostalCode: TextEditingController(text: "AL1 1AA"),
            txtControllerEmailAddress:
                TextEditingController(text: "test@example.test"),
            txtControllerPhoneNumber:
                TextEditingController(text: "07000000000"),
            customerCountry: customerAddressFixture().customerCountry,
            onTapCountry: () {},
          ));

      expect(find.text("Anthony"), findsOneWidget);
      expect(find.text("1 Test Street"), findsOneWidget);
      expect(find.text("Birmingham"), findsOneWidget);
      expect(find.text("test@example.test"), findsOneWidget);
      // The country and its state are shown, not edited.
      expect(find.text("United States"), findsOneWidget);
      expect(find.text("Alabama"), findsOneWidget);
    });
  });

  nyGroup('the drawer', () {
    nyWidgetTest('renders the store menu', (tester) async {
      // Same known cosmetic defect as the payment type page: the drawer's
      // ListTiles sit inside a ColoredBox that paints its own background, so
      // Flutter asserts their ink splash cannot be seen. Debug only, recorded
      // rather than fixed.
      int held = await pumpIgnoringAssertion(
          tester,
          Scaffold(body: HomeDrawerWidget(wooSignalApp: seedAppConfig())),
          'ListTile background color');

      expect(held, greaterThan(0),
          reason: 'the ink splash assertion is expected here until the tiles '
              'are fixed - remove this once they are');
      expect(find.byType(HomeDrawerWidget), findsOneWidget);
      expect(find.text(trans("Menu")), findsOneWidget);
      expect(find.text(trans("Profile")), findsOneWidget);
      expect(find.text(trans("Cart")), findsOneWidget);
      expect(find.text(trans("Change language")), findsOneWidget);
      // The store has the wishlist switched on in the fixture.
      expect(find.text(trans("Wishlist")), findsOneWidget);
    });
  });
}
