import 'package:woosignal/woosignal.dart';

import '/app/models/cart.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/wp_json_api.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {DefaultListener: DefaultListener()};
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    await WPJsonAPI.wpLogout();
    await Cart.getInstance.clear();
    WooSignal.instance.setWpUserId("");
    await routeToInitial();
  }
}
