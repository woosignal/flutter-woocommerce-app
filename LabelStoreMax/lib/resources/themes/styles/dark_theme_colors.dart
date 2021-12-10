import 'package:flutter/material.dart';
import 'package:flutter_app/resources/themes/styles/base_styles.dart';

/*
|--------------------------------------------------------------------------
| Dark Theme Colors
|--------------------------------------------------------------------------
*/

class DarkThemeColors implements BaseColorStyles {
  // general
  Color get background => const Color(0xFF212121);
  Color get backgroundContainer => const Color(0xFF4a4a4a);

  Color get primaryContent => const Color(0xFFE1E1E1);
  Color get primaryAccent => const Color(0xFF818181);

  Color get surfaceBackground => Color(0xFF818181);
  Color get surfaceContent => Colors.black;

  // app bar
  Color get appBarBackground => const Color(0xFF2C2C2C);
  Color get appBarPrimaryContent => Colors.white;

  Color get inputPrimaryContent => Colors.white;

  // buttons
  Color get buttonBackground => Colors.white60;
  Color get buttonPrimaryContent => const Color(0xFF232c33);

  // bottom tab bar
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  Color get bottomTabBarIconSelected => Colors.white70;
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  Color get bottomTabBarLabelUnselected => Colors.white54;
  Color get bottomTabBarLabelSelected => Colors.white;
}