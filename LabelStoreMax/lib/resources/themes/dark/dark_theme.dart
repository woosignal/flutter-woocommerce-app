import 'package:flutter/material.dart';
import '/resources/themes/base_theme.dart';
import '/resources/themes/color_styles.dart';

/* Dark Theme
|--------------------------------------------------------------------------
| Theme Config - bootstrap/theme.dart
|-------------------------------------------------------------------------- */

ThemeData darkTheme(ColorStyles color) =>
    buildAppTheme(color, brightness: Brightness.dark);
