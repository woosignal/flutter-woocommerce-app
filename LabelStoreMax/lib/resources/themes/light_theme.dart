import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/config/font.dart';
import 'package:flutter_app/resources/themes/styles/color_styles.dart';
import 'package:flutter_app/resources/themes/text_theme/default_text_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| Light Theme
|
| Theme Config - config/theme.dart
|--------------------------------------------------------------------------
*/

ThemeData lightTheme(ColorStyles lightColors) {
  try {
    appFont = GoogleFonts.getFont(
        AppHelper.instance.appConfig!.themeFont ?? "Poppins");
  } on Exception catch (e) {
    if (getEnv('APP_DEBUG') == true) {
      NyLogger.error(e.toString());
    }
  }

  TextTheme lightTheme =
      getAppTextTheme(appFont, defaultTextTheme.merge(_textTheme(lightColors)));

  return ThemeData(
    primaryColor: lightColors.primaryContent,
    primaryColorLight: lightColors.primaryAccent,
    focusColor: lightColors.primaryContent,
    scaffoldBackgroundColor: lightColors.background,
    hintColor: lightColors.primaryAccent,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColors.appBarBackground,
      titleTextStyle: lightTheme.titleLarge!
          .copyWith(color: lightColors.appBarPrimaryContent),
      iconTheme: IconThemeData(color: lightColors.appBarPrimaryContent),
      elevation: 1.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightColors.buttonPrimaryContent,
      colorScheme: ColorScheme.light(primary: lightColors.buttonBackground),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: lightColors.primaryContent),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: lightColors.buttonPrimaryContent,
          backgroundColor: lightColors.buttonBackground),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightColors.bottomTabBarBackground,
      unselectedIconTheme:
          IconThemeData(color: lightColors.bottomTabBarIconUnselected),
      selectedIconTheme:
          IconThemeData(color: lightColors.bottomTabBarIconSelected),
      unselectedLabelStyle:
          TextStyle(color: lightColors.bottomTabBarLabelUnselected),
      selectedLabelStyle:
          TextStyle(color: lightColors.bottomTabBarLabelSelected),
      selectedItemColor: lightColors.bottomTabBarLabelSelected,
    ),
    textTheme: lightTheme,
    colorScheme:
        ColorScheme.light().copyWith(background: lightColors.background),
  );
}

/*
|--------------------------------------------------------------------------
| Light Text Theme
|--------------------------------------------------------------------------
*/

TextTheme _textTheme(ColorStyles colors) {
  Color primaryContent = colors.primaryContent;
  TextTheme textTheme = TextTheme().apply(displayColor: primaryContent);
  return textTheme.copyWith(
    labelLarge: TextStyle(color: primaryContent.withOpacity(0.8)),
    bodyMedium: TextStyle(color: primaryContent.withOpacity(0.8)),
  );
}
