import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:nylo_support/helpers/helper.dart';

/*
|--------------------------------------------------------------------------
| Default Theme
|
| Theme Config - config/app_theme.dart
|--------------------------------------------------------------------------
*/

ThemeData defaultTheme(AppTheme appTheme) => ThemeData(
      primaryColor: appTheme.mainColor(),
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      accentColor: appTheme.accentColor(),
      primaryColorLight: appTheme.accentColor(
        brightness: Brightness.light,
      ),
      primaryColorDark: appTheme.accentColor(
        brightness: Brightness.dark,
      ),
      accentColorBrightness: Brightness.light,
      accentTextTheme: _defaultTextTheme(appTheme).apply(
        bodyColor: appTheme.accentColor(),
        displayColor: appTheme.accentColor(),
      ),
      focusColor: appTheme.accentColor(),
      scaffoldBackgroundColor: appTheme.scaffoldColor(),
      primaryTextTheme: _defaultTextTheme(appTheme).copyWith(
          bodyText2: TextStyle(color: Colors.grey),
          bodyText1: TextStyle(color: Colors.grey)),
      hintColor: appTheme.secondColor(),
      appBarTheme: AppBarTheme(
        color: Colors.white,
        textTheme: getAppTextTheme(appThemeFont, _defaultTextTheme(appTheme)),
        iconTheme: IconThemeData(color: appTheme.mainColor()),
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      buttonColor: Colors.white,
      buttonTheme: ButtonThemeData(
        buttonColor: appTheme.accentColor(),
      ),
      textTheme: getAppTextTheme(appThemeFont, _defaultTextTheme(appTheme)),
    );

TextTheme _defaultTextTheme(AppTheme appTheme) {
  return TextTheme(
    headline5: TextStyle(
      fontSize: 22.0,
      color: appTheme.secondColor(),
    ),
    headline4: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: appTheme.secondColor(),
    ),
    headline3: TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.w700,
      color: appTheme.secondColor(),
    ),
    headline2: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
      color: appTheme.mainColor(),
    ),
    headline1: TextStyle(
      fontSize: 36.0,
      fontWeight: FontWeight.w300,
      color: appTheme.secondColor(),
    ),
    subtitle2: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: appTheme.secondColor(),
    ),
    subtitle1: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: appTheme.secondColor(),
    ),
    overline: TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.w400,
      color: appTheme.secondColor(),
    ),
    button: TextStyle(
      color: Colors.white,
    ),
    headline6: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: appTheme.mainColor(),
    ),
    bodyText2: TextStyle(
      fontSize: 14.0,
      color: appTheme.secondColor(),
    ),
    bodyText1: TextStyle(
        fontSize: 16.0,
        color: appTheme.secondColor(),
        fontWeight: FontWeight.bold),
    caption: TextStyle(
        fontSize: 16.0,
        color: appTheme.accentColor(),
        fontWeight: FontWeight.bold),
  );
}
