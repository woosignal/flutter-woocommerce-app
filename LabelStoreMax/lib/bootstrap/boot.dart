// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/app_localization.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/woosignal.dart';
import 'package:wp_json_api/wp_json_api.dart';

/// boot application
Future<void> boot() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await WooSignal.instance
      .init(appKey: getEnv('APP_KEY'), debugMode: getEnv('APP_DEBUG'));

  // Notifications
  /// await Firebase.initializeApp(
  ///   options: DefaultFirebaseOptions.currentPlatform,
  /// );
  ///
  /// FirebaseMessaging messaging = FirebaseMessaging.instance;
  ///
  /// NotificationSettings settings = await messaging.requestPermission(
  ///   alert: true,
  ///   announcement: false,
  ///   badge: true,
  ///   carPlay: false,
  ///   criticalAlert: false,
  ///   provisional: false,
  ///   sound: true,
  /// );
  ///
  /// if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  ///   String token = await messaging.getToken();
  ///   WooSignal.instance.setFcmToken(token);
  /// }

  AppHelper?.instance?.appConfig = WooSignalApp();
  AppHelper.instance.appConfig.themeFont = "Poppins";
  AppHelper.instance.appConfig.themeColors = {
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

  // WooSignal Setup
  WooSignalApp wooSignalApp = await appWooSignal((api) => api.getApp());
  Locale locale = Locale('en');

  if (wooSignalApp != null) {
    AppHelper.instance.appConfig = wooSignalApp;

    if (wooSignalApp.wpLoginEnabled == 1) {
      WPJsonAPI.instance.initWith(
        baseUrl: wooSignalApp.wpLoginBaseUrl,
        shouldDebug: getEnv('APP_DEBUG'),
        wpJsonPath: wooSignalApp.wpLoginWpApiPath,
      );
    }

    if (getEnv('DEFAULT_LOCALE', defaultValue: null) == null &&
        wooSignalApp.locale != null) {
      locale = Locale(wooSignalApp.locale);
    } else {
      locale = Locale(envVal('DEFAULT_LOCALE', defaultValue: 'en'));
    }
  }

  /// NyLocalization
  await NyLocalization.instance.init(
      localeType: localeType,
      languageCode: locale.languageCode,
      languagesList: languagesList,
      assetsDirectory: assetsDirectory,
      valuesAsMap: valuesAsMap);
}
