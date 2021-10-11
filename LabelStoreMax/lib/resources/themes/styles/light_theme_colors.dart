import 'package:flutter/material.dart';
import 'package:flutter_app/resources/themes/styles/theme_styles.dart';

/*
|--------------------------------------------------------------------------
| Light Theme Colors
|--------------------------------------------------------------------------
*/

class LightThemeColors implements BaseStyles {
  // general
  Color get background => const Color(0xFFFFFFFF);
  Color get backgroundContainer => Colors.white;
  Color get primaryContent => const Color(0xFF000000);
  Color get primaryAccent => const Color(0xFF87c694);

  // app bar
  Color get appBarBackground => Colors.white;
  Color get appBarPrimaryContent => const Color(0xFF3a3d40);

  Color get inputPrimaryContent => Colors.black;

  // buttons
  Color get buttonBackground => const Color(0xFF529cda);
  Color get buttonPrimaryContent => Colors.white;

  // bottom tab bar
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  Color get bottomTabBarIconSelected => Colors.blue;
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  Color get bottomTabBarLabelUnselected => Colors.black45;
  Color get bottomTabBarLabelSelected => Colors.black;
}
