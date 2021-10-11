import 'package:flutter/material.dart';
import 'package:flutter_app/resources/themes/styles/dark_theme_colors.dart';
import 'package:flutter_app/resources/themes/styles/light_theme_colors.dart';
import 'package:flutter_app/resources/themes/styles/theme_styles.dart';
import 'package:google_fonts/google_fonts.dart';

/*
|--------------------------------------------------------------------------
| Theme Font
|
| Uses Google Fonts - https://pub.dev/packages/google_fonts
|
| e.g. updating the font from "montserrat" to "lato"
| before: final TextStyle appThemeFont = GoogleFonts.montserrat();
| after:  final TextStyle appThemeFont = GoogleFonts.lato();
|--------------------------------------------------------------------------
*/

final TextStyle appThemeFont = GoogleFonts.overpass();

// e.g. custom font in pubspec.yaml - https://flutter.dev/docs/cookbook/design/fonts
// final TextStyle appThemeFont = TextStyle(fontFamily: "ZenTokyoZoo");

/*
|--------------------------------------------------------------------------
| Theme Colors
|
| Customize your theme's light and dark themes: /lib/config/styles/
|--------------------------------------------------------------------------
*/

class NyColors {
  // Light Colors
  static LightThemeColors light = LightThemeColors();

  // Dark Colors
  static DarkThemeColors dark = DarkThemeColors();

  /// helper to find correct theme from the [context].
  static BaseStyles of(BuildContext context) {
    return ((Theme.of(context).brightness == Brightness.dark) ? dark : light);
  }
}