//  StoreMob
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class NoConnectionPage extends NyStatefulWidget {
  static RouteView path = ("/no-connection", (_) => NoConnectionPage());

  NoConnectionPage({super.key}) : super(child: () => _NoConnectionPageState());
}

class _NoConnectionPageState extends NyPage<NoConnectionPage> {
  _NoConnectionPageState();

  @override
  get init => () {
        if (getEnv('APP_DEBUG') == true) {
          NyLogger.error('WooCommerce site is not connected');
        }
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: SafeAreaWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.black54,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  trans("Oops, something went wrong"),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Button.textOnly(text: trans("Retry"), onPressed: _retry),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retry() async {
    WooSignalApp? wooSignalApp = await (appWooSignal((api) => api.getApp()));

    if (wooSignalApp == null) {
      showToast(
          title: trans("Oops"),
          description: trans("Retry later"),
          id: 'info');
      return;
    }

    AppHelper.instance.appConfig = wooSignalApp;
    routeToInitial();
  }
}
