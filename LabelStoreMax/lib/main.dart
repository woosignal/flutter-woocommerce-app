import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/setup.dart';
import 'package:flutter_app/config/app_localization.dart';
import 'package:flutter_app/routes/router.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/wp_json_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Nylo nylo = await Nylo.init(router: appRouter(), setup: boot);

  String initialRoute = '/no-connection';
  WooSignalApp wooSignalApp = await appWooSignal((api) => api.getApp());
  Locale locale;

  if (wooSignalApp != null) {
    initialRoute = "/home";
    AppHelper.instance.appConfig = wooSignalApp;
    AppHelper.instance.themeType = wooSignalApp.theme;

    if (wooSignalApp.wpLoginEnabled == 1) {
      WPJsonAPI.instance.initWith(
        baseUrl: wooSignalApp.wpLoginBaseUrl,
        shouldDebug: (wooSignalApp.appDebug == 1),
        wpJsonPath: wooSignalApp.wpLoginWpApiPath,
      );
    }

    locale = Locale((getEnv('DEFAULT_LOCALE', defaultValue: null) == null && wooSignalApp.locale != null) ? wooSignalApp.locale : envVal('DEFAULT_LOCALE', defaultValue: 'en'));
  }

  /// NyLocalization
  await NyLocalization.instance.init(
      localeType: localeType,
      languageCode: locale != null ? locale.languageCode : Locale(getEnv('DEFAULT_LOCALE', defaultValue: 'en')),
      languagesList: languagesList,
      assetsDirectory: assetsDirectory,
      valuesAsMap: valuesAsMap
  );

  runApp(
    AppBuild(
      navigatorKey: nylo.router.navigatorKey,
      onGenerateRoute: nylo.router.generator(),
      locale: locale,
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
    ),
  );
}
