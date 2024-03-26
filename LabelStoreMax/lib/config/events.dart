import '/app/events/firebase_on_message_order_event.dart';
import '/app/events/order_notification_event.dart';
import '/app/events/product_notification_event.dart';
import '/app/events/login_event.dart';
import '/app/events/logout_event.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Events
|--------------------------------------------------------------------------
| Add your "app/events" here.
| Events can be fired using: event<MyEvent>();
|
| Learn more: https://nylo.dev/docs/5.20.0/events
|-------------------------------------------------------------------------- */

final Map<Type, NyEvent> events = {
  LoginEvent: LoginEvent(),
  LogoutEvent: LogoutEvent(),
  AuthUserEvent: AuthUserEvent(),
  FirebaseOnMessageOrderEvent: FirebaseOnMessageOrderEvent(),
  OrderNotificationEvent: OrderNotificationEvent(),
  ProductNotificationEvent: ProductNotificationEvent(),
};
