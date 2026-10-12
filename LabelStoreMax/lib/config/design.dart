import 'package:flutter/material.dart';
import '/resources/widgets/store_logo_widget.dart';
import '/resources/widgets/app_loader_widget.dart';
import 'package:google_fonts/google_fonts.dart';

/* Design
|--------------------------------------------------------------------------
| Application configuration settings.
| Learn more: https://nylo.dev/docs/7.x/configuration
| -------------------------------------------------------------------------
| You can access these config values throughout your app using:
| `DesignConfig.appFont`, `DesignConfig.logo`, etc.
|
| Toast notification styles are defined in config/toast_notification.dart
| and registered with Nylo via configure(toastNotifications: ...).
|-------------------------------------------------------------------------- */

final class DesignConfig {
  // App Font - Google Fonts
  //
  // Deliberately NOT `final`: resources/themes/{light,dark} replace this at
  // runtime with the font configured for the store on WooSignal
  // (AppHelper.instance.appConfig!.themeFont), falling back to Poppins.
  // e.g. updating the font from "poppins" to "lato" - GoogleFonts.lato()
  // Custom font in pubspec.yaml? https://flutter.dev/docs/cookbook/design/fonts
  // e.g. TextStyle(fontFamily: "ZenTokyoZoo")
  static TextStyle appFont = GoogleFonts.poppins();

  // App Logo - resources/widgets/store_logo_widget.dart
  static final Widget logo = StoreLogo();

  // App Loader - resources/widgets/app_loader_widget.dart
  static final Widget loader = AppLoaderWidget();
}
