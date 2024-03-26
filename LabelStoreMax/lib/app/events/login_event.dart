import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/woosignal.dart';
import 'package:wp_json_api/wp_json_api.dart';

class LoginEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    String? userId = await WPJsonAPI.wpUserId();
    if (userId != null) {
      WooSignal.instance.setWpUserId(userId);
    }
  }
}
