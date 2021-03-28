import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
|--------------------------------------------------------------------------
| APP THEME
|
| Change the font and colors for your themes.
|--------------------------------------------------------------------------
*/

// Theme main font
final TextStyle appThemeFont = GoogleFonts.overpass();

// Theme colors
class AppColors {
  // MAIN
  Color _mainLightColor = Color(0xFF232c33);
  Color _mainDarkColor = Color(0xFFFAFAFA);

  // SECONDARY
  Color _secondLightColor = Color(0xFF232c33);
  Color _secondDarkColor = Color(0xFFF1F1F1);

  // ACCENT
  Color _accentLightColor = Color(0xFF465f81);
  Color _accentDarkColor = Color(0xFF4a4a4a);

  // SCAFFOLD
  Color _scaffoldDarkColor = Color(0xFF2C2C2C);
  Color _scaffoldLightColor = Color(0xFFFAFAFA);
}

class AppTheme extends AppColors {
  Color mainColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _mainLightColor.withOpacity(opacity)
        : _mainDarkColor.withOpacity(opacity));
  }

  Color secondColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _secondLightColor.withOpacity(opacity)
        : _secondDarkColor.withOpacity(opacity));
  }

  Color accentColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _accentLightColor.withOpacity(opacity)
        : _accentDarkColor.withOpacity(opacity));
  }

  Color scaffoldColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _scaffoldLightColor.withOpacity(opacity)
        : _scaffoldDarkColor.withOpacity(opacity));
  }
}
