import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/notification_item.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Notification tests.
///
/// The in-app notification list is stored on the device, not fetched, so all
/// of this runs without Firebase. [canSeeRemoteMessage] is the filter that
/// stops one customer's order push being shown to whoever is signed in next on
/// a shared device.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    await NyNotification.clearAllNotifications();
    await clearWpUser();
  });

  nyGroup('the notification list', () {
    nyTest('starts empty', () async {
      expect(await NyNotification.allNotifications(), isEmpty);
      expect(await NyNotification.allNotificationsNotRead(), isEmpty);
    });

    nyTest('keeps what was added', () async {
      await NyNotification.addNotification(
          "Your order shipped", "Order #12 is on its way");

      List<NotificationItem> notifications =
          await NyNotification.allNotifications();

      expect(notifications.length, 1);
      expect(notifications.first.title, "Your order shipped");
      expect(notifications.first.message, "Order #12 is on its way");
      expect(notifications.first.hasRead, isFalse);
      expect(notifications.first.createdAt, isNotNull);
    });

    nyTest('carries the push payload as meta', () async {
      await NyNotification.addNotification("Sale", "20% off today",
          id: "n1", meta: {"category_id": "15"});

      NotificationItem item = (await NyNotification.allNotifications()).first;

      expect(item.id, "n1");
      expect(item.meta, {"category_id": "15"});
    });

    nyTest('keeps several notifications in the order they arrived', () async {
      await NyNotification.addNotification("First", "1");
      await NyNotification.addNotification("Second", "2");
      await NyNotification.addNotification("Third", "3");

      List<NotificationItem> notifications =
          await NyNotification.allNotifications();

      expect(notifications.map((n) => n.title), ["First", "Second", "Third"]);
    });

    nyTest('marks one as read by its position', () async {
      await NyNotification.addNotification("First", "1");
      await NyNotification.addNotification("Second", "2");

      await NyNotification.markReadByIndex(0);

      List<NotificationItem> notifications =
          await NyNotification.allNotifications();
      expect(notifications[0].hasRead, isTrue);
      expect(notifications[1].hasRead, isFalse);
      expect((await NyNotification.allNotificationsNotRead()).length, 1);
    });

    nyTest('marks every notification as read', () async {
      await NyNotification.addNotification("First", "1");
      await NyNotification.addNotification("Second", "2");

      await NyNotification.markReadAll();

      expect(await NyNotification.allNotificationsNotRead(), isEmpty);
    });

    nyTest('clears the list', () async {
      await NyNotification.addNotification("First", "1");

      await NyNotification.clearAllNotifications();

      expect(await NyNotification.allNotifications(), isEmpty);
    });

    nyTest('hides a notification addressed to a different customer', () async {
      await seedWpUser(id: 42);
      await NyNotification.addNotification("Yours", "for 42",
          meta: {"user_id": "42"});
      await NyNotification.addNotification("Theirs", "for 99",
          meta: {"user_id": "99"});
      await NyNotification.addNotification("Everyone", "broadcast");

      List<NotificationItem> notifications =
          await NyNotification.allNotifications();

      expect(notifications.map((n) => n.title), ["Yours", "Everyone"]);
    });

    nyTest('is stored under its own key', () async {
      expect(NyNotification.storageKey(), "app_notifications");
    });
  });

  nyGroup('canSeeRemoteMessage', () {
    nyTest('lets a broadcast through', () async {
      // No user_id on the payload means it is for everybody.
      expect(
          await canSeeRemoteMessage(
              RemoteMessage(data: {"product_id": "101"})),
          isTrue);
    });

    nyTest('blocks a targeted message when nobody is signed in', () async {
      expect(
          await canSeeRemoteMessage(RemoteMessage(data: {"user_id": "42"})),
          isFalse);
    });

    nyTest('blocks a message aimed at a different customer', () async {
      await seedWpUser(id: 42);

      expect(
          await canSeeRemoteMessage(RemoteMessage(data: {"user_id": "99"})),
          isFalse);
    });

    nyTest('lets a message through to the customer it names', () async {
      await seedWpUser(id: 42);

      expect(
          await canSeeRemoteMessage(RemoteMessage(data: {"user_id": "42"})),
          isTrue);
    });
  });
}
