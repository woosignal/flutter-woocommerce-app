import 'package:flutter/material.dart';
import '/resources/themes/base_theme.dart';
import '/resources/themes/color_styles.dart';

/* Light Theme
|--------------------------------------------------------------------------
| Theme Config - bootstrap/theme.dart
|-------------------------------------------------------------------------- */

ThemeData lightTheme(ColorStyles color) =>
    buildAppTheme(color, brightness: Brightness.light);
