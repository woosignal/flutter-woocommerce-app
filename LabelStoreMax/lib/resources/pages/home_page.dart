//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/account_order_detail_page.dart';
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/compo_theme_widget.dart';
import '/resources/widgets/mello_theme_widget.dart';
import '/resources/widgets/notic_theme_widget.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class HomePage extends StatefulWidget {
  
  static String path = "/home";
  HomePage();

  @override
  createState() => _HomePageState();
}

class _HomePageState extends NyState<HomePage> {
  _HomePageState();

  final GlobalKey _key = GlobalKey();
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  init() async {
    await _enableFcmNotifications();
  }

  _enableFcmNotifications() async {
    bool? firebaseFcmIsEnabled = AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      /// WP Notify - Product notification
      if (message.data.containsKey('product_id')) {
        routeTo(ProductDetailPage.path, data: int.parse(message.data['product_id']));
      }
      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        routeTo(AccountOrderDetailPage.path, data: int.parse(message.data['order_id']));
      }
    });
  }

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
