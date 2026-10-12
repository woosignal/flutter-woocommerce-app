import 'package:nylo_framework/nylo_framework.dart';

/* Localization
|--------------------------------------------------------------------------
| Application configuration settings.
| Learn more: https://nylo.dev/docs/7.x/configuration
| -------------------------------------------------------------------------
| You can access these config values throughout your app using:
| `LocalizationConfig.languageCode`, `LocalizationConfig.localeType`, etc.
|-------------------------------------------------------------------------- */

final class LocalizationConfig {
  // The language code should match the name of the file i.e /lang/es.json
  //
  // Nullable on purpose: this template ships DEFAULT_LOCALE=null so the store's
  // locale from WooSignal wins. See app/providers/app_provider.dart.
  static final String? languageCode =
      getEnv('DEFAULT_LOCALE', defaultValue: "en");

  // LocaleType defines how locales are managed in the app.
  static final LocaleType localeType = LocaleType.asDefined; // device, asDefined

  // Directory where language JSON files are stored
  static const String assetsDirectory = 'lang/';

  // Supported locales in the application.
  // One entry per file in lang/ - keep the two in sync.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('th'),
    Locale('tr'),
    Locale('zh'),
  ];

  // Fallback language code if a translation is missing
  static const String fallbackLanguageCode = 'en';

  // List of language codes that use right-to-left text direction
  static const List<String> rtlLanguages = <String>['ar', 'he', 'fa', 'ur'];

  // Check if a language code uses right-to-left text direction
  static bool isRtl(String languageCode) => rtlLanguages.contains(languageCode);

  // Enable debug mode for missing translation keys
  static final bool debugMissingKeys =
      getEnv('DEBUG_TRANSLATIONS', defaultValue: 'false') == 'true';
}
