import 'package:nylo_framework/nylo_framework.dart';

/* App
|--------------------------------------------------------------------------
| Application configuration settings.
| Learn more: https://nylo.dev/docs/7.x/configuration
| -------------------------------------------------------------------------
| You can access these configuration values throughout your app using:
| `AppConfig.appName`, `AppConfig.version`, etc.
|
| Values come from your .env file, run
| "dart run nylo_framework:main make:env" after you change it.
|-------------------------------------------------------------------------- */

final class AppConfig {
  // The name of the application.
  static final String appName = getEnv('APP_NAME', defaultValue: 'MyApp');

  // The version of the application.
  static final String version = getEnv('APP_VERSION', defaultValue: '1.0.0');

  // The URL of the application.
  static final String appUrl =
      getEnv('APP_URL', defaultValue: 'https://mywoocommercestore.com');

  // The current environment of the application.
  static final String environment =
      getEnv('APP_ENV', defaultValue: 'developing');

  // The base URL for the application's API.
  static final String apiBaseUrl =
      getEnv('API_BASE_URL', defaultValue: 'https://mywoocommercestore.com');

  // The path to the assets directory.
  static final String assetPath = getEnv('ASSET_PATH', defaultValue: 'assets');

  // Whether to show the splash screen on app startup.
  // Off by default - this template keeps the native launch screen on screen
  // for the whole boot. See resources/widgets/splash_screen.dart.
  static final bool showSplashScreen =
      getEnv('SHOW_SPLASH_SCREEN', defaultValue: false);
}
