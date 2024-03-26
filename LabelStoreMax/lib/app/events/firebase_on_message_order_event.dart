import 'package:firebase_messaging/firebase_messaging.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/notifications_page.dart';
import '/resources/widgets/notification_icon_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class FirebaseOnMessageOrderEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    RemoteMessage message = event['RemoteMessage'];

    await _updateNotificationIconState(message);
  }

  /// Update the notification icon state
  _updateNotificationIconState(RemoteMessage message) async {
    String title = getEnv('APP_NAME');
    if (message.notification?.title != null) {
      title = message.notification!.title!;
    }
    String body = "";
    if (message.notification?.body != null) {
      body = message.notification!.body!;
    }

    await NyNotification.addNotification(title, body, meta: message.data);
    updateState(NotificationIcon.state);
    StateAction.refreshPage(NotificationsPage.path);
  }
}
