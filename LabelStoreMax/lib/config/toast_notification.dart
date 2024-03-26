import 'package:nylo_framework/nylo_framework.dart';

/// ToastNotificationStyleMetaHelper is used to return
/// the correct value for the [ToastNotificationStyleType] toast style.
class NyToastNotificationStyleMetaHelper
    extends ToastNotificationStyleMetaHelper {
  NyToastNotificationStyleMetaHelper(super.style);

  @override
  onSuccess() {
    return ToastMeta.success();
  }

  @override
  onWarning() {
    return ToastMeta.warning();
  }

  @override
  onInfo() {
    return ToastMeta.info();
  }

  @override
  onDanger() {
    return ToastMeta.danger();
  }

// Example customizing a notification
// onSuccess() {
//   return ToastMeta.success(
//     title: "Hello",
//     description: "World",
//     action: () {},
//     backgroundColor: Colors.Yellow
//   );
// }
}
