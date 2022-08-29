import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/themes/styles/color_styles.dart';

/*
|--------------------------------------------------------------------------
| Light Theme Colors
|--------------------------------------------------------------------------
*/

class LightThemeColors implements ColorStyles {
  // general

  @override
  Color get background => Color(int.parse(
      AppHelper.instance.appConfig!.themeColors!['light']['background']));
  @override
  Color get backgroundContainer => Colors.white;
  @override
  Color get primaryContent => Color(int.parse(
      AppHelper.instance.appConfig!.themeColors!['light']['primary_text']));
  @override
  Color get primaryAccent => const Color(0xFF87c694);

  @override
  Color get surfaceBackground => Colors.white;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground =>
      Color(int.parse(AppHelper.instance.appConfig!.themeColors!['light']
          ['app_bar_background']));
  @override
  Color get appBarPrimaryContent => Color(int.parse(
      AppHelper.instance.appConfig!.themeColors!['light']['app_bar_text']));

  @override
  Color get inputPrimaryContent => Colors.black;

  // buttons
  @override
  Color get buttonBackground =>
      Color(int.parse(AppHelper.instance.appConfig!.themeColors!['light']
          ['button_background']));
  @override
  Color get buttonPrimaryContent => Color(int.parse(
      AppHelper.instance.appConfig!.themeColors!['light']['button_text']));

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.blue;
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;
}
