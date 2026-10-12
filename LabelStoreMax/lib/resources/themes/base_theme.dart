import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/bootstrap/app_helper.dart';
import '/config/design.dart';
import '/resources/themes/color_styles.dart';
import '/resources/themes/default_text_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Base Theme Builder
|--------------------------------------------------------------------------
| Shared theme configuration for the light and dark themes.
| Theme Config - bootstrap/theme.dart
|-------------------------------------------------------------------------- */

ThemeData buildAppTheme(ColorStyles color, {required Brightness brightness}) {
  final bool isDark = brightness == Brightness.dark;

  try {
    DesignConfig.appFont = GoogleFonts.getFont(
        AppHelper.instance.appConfig!.themeFont ?? "Poppins");
  } on Exception catch (e) {
    if (getEnv('APP_DEBUG') == true) {
      NyLogger.error(e.toString());
    }
  }

  TextTheme textTheme = getAppTextTheme(
      DesignConfig.appFont, defaultTextTheme.merge(_textTheme(color, isDark)));

  return ThemeData(
    useMaterial3: true,
    primaryColor: color.general.content,
    primaryColorLight: isDark ? null : color.general.primaryAccent,
    primaryColorDark: isDark ? color.general.content : null,
    brightness: brightness,
    focusColor: color.general.content,
    scaffoldBackgroundColor: color.general.background,
    hintColor: isDark ? null : color.general.primaryAccent,
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: color.appBar.background,
      titleTextStyle:
          textTheme.titleLarge!.copyWith(color: color.appBar.content),
      iconTheme: IconThemeData(color: color.appBar.content),
      elevation: 1.0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: isDark ? color.general.primaryAccent : color.button.content,
      colorScheme: ColorScheme.light(primary: color.button.background),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: color.general.content),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: color.button.content,
          backgroundColor: color.button.background),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBar.background,
      unselectedIconTheme:
          IconThemeData(color: color.bottomTabBar.iconUnselected),
      selectedIconTheme: IconThemeData(color: color.bottomTabBar.iconSelected),
      unselectedLabelStyle:
          TextStyle(color: color.bottomTabBar.labelUnselected),
      selectedLabelStyle: TextStyle(color: color.bottomTabBar.labelSelected),
      selectedItemColor: color.bottomTabBar.labelSelected,
    ),
    textTheme: textTheme,
    colorScheme: isDark
        ? ColorScheme.dark(
            surface: color.general.background, primary: color.general.content)
        : ColorScheme.light(
            surface: color.general.background, primary: color.general.content),
  );
}

/*
|--------------------------------------------------------------------------
| Text Theme
|--------------------------------------------------------------------------
*/

TextTheme _textTheme(ColorStyles colors, bool isDark) {
  Color primaryContent = colors.general.content;
  TextTheme textTheme = TextTheme().apply(displayColor: primaryContent);

  if (isDark) {
    return textTheme.copyWith(
        titleLarge: TextStyle(color: primaryContent.withValues(alpha: 0.8)),
        labelLarge: TextStyle(color: primaryContent.withValues(alpha: 0.8)),
        bodySmall: TextStyle(color: primaryContent.withValues(alpha: 0.8)),
        bodyMedium: TextStyle(color: primaryContent.withValues(alpha: 0.8)));
  }

  return textTheme.copyWith(
    labelLarge: TextStyle(color: primaryContent.withValues(alpha: 0.8)),
    bodyMedium: TextStyle(color: primaryContent.withValues(alpha: 0.8)),
  );
}
