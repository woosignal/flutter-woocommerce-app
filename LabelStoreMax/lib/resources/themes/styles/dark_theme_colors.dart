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
  @override
  Color get background => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['background']));
  @override
  Color get backgroundContainer => const Color(0xFF4a4a4a);

  @override
  Color get primaryContent => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['primary_text']));
  @override
  Color get primaryAccent => const Color(0xFF818181);

  @override
  Color get surfaceBackground => Color(0xFF818181);
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['app_bar_background']));
  @override
  Color get appBarPrimaryContent => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['app_bar_text']));

  @override
  Color get inputPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['button_background']));
  @override
  Color get buttonPrimaryContent => Color(int.parse(
      AppHelper.instance.appConfig.themeColors['dark']['button_text']));

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.white70;
  @override
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.white54;
  @override
  Color get bottomTabBarLabelSelected => Colors.white;
}
