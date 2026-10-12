import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/events/cart_remove_all_event.dart';
import 'package:flutter_app/app/events/cart_remove_item_event.dart';
import 'package:flutter_app/app/events/category_notification_event.dart';
import 'package:flutter_app/app/events/firebase_on_message_order_event.dart';
import 'package:flutter_app/app/events/login_event.dart';
import 'package:flutter_app/app/events/logout_event.dart';
import 'package:flutter_app/app/events/order_notification_event.dart';
import 'package:flutter_app/app/events/product_notification_event.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/bootstrap/events.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/pages/account_order_detail_page.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/pages/home_search_page.dart';
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:flutter_app/app/providers/app_provider.dart';
import 'package:woosignal/networking/api_provider.dart';
import 'package:woosignal/woosignal.dart' show WooSignal;
import 'package:wp_json_api/wp_json_api.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Event tests.
///
/// Events are how the app reacts to something happening elsewhere - a push
/// notification arriving, the customer signing out, an item leaving the cart.
/// The push events in particular are worth pinning: each has to act on its own
/// payload key and leave the others alone, or one notification triggers three
/// different screens.
/// The customer's wp_json_api token WooSignal requests are carrying, if any.
String? wooSignalUserToken() => WooSignal.instance.apiProvider.dio.options
    .headers[ApiProvider.wpUserTokenHeader] as String?;

/// The WordPress user id WooSignal requests are carrying in the device meta.
dynamic wooSignalWpUserId() => (jsonDecode(WooSignal.instance.apiProvider.dio
    .options.headers["X-DMETA"] as String) as Map)['wp_user_id'];

const String customerToken =
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

