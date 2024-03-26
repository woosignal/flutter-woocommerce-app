//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/notifications_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NotificationIcon extends StatefulWidget {
  NotificationIcon({super.key});

  static String state = "notification_icon";

  @override
  createState() => _NotificationIconState();
}

class _NotificationIconState extends NyState<NotificationIcon> {
  int totalNotifications = 0;

  _NotificationIconState() {
    stateName = NotificationIcon.state;
  }

  @override
  boot() async {
    totalNotifications =
        (await NyNotification.allNotificationsNotRead()).length;
  }

  @override
  stateUpdated(dynamic data) async {
    totalNotifications =
        (await NyNotification.allNotificationsNotRead()).length;
  }

  @override
  Widget view(BuildContext context) {
    if (!isFirebaseEnabled()) {
      return SizedBox.shrink();
    }
    if (totalNotifications == 0) {
      return InkWell(
        onTap: () => routeTo(NotificationsPage.path),
        child: Icon(Icons.notifications),
      );
    }
    return InkWell(
      onTap: () => routeTo(NotificationsPage.path),
      child: Badge.count(
        child: Icon(Icons.notifications),
        count: totalNotifications,
      ),
    );
  }
}
