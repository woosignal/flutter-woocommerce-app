//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/widgets/compo_theme_widget.dart';
import 'package:flutter_app/resources/widgets/mello_theme_widget.dart';
import 'package:flutter_app/resources/widgets/notic_theme_widget.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  final GlobalKey _key = GlobalKey();
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  Widget build(BuildContext context) {
    Widget theme =
        MelloThemeWidget(globalKey: _key, wooSignalApp: _wooSignalApp);
    if (AppHelper.instance.appConfig!.theme == "notic") {
      theme = NoticThemeWidget(globalKey: _key, wooSignalApp: _wooSignalApp);
    }
    if (AppHelper.instance.appConfig!.theme == "compo") {
      theme = CompoThemeWidget(globalKey: _key, wooSignalApp: _wooSignalApp);
    }
    return theme;
  }
}
