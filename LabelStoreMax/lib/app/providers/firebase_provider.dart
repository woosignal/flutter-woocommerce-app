import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/woosignal.dart';

class FirebaseProvider implements NyProvider {

  boot(Nylo nylo) async {

    return null;
  }

  afterBoot(Nylo nylo) async {
    if (getEnv('FCM_ENABLED') != true) return;

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

    String? token = await messaging.getToken();
    if (token != null) {
      WooSignal.instance.setFcmToken(token);
    }
  }
}
