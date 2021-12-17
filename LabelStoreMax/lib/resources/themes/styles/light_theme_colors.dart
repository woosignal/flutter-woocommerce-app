import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/themes/styles/base_styles.dart';

/*
|--------------------------------------------------------------------------
| Light Theme Colors
|--------------------------------------------------------------------------
*/

class LightThemeColors implements BaseColorStyles {
  // general

  Color get background => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['background']));
  Color get backgroundContainer => Colors.white;
  Color get primaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['primary_text']));
  Color get primaryAccent => const Color(0xFF87c694);

  Color get surfaceBackground => Colors.white;
  Color get surfaceContent => Colors.black;

  // app bar
  Color get appBarBackground => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['app_bar_background']));
  Color get appBarPrimaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['app_bar_text']));

  Color get inputPrimaryContent => Colors.black;

  // buttons
  Color get buttonBackground => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['button_background']));
  Color get buttonPrimaryContent => Color(int.parse(AppHelper.instance.appConfig.themeColors['light']['button_text']));

  // bottom tab bar
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  Color get bottomTabBarIconSelected => Colors.blue;
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  Color get bottomTabBarLabelUnselected => Colors.black45;
  Color get bottomTabBarLabelSelected => Colors.black;
}
