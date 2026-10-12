import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/bootstrap/theme.dart';
import 'package:flutter_app/config/app.dart';
import 'package:flutter_app/config/currency.dart';
import 'package:flutter_app/config/localization.dart';
import 'package:flutter_app/config/payment_gateways.dart';
import 'package:flutter_app/config/storage_keys.dart';
import 'package:flutter_app/config/toast_notification.dart';
import 'package:flutter_app/bootstrap/enums/symbol_position_enums.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/toast_notification_widget.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Configuration tests.
///
/// `lib/config/` is what a customer edits before they build the app, and
/// `lib/bootstrap/env.g.dart` is generated from their `.env`. These tests pin
/// the contract between the two, and pin the storage key strings, which are
/// the one thing here that cannot be changed without losing customer data.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
  });

  nyGroup('the encrypted env', () {
    nyTest('reads a value straight out of .env', () async {
      expect(getEnv('APP_NAME'), "MyApp");
      expect(getEnv('ASSET_PATH'), "assets");
      expect(getEnv('PRODUCT_PLACEHOLDER_IMAGE'),
          "https://woosignal.com/images/woocommerce-placeholder.png");
    });

    nyTest('reads a bool as a bool, not the string "true"', () async {
      expect(getEnv('APP_DEBUG'), isA<bool>());
      expect(getEnv('APP_DEBUG'), isTrue);
      expect(getEnv('SHOW_SPLASH_SCREEN'), isFalse);
    });

    nyTest('reads the literal null in .env as null', () async {
      // `DEFAULT_LOCALE=null` is how this template says "let the store decide".
      expect(getEnv('DEFAULT_LOCALE'), isNull);
      expect(getEnv('ENCRYPT_KEY'), isNull);
      expect(getEnv('FCM_ENABLED'), isNull);
    });

    nyTest('falls back to the default for a key that is not there', () async {
      expect(getEnv('A_KEY_THAT_DOES_NOT_EXIST'), isNull);
      expect(getEnv('A_KEY_THAT_DOES_NOT_EXIST', defaultValue: "fallback"),
          "fallback");
      expect(getEnv('A_KEY_THAT_DOES_NOT_EXIST', defaultValue: 7), 7);
    });

    nyTest('the keys the app cannot start without are all set', () async {
      expectEnvSet('APP_NAME');
      expectEnvSet('WOOSIGNAL_APP_KEY');
      expectEnvSet('ASSET_PATH');
      expectEnvSet('API_BASE_URL');
    });

    nyTest('the WooSignal key is its own, not Nylo\'s APP_KEY', () async {
      // Nylo reserves APP_KEY to encrypt env.g.dart, so the store key had to
      // move to a name of its own.
      expect(getEnv('WOOSIGNAL_APP_KEY'), isNotNull);
      expect(getEnv('WOOSIGNAL_APP_KEY'), isNot(getEnv('APP_KEY')));
    });

    nyTest('assets resolve under assets/', () async {
      expect(getAsset('json/default_shipping.json'),
          "assets/json/default_shipping.json");
    });
  });

  nyGroup('AppConfig', () {
    nyTest('mirrors the env', () async {
      expect(AppConfig.appName, getEnv('APP_NAME'));
      expect(AppConfig.version, getEnv('APP_VERSION'));
      expect(AppConfig.appUrl, getEnv('APP_URL'));
      expect(AppConfig.environment, getEnv('APP_ENV'));
      expect(AppConfig.apiBaseUrl, getEnv('API_BASE_URL'));
      expect(AppConfig.assetPath, getEnv('ASSET_PATH'));
    });

    nyTest('keeps the splash screen off by default', () async {
      // The template holds the native launch screen for the whole boot.
      expect(AppConfig.showSplashScreen, isFalse);
    });
  });

  nyGroup('storage keys', () {
    nyTest('are the exact strings already on customers\' devices', () async {
      // Every one of these names data persisted by an earlier release.
      // Changing a string here orphans that data on the next app update.
      expect(StorageKeysConfig.cart, "CART_SESSION");
      expect(StorageKeysConfig.customerBillingDetails, "CS_BILLING_DETAILS");
      expect(StorageKeysConfig.customerShippingDetails, "CS_SHIPPING_DETAILS");
      expect(StorageKeysConfig.wishlistProducts, "CS_WISHLIST_PRODUCTS");
      expect(StorageKeysConfig.auth, "wp_json_api");
    });

    nyTest('the auth key is the one synced on boot', () async {
      expect(await StorageKeysConfig.syncedOnBoot()(),
          [StorageKeysConfig.auth]);
    });
  });

  nyGroup('localization', () {
    nyTest('every supported locale has a language file, and vice versa',
        () async {
      List<String> declared = LocalizationConfig.supportedLocales
          .map((locale) => locale.languageCode)
          .toList()
        ..sort();

      List<String> onDisk = Directory('lang')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .where((name) => name.endsWith('.json'))
          .map((name) => name.replaceAll('.json', ''))
          .toList()
        ..sort();

      expect(declared, onDisk,
          reason: 'lib/config/localization.dart and lang/ must agree - a '
              'locale listed with no file falls back to raw keys, and a file '
              'with no locale can never be selected');
      expect(declared.length, 12);
    });

    nyTest('English is the fallback and the language files live in lang/',
        () async {
      expect(LocalizationConfig.fallbackLanguageCode, "en");
      expect(LocalizationConfig.assetsDirectory, "lang/");
      expect(LocalizationConfig.localeType, LocaleType.asDefined);
    });

    nyTest('the language code is nullable so the store can choose', () async {
      // .env ships DEFAULT_LOCALE=null, which lets the store's own locale win.
      expect(LocalizationConfig.languageCode, isNull);
    });

    nyTest('knows which languages read right to left', () async {
      expect(LocalizationConfig.isRtl('ar'), isTrue);
      expect(LocalizationConfig.isRtl('he'), isTrue);
      expect(LocalizationConfig.isRtl('fa'), isTrue);
      expect(LocalizationConfig.isRtl('ur'), isTrue);
      expect(LocalizationConfig.isRtl('en'), isFalse);
    });
  });

  nyGroup('toast styles', () {
    nyTest('registers the four ids the app shows toasts with', () async {
      expect(ToastNotificationConfig.styles.keys.toSet(),
          {'success', 'warning', 'info', 'danger'});
    });

    nyTest('each style builds the app\'s own toast widget', () async {
      for (String id in ToastNotificationConfig.styles.keys) {
        ToastStyleFactory factory = ToastNotificationConfig.styles[id];
        Widget toast = factory(
            ToastMeta(title: "A title", description: "A description"),
            (_) {});

        expect(toast, isA<ToastNotification>(), reason: 'style "$id"');
      }
    });

    nyWidgetTest(
        'a style falls back to its own title when the call site gives none',
        (tester) async {
      Map<String, String> defaultTitles = {
        'success': "Success",
        'warning': "Warning",
        'info': "Info",
        'danger': "Oops",
      };

      for (MapEntry<String, String> entry in defaultTitles.entries) {
        ToastStyleFactory factory = ToastNotificationConfig.styles[entry.key];

        await tester.pumpNyWidgetSimple(Scaffold(
            body: factory(
                ToastMeta(title: "", description: "A description"), (_) {})));

        expect(find.text(entry.value), findsOneWidget,
            reason: 'style "${entry.key}" must supply its own title');
        expect(find.text("A description"), findsOneWidget);
      }
    });

    nyWidgetTest('a style keeps the title the call site gives it',
        (tester) async {
      ToastStyleFactory factory = ToastNotificationConfig.styles['danger'];

      await tester.pumpNyWidgetSimple(Scaffold(
          body: factory(
              ToastMeta(title: "Invalid details", description: "Nope"),
              (_) {})));

      expect(find.text("Invalid details"), findsOneWidget);
      expect(find.text("Oops"), findsNothing);
      expect(find.text("Nope"), findsOneWidget);
    });
  });

  nyGroup('themes', () {
    nyTest('registers the two theme ids the drawer toggles between', () async {
      expect(appThemes.map((theme) => theme.id),
          ["default_light_theme", "default_dark_theme"]);
      expect(appThemes.map((theme) => theme.type),
          [NyThemeType.light, NyThemeType.dark]);
    });
  });

  nyGroup('currency and payment gateways', () {
    nyTest('the currency symbol sits on the left by default', () async {
      expect(appCurrencySymbolPosition, SymbolPositionType.left);
    });

    nyTest('ships with no gateway forced on, so the store decides', () async {
      expect(appPaymentGateways, isEmpty);
    });

    nyTest('the gateway list holds the three enabled gateways', () async {
      expect(paymentTypeList.map((paymentType) => paymentType.name),
          ["Stripe", "CashOnDelivery", "PayPal"]);
      expect(paymentTypeList.map((paymentType) => paymentType.id), [1, 2, 4]);
      expect(paymentTypeList.map((paymentType) => paymentType.assetImage), [
        "dark_powered_by_stripe.png",
        "cash_on_delivery.jpeg",
        "paypal_logo.png",
      ]);
    });

    nyTest('offers nothing when the store has every gateway switched off',
        () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(
              stripeEnabled: false, paypalEnabled: false, codEnabled: false));

      expect(await getPaymentTypes(), isEmpty);
    });

    nyTest('offers the gateways the store has switched on', () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(
              stripeEnabled: true, paypalEnabled: true, codEnabled: false));

      List<PaymentType?> paymentTypes = await getPaymentTypes();

      expect(paymentTypes.map((paymentType) => paymentType!.name),
          ["Stripe", "PayPal"]);
    });

    nyTest('offers cash on delivery when the store enables it', () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(codEnabled: true));

      expect((await getPaymentTypes()).single!.name, "CashOnDelivery");
    });
  });
}
