import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/bootstrap/app_helper.dart';
import '/firebase_options.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/woosignal.dart';

class FirebaseProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    return null;
  }

  @override
  afterBoot(Nylo nylo) async {
    bool? firebaseFcmIsEnabled =
        AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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

    WpUser? wpUser = await WPJsonAPI.wpUser();
    if (wpUser != null && wpUser.id != null) {
      WooSignal.instance.setWpUserId(wpUser.id.toString());
    }

    String? token = await messaging.getToken();
    if (token != null) {
      WooSignal.instance.setFcmToken(token);
    }
  }
}
