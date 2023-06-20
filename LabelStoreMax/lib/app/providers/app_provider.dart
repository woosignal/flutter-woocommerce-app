import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/config/design.dart';
import 'package:flutter_app/config/theme.dart';
import 'package:flutter_app/config/validation_rules.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/config/localization.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/woosignal.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AppProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await WooSignal.instance
        .init(appKey: getEnv('APP_KEY'), debugMode: getEnv('APP_DEBUG'));

    AppHelper.instance.appConfig = WooSignalApp();
    AppHelper.instance.appConfig!.themeFont = "Poppins";
    AppHelper.instance.appConfig!.themeColors = {
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
    WooSignalApp? wooSignalApp = await (appWooSignal((api) => api.getApp()));
    Locale locale = Locale('en');

    if (wooSignalApp != null) {
      AppHelper.instance.appConfig = wooSignalApp;

      if (wooSignalApp.wpLoginEnabled == 1) {
        if (wooSignalApp.wpLoginBaseUrl == null) {
          AppHelper.instance.appConfig?.wpLoginEnabled = 0;
          log('Set your stores domain on WooSignal. Go to Features > WP Login and add your domain to "Store Base Url"');
        }

        if (wooSignalApp.wpLoginWpApiPath == null) {
          AppHelper.instance.appConfig?.wpLoginEnabled = 0;
          log('Set your stores Wp JSON path on WooSignal. Go to Features > WP Login and add your Wp JSON path to "WP API Path"');
        }

        WPJsonAPI.instance.initWith(
          baseUrl: wooSignalApp.wpLoginBaseUrl ?? "",
          shouldDebug: getEnv('APP_DEBUG'),
          wpJsonPath: wooSignalApp.wpLoginWpApiPath ?? "",
        );
      }

      if (getEnv('DEFAULT_LOCALE', defaultValue: null) == null &&
          wooSignalApp.locale != null) {
        locale = Locale(wooSignalApp.locale!);
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

    nylo.appThemes = appThemes;
    nylo.appLoader = loader;
    nylo.appLogo = logo;

    nylo.addModelDecoders(modelDecoders);
    nylo.addValidationRules(validationRules);

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {

  }
}