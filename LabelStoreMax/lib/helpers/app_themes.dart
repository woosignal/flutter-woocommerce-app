//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:label_storemax/helpers/tools.dart';

TextTheme textThemeAccent() {
  return TextTheme(
    display1: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w800,
        fontSize: 26),
    display2: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    display3: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    display4: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    headline: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    title: new TextStyle(
      color: Colors.black,
      fontFamily: appFontFamily,
    ),
    subhead: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w800),
    body2: new TextStyle(
        color: HexColor("#606060"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700),
    body1: new TextStyle(
        color: HexColor("#a8a8a8"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 18),
    caption: new TextStyle(
        color: HexColor("#2a5080"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 14),
    button: new TextStyle(
        color: Colors.white,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700),
  );
}

TextTheme textThemePrimary() {
  return TextTheme(
    display1: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w800,
        fontSize: 26),
    display2: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    display3: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    display4: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600),
    headline: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    title: new TextStyle(
      color: Colors.black,
      fontFamily: appFontFamily,
    ),
    subhead: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w800),
    body2: new TextStyle(
        color: HexColor("#606060"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700),
    body1: new TextStyle(
        color: HexColor("#a8a8a8"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 18),
    caption: new TextStyle(
        color: HexColor("#2a5080"),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 14),
    button: new TextStyle(
        color: Colors.white,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w700),
  );
}

TextTheme textThemeMain() {
  return TextTheme(
    display1: new TextStyle(
      color: Colors.black,
      fontFamily: appFontFamily,
    ),
    display2: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    display3: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    display4: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    headline: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    title: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    subhead: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    body2: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    body1: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    caption: new TextStyle(
        color: Colors.redAccent, fontSize: 16, fontFamily: appFontFamily),
    button: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
  );
}

TextTheme textThemeAppBar() {
  return TextTheme(
    display1: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    display2: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    display3: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    display4: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    headline: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    title: new TextStyle(
        color: Colors.black,
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w900),
    subhead: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    body2: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    body1: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    caption: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
    button: new TextStyle(color: Colors.black, fontFamily: appFontFamily),
  );
}

ColorScheme colorSchemeButton() {
  return ColorScheme.light(
      primary: const Color(0xff6200ee),
      primaryVariant: const Color(0xff3700b3),
      secondary: const Color(0xff03dac6),
      secondaryVariant: const Color(0xff018786),
      surface: Colors.white,
      background: Colors.white,
      error: const Color(0xffb00020),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light);
}
