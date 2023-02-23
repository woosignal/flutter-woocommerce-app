import 'package:flutter_app/resources/themes/dark_theme.dart';
import 'package:flutter_app/resources/themes/light_theme.dart';
import 'package:flutter_app/resources/themes/styles/color_styles.dart';
import 'package:flutter_app/resources/themes/styles/dark_theme_colors.dart';
import 'package:flutter_app/resources/themes/styles/light_theme_colors.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| Theme Config
|--------------------------------------------------------------------------
*/

// App Themes
final List<BaseThemeConfig<ColorStyles>> appThemes = [
  ThemeConfig.light(),
  ThemeConfig.dark(),
];

/*
|--------------------------------------------------------------------------
| Theme Colors
|--------------------------------------------------------------------------
*/

// Light Colors
ColorStyles lightColors = LightThemeColors();

// Dark Colors
ColorStyles darkColors = DarkThemeColors();

/*
|--------------------------------------------------------------------------
| Themes
|--------------------------------------------------------------------------
*/

// Preset Themes
class ThemeConfig {
  // LIGHT
  static BaseThemeConfig<ColorStyles> light() => BaseThemeConfig<ColorStyles>(
        id: "default_light_theme",
        description: "Light theme",
        theme: lightTheme(lightColors),
        colors: lightColors,
      );

  // DARK
  static BaseThemeConfig<ColorStyles> dark() => BaseThemeConfig<ColorStyles>(
        id: "default_dark_theme",
        description: "Dark theme",
        theme: darkTheme(darkColors),
        colors: darkColors,
      );

// E.G. CUSTOM THEME
  /// Run: "flutter pub run nylo_framework:main make:theme bright_theme" // example bright_theme
// Creates a basic theme in /resources/themes/bright_theme.dart
// Creates the themes colors in /resources/themes/styles/bright_theme_colors.dart

// First add the colors which was created into the above section like the following:
// Bright Colors
  /// ColorStyles brightColors = BrightThemeColors();

// Next, uncomment the below:
  /// static BaseThemeConfig<ColorStyles> bright() => BaseThemeConfig<ColorStyles>(
  ///  id: "default_bright_theme",
  ///  description: "Bright theme",
  ///  theme: brightTheme(brightColors),
  ///  colors: brightColors,
  /// );

// To then use this theme, add it to the [appThemes] above like the following:
// final appThemes = [
  ///   ThemeConfig.bright(), // new theme
//
//   ThemeConfig.light(),
//
//   ThemeConfig.dark(),
// ];
}
