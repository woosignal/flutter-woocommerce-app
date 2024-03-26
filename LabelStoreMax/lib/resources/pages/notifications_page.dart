import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/account_order_detail_page.dart';
import '/resources/widgets/notification_icon_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';

class NotificationsPage extends NyStatefulWidget {
  static const path = '/notifications';

  NotificationsPage() : super(path, child: _NotificationsPageState());
}

class _NotificationsPageState extends NyState<NotificationsPage> {
  WpUser? _wpUser;

  @override
  boot() async {
    _wpUser = (await WPJsonAPI.wpUser());
  }

  @override
  Widget view(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        await NyNotification.markReadAll();
        updateState(NotificationIcon.state);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Notifications".tr()),
          actions: [
            TextButton(
              onPressed: () async {
                await NyNotification.markReadAll();
                showStatusAlert(
                  context,
                  title: trans("Success"),
                  subtitle: trans("All notifications marked as read"),
                  duration: 1,
                  icon: Icons.notifications,
                );
                setState(() {});
              },
              child: Text(
                "Mark all read".tr(),
              ),
            ),
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 18, right: 18, bottom: 18),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Showing last 30 days".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800),
              ),
            ),
            Expanded(
              child: NyNotification.renderListNotificationsWithSeparator(
                  (notificationItem) {
                if (notificationItem.meta != null &&
                    notificationItem.meta!.containsKey('user_id')) {
                  String? userId = notificationItem.meta?['user_id'];

                  if (userId != _wpUser?.id.toString()) {
                    return SizedBox.shrink();
                  }
                }
                String? createdAt = notificationItem.createdAt;
                if (createdAt != null) {
                  DateTime createdAtDate = DateTime.parse(createdAt);
                  createdAt = createdAtDate.toTimeAgoString();
                }
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  title: Text(
                    notificationItem.title ?? "",
                    style: TextStyle(
                        fontWeight: notificationItem.hasRead == true
                            ? null
                            : FontWeight.w800),
                  ),
                  leading: Container(
                    child: Icon(Icons.shopping_bag_outlined),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  subtitle: NyRichText(
                    style: TextStyle(color: Colors.black),
                    children: [
                      Text(
                        notificationItem.message ?? "",
                        style: TextStyle(
                            fontWeight: notificationItem.hasRead == true
                                ? null
                                : FontWeight.w800),
                      ),
                      if (createdAt != null)
                        Text("\n$createdAt",
                            style: TextStyle(color: Colors.grey.shade600))
                    ],
                  ),
                  trailing: Text("View".tr()),
                  onTap: () {
                    dynamic orderId = notificationItem.meta?['order_id'];
                    routeTo(AccountOrderDetailPage.path,
                        data: int.parse(orderId.toString()));
                  },
                );
              }, loading: SizedBox.shrink()),
            ),
          ],
        )),
      ),
    );
  }
}
