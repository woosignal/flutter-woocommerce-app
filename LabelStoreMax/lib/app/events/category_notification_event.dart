import 'package:firebase_messaging/firebase_messaging.dart';
import '/resources/pages/browse_category_page.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CategoryNotificationEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    RemoteMessage message = data['RemoteMessage'];

    if (!message.data.containsKey('category_id')) {
      return;
    }

    /// A category push is usually a broadcast, so it carries no `user_id`.
    /// When it does target a user, only that user should be routed.
    if (!(await canSeeRemoteMessage(message))) {
      return;
    }

    routeTo(BrowseCategoryPage.path,
        data: int.parse(message.data['category_id']));
  }
}
