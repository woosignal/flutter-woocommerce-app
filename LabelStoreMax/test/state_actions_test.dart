import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/cart_page.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation_page.dart';
import 'package:flutter_app/resources/pages/notifications_page.dart';
import 'package:flutter_app/resources/widgets/cart_product_item_widget.dart';
import 'package:flutter_app/resources/widgets/cart_quantity_widget.dart';
import 'package:flutter_app/resources/widgets/notification_icon_widget.dart';
import 'package:flutter_app/resources/widgets/product_quantity_widget.dart';
import 'package:flutter_app/resources/widgets/shopping_cart_total_widget.dart';
import 'package:flutter_app/resources/widgets/wishlist_icon_widget.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// State action tests.
///
/// Nylo's event bus is how one part of the app tells another that something
/// changed - the cart icon in the app bar, the running total at the bottom of
/// the cart, the loading overlay a payment gateway raises. Each action here is
/// fired by name, exactly as the code that sends it does, and the receiving
/// widget is checked for what the customer would see.
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
    await NyNotification.clearAllNotifications();
    recordToasts();
    NyStateTestHelpers.reset();
  });

  nyGroup('the cart page', () {
    nyWidgetTest('tells the customer the cart was cleared', (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      fireStateAction(CartPage.path.stateName(), 'cart_cleared');
      await tester.pump();

      expectToastShown(id: 'success', description: trans("Cart cleared"));
      expectStateAction(CartPage.path.stateName(), 'cart_cleared');
      await settleToasts(tester);
    });

    nyWidgetTest('tells the customer an item was removed', (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      fireStateAction(CartPage.path.stateName(), 'item_removed');
      await tester.pump();

      expectToastShown(id: 'warning', description: trans("Item removed"));
      await settleToasts(tester);
    });

    nyWidgetTest('warns when the customer asks for more than the stock',
        (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      fireStateAction(CartPage.path.stateName(), 'max_stock');
      await tester.pump();

      expectToastShown(
          id: 'warning', description: trans("Maximum stock reached"));
      await settleToasts(tester);
    });

    nyWidgetTest('shows nothing until an action is fired', (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());
      await tester.pump();

      expectNoToastShown(id: 'success');
      expectNoToastShown(id: 'warning');
    });

    nyWidgetTest('an empty cart shows the empty basket message',
        (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      expect(find.text(trans("Empty Basket")), findsOneWidget);
      expect(find.text(trans("PROCEED TO CHECKOUT")), findsOneWidget);
    });
  });

  nyGroup('the checkout page', () {
    nyWidgetTest('raises the loading overlay when a payment starts',
        (tester) async {
      seedCheckoutSession();
      await pumpOffline(tester, CheckoutConfirmationPage());

      expectNotLoadingNamed(
          tester, find.byType(CheckoutConfirmationPage), 'default');

      fireStateAction(
          CheckoutConfirmationPage.path.stateName(), 'payment_started');
      await tester.pump();

      expectLoadingNamed(
          tester, find.byType(CheckoutConfirmationPage), 'default');
    });

    nyWidgetTest('drops the overlay when the payment finishes',
        (tester) async {
      seedCheckoutSession();
      await pumpOffline(tester, CheckoutConfirmationPage());

      fireStateAction(
          CheckoutConfirmationPage.path.stateName(), 'payment_started');
      await tester.pump();
      fireStateAction(
          CheckoutConfirmationPage.path.stateName(), 'payment_finished');
      await tester.pump();

      expectNotLoadingNamed(
          tester, find.byType(CheckoutConfirmationPage), 'default');
    });

    nyWidgetTest('drops the overlay and explains when a payment fails',
        (tester) async {
      seedCheckoutSession();
      await pumpOffline(tester, CheckoutConfirmationPage());

      fireStateAction(
          CheckoutConfirmationPage.path.stateName(), 'payment_started');
      await tester.pump();

      fireStateAction(
          CheckoutConfirmationPage.path.stateName(), 'payment_failed',
          data: {
            'title': "Oops!",
            'description': "Your card was declined",
          });
      await tester.pump();

      // The customer must be able to try again, so the overlay has to go.
      expectNotLoadingNamed(
          tester, find.byType(CheckoutConfirmationPage), 'default');
      expectToastShown(description: "Your card was declined");
      await settleToasts(tester);
    });

    nyWidgetTest('renders the order summary from the seeded session',
        (tester) async {
      seedCheckoutSession();
      await seedCart([cartLineItemFixture(quantity: 2, subtotal: "10.00")]);

      await pumpOffline(tester, CheckoutConfirmationPage());

      expect(find.text(trans("Order Summary")), findsOneWidget);
      expect(find.text(trans("Billing/shipping details")), findsOneWidget);
      // The delivery address is shown as one line.
      expect(
          find.text(
              "1 Test Street, Birmingham, AL1 1AA, Alabama, United States"),
          findsOneWidget);
      expect(find.text(r"$20.00"), findsWidgets);
      expect(find.text(r"$5.00"), findsWidgets); // the flat rate shipping
    });

    nyWidgetTest('asks for a shipping method when none has been chosen',
        (tester) async {
      // The page half of the same scenario the order builder has to survive:
      // shipping is on, but nothing has been selected.
      seedCheckoutSession();
      CheckoutSession.getInstance.shippingType = null;
      await seedCart([cartLineItemFixture()]);

      await pumpOffline(tester, CheckoutConfirmationPage());

      expect(find.text(trans("Select shipping")), findsWidgets);
      expect(find.text(trans("Select a shipping option")), findsOneWidget);
    });
  });

  nyGroup('the cart quantity badge', () {
    nyWidgetTest('shows how many items are in the cart', (tester) async {
      await seedCart([
        cartLineItemFixture(productId: 1, quantity: 2),
        cartLineItemFixture(productId: 2, quantity: 3),
      ]);

      await tester.pumpNyWidgetSimple(Scaffold(body: CartQuantity()));

      expect(find.text("5"), findsOneWidget);
    });

    nyWidgetTest('picks up a change when refreshed', (tester) async {
      await seedCart([cartLineItemFixture(quantity: 1)]);
      await tester.pumpNyWidgetSimple(Scaffold(body: CartQuantity()));
      expect(find.text("1"), findsOneWidget);

      // What CartRemoveItemEvent and the quantity stepper send.
      await seedCart([cartLineItemFixture(quantity: 4)]);
      fireStateAction(CartQuantity.state, 'refresh');
      await tester.pump();
      await tester.pump();

      expect(find.text("4"), findsOneWidget);
    });

    nyTest('listens on the name the senders use', () async {
      expect(CartQuantity.state, "cart_quantity");
    });
  });

  nyGroup('the running cart total', () {
    nyWidgetTest('shows the formatted cart total', (tester) async {
      await seedCart([cartLineItemFixture(quantity: 2, subtotal: "10.00")]);

      await tester.pumpNyWidgetSimple(Scaffold(body: ShoppingCartTotal()));

      expect(find.text(r"$20.00"), findsOneWidget);
    });

    nyWidgetTest('picks up a change when refreshed', (tester) async {
      await seedCart([cartLineItemFixture(quantity: 1, subtotal: "10.00")]);
      await tester.pumpNyWidgetSimple(Scaffold(body: ShoppingCartTotal()));
      expect(find.text(r"$10.00"), findsOneWidget);

      await seedCart([cartLineItemFixture(quantity: 3, subtotal: "10.00")]);
      fireStateAction(ShoppingCartTotal.state, 'refresh');
      await tester.pump();
      await tester.pump();

      expect(find.text(r"$30.00"), findsOneWidget);
    });

    nyTest('listens on the name the senders use', () async {
      expect(ShoppingCartTotal.state, "shopping_cart_total");
    });
  });

  nyGroup('the wishlist heart', () {
    nyWidgetTest('fills in once the product is on the wishlist',
        (tester) async {
      await tester.pumpNyWidgetSimple(
          Scaffold(body: WishlistIcon(productFixture())));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await saveWishlistProduct(product: productFixture());
      fireStateAction(WishlistIcon.state, 'refresh');
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    nyTest('listens on the name the senders use', () async {
      expect(WishlistIcon.state, "wishlist_icon");
    });
  });

  nyGroup('the notification bell', () {
    nyWidgetTest('counts the unread notifications, and recounts on refresh',
        (tester) async {
      seedAppConfig().firebaseFcmIsEnabled = true;

      await tester.pumpNyWidgetSimple(Scaffold(body: NotificationIcon()));
      expect(find.text("1"), findsNothing);

      // What FirebaseOnMessageOrderEvent sends after storing a push.
      await NyNotification.addNotification("Your order shipped", "On its way");
      fireStateAction(NotificationIcon.state, 'refresh');
      await tester.pump();
      await tester.pump();

      expect(find.text("1"), findsOneWidget);
    });

    nyWidgetTest('is hidden when the store has push notifications off',
        (tester) async {
      seedAppConfig().firebaseFcmIsEnabled = false;

      await tester.pumpNyWidgetSimple(Scaffold(body: NotificationIcon()));

      expect(find.byIcon(Icons.notifications_none), findsNothing);
    });

    nyTest('listens on the name the senders use', () async {
      expect(NotificationIcon.state, "notification_icon");
      // The notifications page is addressed by its route, not a name.
      expect(NotificationsPage.path.name, "/notifications");
    });
  });

  nyGroup('the product quantity stepper', () {
    nyWidgetTest('starts at one and takes a quantity from a state action',
        (tester) async {
      await tester.pumpNyWidgetSimple(Scaffold(body: ProductQuantity()));

      expect(find.text("1"), findsOneWidget);

      fireStateAction(ProductQuantity.state, 'set_quantity', data: 7);
      await tester.pump();
      await tester.pump();

      expect(find.text("7"), findsOneWidget);
    });

    nyTest('listens on the name the senders use', () async {
      expect(ProductQuantity.state, "product_quantity");
    });
  });

  nyGroup('a cart line', () {
    nyTest('gets a state key of its own per product and variation', () async {
      // Every line in the cart listens separately, so stepping one does not
      // rebuild the others.
      expect(
          CartProductItem(cartLineItemFixture(productId: 101)).stateKey,
          "cart_product_item_101_null");
      expect(
          CartProductItem(
                  cartLineItemFixture(productId: 101, variationId: 55))
              .stateKey,
          "cart_product_item_101_55");
    });

    nyTest('two variations of one product get different keys', () async {
      expect(
          CartProductItem(
                  cartLineItemFixture(productId: 1, variationId: 10))
              .stateKey,
          isNot(CartProductItem(
                  cartLineItemFixture(productId: 1, variationId: 11))
              .stateKey));
    });

    nyWidgetTest('renders the line the customer added', (tester) async {
      await tester.pumpNyWidgetSimple(Scaffold(
          body: CartProductItem(cartLineItemFixture(
              name: "Blue Shirt",
              quantity: 2,
              subtotal: "12.50",
              variationOptions: "Blue; Large"))));

      expect(find.text("Blue Shirt"), findsOneWidget);
      expect(find.text("Blue; Large"), findsOneWidget);
      expect(find.text(trans("In Stock")), findsOneWidget);
      expect(find.text("2"), findsOneWidget);
    });

    nyWidgetTest('says when a line is out of stock', (tester) async {
      await tester.pumpNyWidgetSimple(Scaffold(
          body: CartProductItem(
              cartLineItemFixture(stockStatus: "outofstock"))));

      expect(find.text(trans("Out of stock")), findsOneWidget);
    });
  });

  nyGroup('the cart list', () {
    nyTest('is addressed by its own name', () async {
      // The remove and clear events reset this CollectionView by name.
      expect(CartPage.cartListState, "shopping_cart_items_list_view");
    });

    nyWidgetTest('still renders when the store cannot be reached',
        (tester) async {
      // A cart with lines in it makes the page re-check them against the
      // store, and the page has to survive that failing. The lines themselves
      // come back from the store, so they cannot be asserted here - the
      // rendering of a line is covered by "a cart line" above.
      await seedCart([
        cartLineItemFixture(name: "Blue Shirt", productId: 1),
        cartLineItemFixture(name: "Red Hat", productId: 2),
      ]);

      List<Object> unreachable = await pumpOffline(tester, CartPage());

      expect(unreachable, isNotEmpty,
          reason: 'the cart check is expected to fail with no network');
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text(trans("Shopping Cart")), findsOneWidget);
      expect(find.text(trans("PROCEED TO CHECKOUT")), findsOneWidget);
    });
  });

  nyGroup('locks', () {
    nyWidgetTest('the checkout button is not held before it is pressed',
        (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      expectNotLocked(
          tester, find.byType(CartPage), 'proceed_to_checkout');
    });

    nyWidgetTest('pressing checkout with an empty cart releases the lock',
        (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());

      await tester.tap(find.text(trans("PROCEED TO CHECKOUT")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // The guard clause returns, and the lock has to be released or the
      // button is dead for the rest of the session.
      expectNotLocked(tester, find.byType(CartPage), 'proceed_to_checkout');
      expectToastShown(
          id: 'warning',
          description: trans("You need items in your cart to checkout"));
      await settleToasts(tester);
    });

    nyWidgetTest('checkout refuses a cart holding an out of stock line',
        (tester) async {
      // The page is pumped with an empty cart so its start-up cart check
      // never reaches the store; the button re-reads the cart from storage
      // when it is pressed, which is the rule under test.
      await tester.pumpNyWidgetSimple(CartPage());
      await seedCart([cartLineItemFixture(stockStatus: "outofstock")]);

      await tester.tap(find.text(trans("PROCEED TO CHECKOUT")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expectToastShown(
          id: 'warning', description: trans("There is an item out of stock"));
      expectNotLocked(tester, find.byType(CartPage), 'proceed_to_checkout');
      await settleToasts(tester);
    });

    nyWidgetTest('a signed out customer is offered guest checkout or login',
        (tester) async {
      await tester.pumpNyWidgetSimple(CartPage());
      await seedCart([cartLineItemFixture(stockStatus: "instock")]);
      await clearWpUser();

      await tester.tap(find.text(trans("PROCEED TO CHECKOUT")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text("Checkout as guest or login to continue".tr()),
          findsOneWidget);
      expect(find.text("Checkout as guest".tr()), findsOneWidget);
      expect(find.text("Login / Create an account".tr()), findsOneWidget);
      expect(find.text("Cancel".tr()), findsOneWidget);
    });

    nyWidgetTest('the login option is hidden when the store has no accounts',
        (tester) async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(wpLoginEnabled: 0));
      await tester.pumpNyWidgetSimple(CartPage());
      await seedCart([cartLineItemFixture(stockStatus: "instock")]);
      await clearWpUser();

      await tester.tap(find.text(trans("PROCEED TO CHECKOUT")));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text("Checkout as guest".tr()), findsOneWidget);
      expect(find.text("Login / Create an account".tr()), findsNothing);
    });
  });

  nyGroup('the event bus', () {
    nyTest('is installed, or every state action would be dropped', () async {
      // Without it updateState logs "Event bus not defined" and returns, so a
      // test covering a state action would pass while asserting nothing.
      expect(Backpack.instance.read("event_bus"), isNotNull);
    });

    nyTest('a page is addressed by the name built from its route', () async {
      expect(CartPage.path.stateName(), "Closure: () => _CartPageState");
      expect(CheckoutConfirmationPage.path.stateName(),
          "Closure: () => _CheckoutConfirmationPageState");
    });
  });
}
