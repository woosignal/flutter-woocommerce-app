import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/themes/styles/base_styles.dart';

/*
|--------------------------------------------------------------------------
| Dark Theme Colors
|--------------------------------------------------------------------------
*/

class DarkThemeColors implements BaseColorStyles {
  // general
  Color get background => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['background']));
  Color get backgroundContainer => const Color(0xFF4a4a4a);

  Color get primaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['primary_text']));
  Color get primaryAccent => const Color(0xFF818181);

  Color get surfaceBackground => Color(0xFF818181);
  Color get surfaceContent => Colors.black;

  // app bar
  Color get appBarBackground => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['app_bar_background']));
  Color get appBarPrimaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['app_bar_text']));

  Color get inputPrimaryContent => Colors.white;

  // buttons
  Color get buttonBackground => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['button_background']));
  Color get buttonPrimaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['dark']['button_text']));

  // bottom tab bar
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  Color get bottomTabBarIconSelected => Colors.white70;
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  Color get bottomTabBarLabelUnselected => Colors.white54;
  Color get bottomTabBarLabelSelected => Colors.white;
}