import '/app/events/category_notification_event.dart';
import '/app/events/cart_remove_all_event.dart';
import '/app/events/cart_remove_item_event.dart';
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
| Learn more: https://nylo.dev/docs/7.x/events
|-------------------------------------------------------------------------- */

final Map<Type, NyEvent> events = {
  LoginEvent: LoginEvent(),
  LogoutEvent: LogoutEvent(),
  FirebaseOnMessageOrderEvent: FirebaseOnMessageOrderEvent(),
  OrderNotificationEvent: OrderNotificationEvent(),
  ProductNotificationEvent: ProductNotificationEvent(),
  CartRemoveItemEvent: CartRemoveItemEvent(),
  CartRemoveAllEvent: CartRemoveAllEvent(),
  CategoryNotificationEvent: CategoryNotificationEvent(),
};
