//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/compo_theme_widget.dart';
import '/resources/widgets/mello_theme_widget.dart';
import '/resources/widgets/notic_theme_widget.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class HomePage extends NyStatefulWidget {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  Widget view(BuildContext context) {
    return match(
        AppHelper.instance.appConfig?.theme,
        () => {
              "notic": NoticThemeWidget(wooSignalApp: _wooSignalApp),
              "compo": CompoThemeWidget(wooSignalApp: _wooSignalApp),
              "mello": MelloThemeWidget(wooSignalApp: _wooSignalApp),
            },
        defaultValue: MelloThemeWidget(wooSignalApp: _wooSignalApp));
  }
}
