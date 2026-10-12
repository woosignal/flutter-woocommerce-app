import 'package:flutter/services.dart';
import '/config/storage_keys.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/bootstrap/decoders.dart';
import '/config/design.dart';
import '/bootstrap/theme.dart';
import '/bootstrap/wp_json_api_errors.dart';
import '/config/toast_notification.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/localization.dart';
import 'package:woosignal/woosignal.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AppProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await WooSignal.instance.init(
      appKey: getEnv('WOOSIGNAL_APP_KEY'),
      debugMode: getEnv('APP_DEBUG'),
      encryptKey: getEnv('ENCRYPT_KEY', defaultValue: null),
      encryptSecret: getEnv('ENCRYPT_SECRET', defaultValue: null),
    );

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
    WooSignalApp? wooSignalApp =
        await (appWooSignal((api) => api.getApp(encrypted: shouldEncrypt())));
    Locale locale = Locale('en');

    if (wooSignalApp != null) {
      AppHelper.instance.appConfig = wooSignalApp;

      if (wooSignalApp.wpLoginEnabled == 1) {
        if (wooSignalApp.wpLoginBaseUrl == null) {
          AppHelper.instance.appConfig?.wpLoginEnabled = 0;
          NyLogger.debug(
              'Set your stores domain on WooSignal. Go to Features > WP Login and add your domain to "Store Base Url"');
        }

        if (wooSignalApp.wpLoginWpApiPath == null) {
          AppHelper.instance.appConfig?.wpLoginEnabled = 0;
          NyLogger.debug(
              'Set your stores Wp JSON path on WooSignal. Go to Features > WP Login and add your Wp JSON path to "WP API Path"');
        }

        WPJsonAPI.instance.init(
            baseUrl: wooSignalApp.wpLoginBaseUrl ?? "",
            shouldDebug: getEnv('APP_DEBUG'),
            wpJsonPath: wooSignalApp.wpLoginWpApiPath ?? "",
            nylo: nylo);
      }

      if (getEnv('DEFAULT_LOCALE', defaultValue: null) == null &&
          wooSignalApp.locale != null) {
        locale = Locale(wooSignalApp.locale!);
      } else {
        locale = Locale(getEnv('DEFAULT_LOCALE', defaultValue: 'en'));
      }
    }

    // NOTE: `initialThemeId` is deliberately NOT passed. Supplying it turns off
    // NyThemeManager's followSystemTheme, which would pin nyColorStyle (i.e.
    // every context.color call) to the light palette while MaterialApp still
    // swaps to darkTheme under ThemeMode.system - dark ThemeData with light
    // colours. Omitting it makes registerThemes pick the theme from system
    // brightness, matching the v6 ThemeMode.system behaviour. A theme the user
    // picks in the drawer is still saved and restored by NyThemeManager.init().
    await nylo.configure(
      loader: DesignConfig.loader,
      logo: DesignConfig.logo,
      themes: appThemes,
      toastNotifications: ToastNotificationConfig.styles,
      modelDecoders: modelDecoders,
      controllers: controllers,
      apiDecoders: apiDecoders,
      authKey: nylo.getAuthKey() == null ? StorageKeysConfig.auth : null,
      syncKeys: StorageKeysConfig.syncedOnBoot,
      useErrorStack: true,
      localization: NyLocalizationConfig(
        localeType: LocalizationConfig.localeType,
        languageCode: locale.languageCode,
        assetsDirectory: LocalizationConfig.assetsDirectory,
      ),
    );

    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    if (AppHelper.instance.appConfig?.wpLoginEnabled == 1) {
      // Sessions saved before WP JSON API 5.0 (or with an expired token) can't
      // be used any more, so the customer starts logged out.
      await clearExpiredWpSession();
      // A customer who is still logged in: send their id and token with
      // WooSignal requests (order history, personal notifications).
      await syncWooSignalCustomer();
    }
  }
}
