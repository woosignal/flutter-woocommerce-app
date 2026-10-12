import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/resources/themes/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Light Theme Colors
|--------------------------------------------------------------------------
| The colours read from AppHelper.instance.appConfig!.themeColors!['light']
| are set on your store's WooSignal dashboard, do not hardcode them.
|-------------------------------------------------------------------------- */

class LightThemeColors extends ColorStyles {
  /// Colors for general use.
  @override
  GeneralColors get general => GeneralColors(
        background: Color(int.parse(
            AppHelper.instance.appConfig!.themeColors!['light']['background'])),
        content: Color(int.parse(AppHelper
            .instance.appConfig!.themeColors!['light']['primary_text'])),
        primaryAccent: const Color(0xFF87c694),
        surface: Colors.white,
        surfaceContent: Colors.black,
      );

  /// Colors for the app bar.
  @override
  AppBarColors get appBar => AppBarColors(
        background: Color(int.parse(AppHelper.instance.appConfig!
            .themeColors!['light']['app_bar_background'])),
        content: Color(int.parse(AppHelper
            .instance.appConfig!.themeColors!['light']['app_bar_text'])),
      );

  /// Colors for the bottom tab bar.
  @override
  BottomTabBarColors get bottomTabBar => const BottomTabBarColors(
        background: Colors.white,
        iconSelected: Colors.blue,
        iconUnselected: Colors.black54,
        labelSelected: Colors.black,
        labelUnselected: Colors.black45,
      );

  /// Colors for the store's buttons.
  @override
  ButtonColors get button => ButtonColors(
        background: Color(int.parse(AppHelper.instance.appConfig!
            .themeColors!['light']['button_background'])),
        content: Color(int.parse(AppHelper
            .instance.appConfig!.themeColors!['light']['button_text'])),
        secondaryBackground: const Color(0xFFF6F6F9),
        secondaryContent: Colors.black87,
      );

  /// Colors for containers drawn on top of the background.
  @override
  ContainerColors get container =>
      const ContainerColors(background: Colors.white);

  /// Colors for form inputs.
  @override
  InputColors get input => const InputColors(content: Colors.black);
}
