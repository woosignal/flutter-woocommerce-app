import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/helpers.dart';

class LoginEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    // Send the customer's id and token with WooSignal requests (order
    // history, personal notifications).
    await syncWooSignalCustomer();
  }
}
