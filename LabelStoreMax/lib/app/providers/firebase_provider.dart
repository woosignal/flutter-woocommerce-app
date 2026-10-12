import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/app/events/category_notification_event.dart';
import '/app/events/firebase_on_message_order_event.dart';
import '/app/events/order_notification_event.dart';
import '/app/events/product_notification_event.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/firebase_options.dart';
import '/resources/pages/account_order_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/woosignal.dart';

class FirebaseProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    bool? firebaseFcmIsEnabled =
        AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    // `DefaultFirebaseOptions.currentPlatform` throws when firebase_options.dart
    // still holds the template's placeholder values, i.e. whenever a store has
    // not set Firebase up yet. Push notifications are optional, so log it and
    // let the rest of the app boot instead of taking the whole app down.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      NyLogger.error(
          "Firebase failed to initialize, push notifications are disabled for this session: $e");
      return;
    }

    _listenForRemoteMessages();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    // Link this device to the logged in customer; WooSignal only does that
    // once it has checked their token with the store.
    if (AppHelper.instance.appConfig?.wpLoginEnabled == 1) {
      await syncWooSignalCustomer();
    }

    try {
      String? token = await messaging.getToken();
      if (token != null) {
        WooSignal.instance.setFcmToken(token);
      }
    } catch (e) {
      printError(e);
    }
  }

  /// Subscribe to Firebase Messaging streams.
  /// This lives in the provider (and not in a page) so the subscriptions are
  /// opened once for the lifetime of the app.
  void _listenForRemoteMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      /// WP Notify - Product notification
      if (message.data.containsKey('product_id')) {
        event<ProductNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        event<OrderNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// WooSignal - Category notification
      if (message.data.containsKey('category_id')) {
        event<CategoryNotificationEvent>(data: {"RemoteMessage": message});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        event<FirebaseOnMessageOrderEvent>(data: {"RemoteMessage": message});
        _maybeShowSnackBar(message);
      }
    });
  }

  /// Attempt to show a snackbar if the user is on the same page
  Future<void> _maybeShowSnackBar(RemoteMessage message) async {
    if (!(await canSeeRemoteMessage(message))) {
      return;
    }
    _showSnackBar(message.notification?.body, onPressed: () {
      routeTo(AccountOrderDetailPage.path,
          data: int.parse(message.data['order_id']));
    });
  }

  void _showSnackBar(String? message, {Function()? onPressed}) {
    SnackBar snackBar = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'New notification received'.tr()} 🚨',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          if (message != null) Text(message)
        ],
      ),
      action: onPressed == null
          ? null
          : SnackBarAction(
              label: 'View'.tr(),
              onPressed: onPressed,
            ),
      duration: Duration(milliseconds: 4500),
    );

    BuildContext? context =
        NyNavigator.instance.router.navigatorKey?.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
