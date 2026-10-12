import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/resources/themes/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Dark Theme Colors
|--------------------------------------------------------------------------
| The colours read from AppHelper.instance.appConfig!.themeColors!['dark']
| are set on your store's WooSignal dashboard, do not hardcode them.
|-------------------------------------------------------------------------- */

class DarkThemeColors extends ColorStyles {
  /// Colors for general use.
  @override
  GeneralColors get general => GeneralColors(
        background: Color(int.parse(
            AppHelper.instance.appConfig!.themeColors!['dark']['background'])),
        content: Color(int.parse(
            AppHelper.instance.appConfig!.themeColors!['dark']['primary_text'])),
        primaryAccent: const Color(0xFF818181),
        surface: const Color(0xFF818181),
        surfaceContent: Colors.black,
      );

  /// Colors for the app bar.
  @override
  AppBarColors get appBar => AppBarColors(
        background: Color(int.parse(AppHelper
            .instance.appConfig!.themeColors!['dark']['app_bar_background'])),
        content: Color(int.parse(
            AppHelper.instance.appConfig!.themeColors!['dark']['app_bar_text'])),
      );

  /// Colors for the bottom tab bar.
  @override
  BottomTabBarColors get bottomTabBar => const BottomTabBarColors(
        background: Color(0xFF232c33),
        iconSelected: Colors.white70,
        iconUnselected: Colors.white60,
        labelSelected: Colors.white,
        labelUnselected: Colors.white54,
      );

  /// Colors for the store's buttons.
  @override
  ButtonColors get button => ButtonColors(
        background: Color(int.parse(AppHelper
            .instance.appConfig!.themeColors!['dark']['button_background'])),
        content: Color(int.parse(
            AppHelper.instance.appConfig!.themeColors!['dark']['button_text'])),
        secondaryBackground: const Color(0xFFF6F6F9),
        secondaryContent: Colors.black87,
      );

  /// Colors for containers drawn on top of the background.
  @override
  ContainerColors get container =>
      const ContainerColors(background: Color(0xFF4a4a4a));

  /// Colors for form inputs.
  @override
  InputColors get input => const InputColors(content: Colors.white);
}
