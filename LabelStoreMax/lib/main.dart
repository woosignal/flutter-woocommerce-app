import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/app.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/app_locale.dart';
import 'package:flutter_app/resources/themes/dark_theme.dart';
import 'package:flutter_app/resources/themes/default_theme.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:flutter_app/routes/router.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:nylo_framework/theme/helper/theme_helper.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/wp_json_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme appTheme = AppTheme();

  Nylo nylo =
      await initNylo(theme: defaultTheme(appTheme), router: buildRouter());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  String initialRoute = '/no-connection';
  WooSignalApp wooSignalApp = await appWooSignal((api) => api.getApp());
  Locale locale = app_locale;

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

    if (locale == null) {
      if (wooSignalApp.locale != null) {
        locale = Locale(wooSignalApp.locale);
      } else {
        locale = Locale(getEnv('DEFAULT_LOCALE', defaultValue: 'en'));
      }
    }
  }

  runApp(
    AppBuild(
      navigatorKey: nylo.router.navigatorKey,
      onGenerateRoute: nylo.router.generator(),
      themeData: CurrentTheme.instance.theme,
      darkTheme: darkTheme(appTheme),
      locale: locale,
      initialRoute: initialRoute,
      supportedLocales: app_locales_supported,
      debugShowCheckedModeBanner: false,
    ),
  );
}
