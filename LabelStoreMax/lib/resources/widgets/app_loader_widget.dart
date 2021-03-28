//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';

class AppLoaderWidget extends StatelessWidget {
  const AppLoaderWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveThemeMode = AdaptiveTheme.of(context).mode;
    return SpinKitDoubleBounce(
        color: adaptiveThemeMode.isLight
            ? HexColor("#424242")
            : HexColor("#c7c7c7"));
  }
}
