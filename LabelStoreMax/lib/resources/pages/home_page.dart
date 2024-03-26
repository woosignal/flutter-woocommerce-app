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
import '/resources/pages/account_order_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/events/firebase_on_message_order_event.dart';
import '/app/events/order_notification_event.dart';
import '/app/events/product_notification_event.dart';
import '/bootstrap/helpers.dart';
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

  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  init() async {
    await _enableFcmNotifications();
  }

  _enableFcmNotifications() async {
    bool? firebaseFcmIsEnabled =
        AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      /// WP Notify - Product notification
      if (message.data.containsKey('product_id')) {
        event<ProductNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        event<OrderNotificationEvent>(data: {"RemoteMessage": message});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        event<FirebaseOnMessageOrderEvent>(data: {"RemoteMessage": message});
        _maybeShowSnackBar(message);
      }
    });
  }

  /// Attempt to show a snackbar if the user is on the same page
  _maybeShowSnackBar(RemoteMessage message) async {
    if (!(await canSeeRemoteMessage(message))) {
      return;
    }
    _showSnackBar(message.notification?.body, onPressed: () {
      routeTo(AccountOrderDetailPage.path,
          data: int.parse(message.data['order_id']));
    });
  }

  _showSnackBar(String? message, {Function()? onPressed}) {
    SnackBar snackBar = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'New notification received'.tr()} 🚨',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          if (message != null) Text(message)
        ],
      ),
      action: onPressed == null
          ? null
          : SnackBarAction(
              label: 'View'.tr(),
              onPressed: onPressed,
            ),
      duration: Duration(milliseconds: 4500),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
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
