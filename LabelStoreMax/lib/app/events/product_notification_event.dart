import 'package:firebase_messaging/firebase_messaging.dart';
import '/resources/pages/product_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProductNotificationEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    RemoteMessage message = event['RemoteMessage'];

    if (!message.data.containsKey('product_id')) {
      return;
    }

    routeTo(ProductDetailPage.path,
        data: int.parse(message.data['product_id']));
  }
}