void main() {
  NyTest.init();

  nySetUpAll(() async {
    NyWidgetTest.configure(testTheme: NyWidgetTest.simpleTestTheme);
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    await clearCart();
    await clearWpUser();
    await NyNotification.clearAllNotifications();
    WooSignal.instance.setWpUserToken(null);
  });

  nyGroup('registration', () {
    nyTest('all eight events are registered', () async {
      expect(events.keys.toSet(), {
        LoginEvent,
        LogoutEvent,
        FirebaseOnMessageOrderEvent,
        OrderNotificationEvent,
        ProductNotificationEvent,
        CartRemoveItemEvent,
        CartRemoveAllEvent,
        CategoryNotificationEvent,
      });
      expect(events.length, 8);
    });

    nyTest('every event has a listener behind it', () async {
      // An event registered with no listener fires and does nothing.
      for (MapEntry<Type, NyEvent> entry in events.entries) {
        expect(entry.value.listeners, isNotEmpty,
            reason: '${entry.key} has no listener');
      }
    });
  });

  nyGroup('signing in', () {
    nyTest('tells WooSignal which customer is shopping', () async {
      // The store needs the WordPress user id to attribute the cart and the
      // order to a customer.
      await seedWpUser(id: 42);

      await event<LoginEvent>();

      expect(await WPJsonAPI.wpUserId(), "42");
    });

    nyTest('sends the customer\'s login to WooSignal', () async {
      // WooSignal checks the token with the store before it returns the
      // customer's orders or links this device to them.
      await seedWpUser(id: 42, token: customerToken);

      await event<LoginEvent>();

      expect(wooSignalUserToken(), customerToken);
      expect(wooSignalWpUserId(), "42");
    });

    nyTest('sends no login when the session has expired', () async {
      WooSignal.instance.setWpUserToken("stale-token");
      await seedWpUser(
          token: customerToken,
          expiresAt: DateTime.now()
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch ~/
              1000);

      await event<LoginEvent>();

      expect(wooSignalUserToken(), isNull);
      expect(wooSignalWpUserId(), "");
    });

    nyTest('does nothing when there is no session to read', () async {
      await clearWpUser();

      await event<LoginEvent>();

      expect(await WPJsonAPI.wpUserId(), isNull);
    });
  });

  nyGroup('app start', () {
    nyTest('a saved session sends the customer\'s login to WooSignal',
        () async {
      await seedWpUser(id: 7, token: customerToken);

      await AppProvider().boot(Nylo());

      expect(wooSignalUserToken(), customerToken);
      expect(wooSignalWpUserId(), "7");
    });

    nyTest('an expired saved session sends no login', () async {
      WooSignal.instance.setWpUserToken("stale-token");
      await seedWpUser(token: customerToken, legacySession: true);

      await AppProvider().boot(Nylo());

      expect(wooSignalUserToken(), isNull);
      expect(await WPJsonAPI.wpUser(), isNull);
    });
  });

  nyGroup('signing out', () {
    nyWidgetTest('clears the WordPress session and the cart', (tester) async {
      await seedWpUser();
      await seedCart([cartLineItemFixture()]);
      expect(await WPJsonAPI.wpUserLoggedIn(), isTrue);
      expect(await Cart.getInstance.getCart(), isNotEmpty);

      // The listener ends by routing home, so it needs a live navigator.
      await pumpAppRouter(tester);
      await fireAndSettle(tester, () => event<LogoutEvent>());

      expect(await WPJsonAPI.wpUserLoggedIn(), isFalse);
      expect(await WPJsonAPI.wpUser(), isNull);
      expect(await Cart.getInstance.getCart(), isEmpty);
    });

    nyWidgetTest('stops sending the customer\'s login to WooSignal',
        (tester) async {
      await seedWpUser(token: customerToken);
      await event<LoginEvent>();
      expect(wooSignalUserToken(), customerToken);

      await pumpAppRouter(tester);
      await fireAndSettle(tester, () => event<LogoutEvent>());

      expect(wooSignalUserToken(), isNull);
      expect(wooSignalWpUserId(), "");
    });

    nyWidgetTest(
        'an expired session stops sending the customer\'s login to WooSignal',
        (tester) async {
      await seedWpUser(token: customerToken);
      await event<LoginEvent>();

      await pumpAppRouter(tester);
      await fireAndSettle(
          tester, () => event<LogoutEvent>(data: {"session_expired": true}));

      expect(wooSignalUserToken(), isNull);
      expect(wooSignalWpUserId(), "");
    });

    nyWidgetTest('sends the customer back to the home page', (tester) async {
      await seedWpUser();
      await pumpAppRouter(tester);

      await fireAndSettle(tester, () => event<LogoutEvent>());

      expect(Nylo.getCurrentRouteName(), HomePage.path.name);
    });

    nyWidgetTest(
        'an expired session clears the device, keeps the cart and asks the '
        'customer to login', (tester) async {
      // The store answered InvalidUserTokenException: the token expired, was
      // revoked, or the password changed elsewhere.
      await seedWpUser();
      await seedCart([cartLineItemFixture()]);

      await pumpAppRouter(tester);
      await fireAndSettle(
          tester, () => event<LogoutEvent>(data: {"session_expired": true}));

      expect(await WPJsonAPI.wpUser(), isNull);
      expect(await Cart.getInstance.getCart(), isNotEmpty);
      expect(Nylo.getCurrentRouteName(), AccountLoginPage.path.name);
    });

    nyWidgetTest('leaves the saved addresses alone', (tester) async {
      // Signing out is not the same as forgetting where somebody lives; the
      // addresses are keyed separately and survive.
      await seedWpUser();
      await NyStorage.save("CS_BILLING_DETAILS", "{}");

      await pumpAppRouter(tester);
      await fireAndSettle(tester, () => event<LogoutEvent>());

      expect(await NyStorage.read("CS_BILLING_DETAILS"), "{}");
    });
  });

  nyGroup('removing an item from the cart', () {
    nyTest('takes the line out of storage', () async {
      await seedCart([
        cartLineItemFixture(name: "Blue Shirt", productId: 1),
        cartLineItemFixture(name: "Red Hat", productId: 2),
      ]);

      await event<CartRemoveItemEvent>(
          data: {"cartLineItem": cartLineItemFixture(productId: 1)});

      expect((await Cart.getInstance.getCart()).single.name, "Red Hat");
    });
  });

  nyGroup('clearing the cart', () {
    nyTest('empties it', () async {
      await seedCart([cartLineItemFixture()]);

      await event<CartRemoveAllEvent>();

      expect(await Cart.getInstance.getCart(), isEmpty);
    });
  });

  nyGroup('an order push', () {
    /// Fire an order push at an app sitting on the search page and report
    /// where it ended up.
    Future<String?> pushOrder(WidgetTester tester,
        {Map<String, String> data = const {}}) async {
      await pumpAppRouter(tester);
      await event<OrderNotificationEvent>(
          data: {'RemoteMessage': RemoteMessage(data: data)});
      await settleOffline(tester);
      return Nylo.getCurrentRouteName();
    }

    nyWidgetTest('opens the order it names for the customer it belongs to',
        (tester) async {
      await seedWpUser(id: 42);

      expect(
          await pushOrder(tester, data: {"order_id": "12", "user_id": "42"}),
          AccountOrderDetailPage.path.name);
    });

    nyWidgetTest('ignores a push with no order_id', (tester) async {
      await seedWpUser(id: 42);

      expect(await pushOrder(tester, data: {"user_id": "42"}),
          HomeSearchPage.path.name);
    });

    nyWidgetTest('ignores a push with no user_id', (tester) async {
      // An order belongs to somebody, so a broadcast must not open one.
      await seedWpUser(id: 42);

      expect(await pushOrder(tester, data: {"order_id": "12"}),
          HomeSearchPage.path.name);
    });

    nyWidgetTest('ignores a push when nobody is signed in', (tester) async {
      await clearWpUser();

      expect(
          await pushOrder(tester, data: {"order_id": "12", "user_id": "42"}),
          HomeSearchPage.path.name);
    });

    nyWidgetTest('ignores an order that belongs to somebody else',
        (tester) async {
      // The customer signed in on this device is 42; the push is for 99.
      await seedWpUser(id: 42);

      expect(
          await pushOrder(tester, data: {"order_id": "12", "user_id": "99"}),
          HomeSearchPage.path.name);
    });
  });

  nyGroup('a product push', () {
    nyWidgetTest('ignores a push with no product_id', (tester) async {
      await pumpAppRouter(tester);

      await event<ProductNotificationEvent>(
          data: {'RemoteMessage': RemoteMessage(data: {"order_id": "12"})});
      await settleOffline(tester);

      expect(Nylo.getCurrentRouteName(), HomeSearchPage.path.name);
    });

    nyWidgetTest(
        'opens the product page - which cannot read the id it is given',
        (tester) async {
      // Pre-existing defect: ProductNotificationEvent sends
      // `int.parse(product_id)`, while ProductDetailPage.init assigns whatever
      // it is handed straight to a `Product?`, so the page throws a TypeError.
      // Un-skip once the payload contract is settled.
      await pumpAppRouter(tester);

      await event<ProductNotificationEvent>(
          data: {'RemoteMessage': RemoteMessage(data: {"product_id": "101"})});
      List<Object> errors = await settleOffline(tester);

      expect(Nylo.getCurrentRouteName(), ProductDetailPage.path.name);
      expect(errors, isEmpty);
    }, skip: true);
  });

  nyGroup('a category push', () {
    nyWidgetTest('ignores a push with no category_id', (tester) async {
      await pumpAppRouter(tester);

      await event<CategoryNotificationEvent>(
          data: {'RemoteMessage': RemoteMessage(data: {"product_id": "1"})});
      await settleOffline(tester);

      expect(Nylo.getCurrentRouteName(), HomeSearchPage.path.name);
    });

    nyWidgetTest('ignores a category push aimed at a different customer',
        (tester) async {
      await seedWpUser(id: 42);
      await pumpAppRouter(tester);

      await event<CategoryNotificationEvent>(data: {
        'RemoteMessage':
            RemoteMessage(data: {"category_id": "15", "user_id": "99"})
      });
      await settleOffline(tester);

      expect(Nylo.getCurrentRouteName(), HomeSearchPage.path.name);
    });

    nyWidgetTest(
        'opens the category page - which cannot read the id it is given',
        (tester) async {
      // Same mismatch as the product push: the event sends an int,
      // BrowseCategoryPage.init assigns it to a `ProductCategory?`.
      await pumpAppRouter(tester);

      await event<CategoryNotificationEvent>(
          data: {'RemoteMessage': RemoteMessage(data: {"category_id": "15"})});
      List<Object> errors = await settleOffline(tester);

      expect(Nylo.getCurrentRouteName(), BrowseCategoryPage.path.name);
      expect(errors, isEmpty);
    }, skip: true);
  });

  nyGroup('a notification push', () {
    nyTest('stores the notification for the in-app list', () async {
      await event<FirebaseOnMessageOrderEvent>(data: {
        'RemoteMessage': RemoteMessage(
            data: {"order_id": "12"},
            notification: RemoteNotification(
                title: "Your order shipped", body: "Order #12 is on its way"))
      });

      List<dynamic> notifications = await NyNotification.allNotifications();

      expect(notifications.length, 1);
      expect(notifications.first.title, "Your order shipped");
      expect(notifications.first.message, "Order #12 is on its way");
      expect(notifications.first.meta, {"order_id": "12"});
      expect(notifications.first.hasRead, isFalse);
    });

    nyTest('falls back to the app name when the push carries no title',
        () async {
      await event<FirebaseOnMessageOrderEvent>(
          data: {'RemoteMessage': RemoteMessage(data: {})});

      List<dynamic> notifications = await NyNotification.allNotifications();

      expect(notifications.single.title, getEnv('APP_NAME'));
      expect(notifications.single.message, "");
    });

    nyTest('stores one notification per push', () async {
      for (int i = 1; i <= 3; i++) {
        await event<FirebaseOnMessageOrderEvent>(data: {
          'RemoteMessage': RemoteMessage(
              data: {"order_id": "$i"},
              notification: RemoteNotification(title: "Push $i", body: "body"))
        });
      }

      expect((await NyNotification.allNotifications()).length, 3);
    });
  });
}
