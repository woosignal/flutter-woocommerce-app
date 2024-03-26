import 'package:flutter/cupertino.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import '/config/toast_notification.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/toast_notification_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Design
|--------------------------------------------------------------------------
| Contains widgets used in the Nylo framework.
|
| Learn more: https://nylo.dev/docs/5.20.0/themes
|-------------------------------------------------------------------------- */

Widget logo = StoreLogo();
// resources/widgets/woosignal_ui.dart

Widget loader = AppLoaderWidget();
// resources/widgets/app_loader_widget.dart

Widget getToastNotificationWidget(
    {required ToastNotificationStyleType style,
    Function(ToastNotificationStyleMetaHelper helper)?
        toastNotificationStyleMeta,
    Function? onDismiss}) {
  if (toastNotificationStyleMeta == null) return SizedBox.shrink();

  ToastMeta toastMeta =
      toastNotificationStyleMeta(NyToastNotificationStyleMetaHelper(style));

  return ToastNotification(toastMeta, onDismiss: onDismiss);
  // resources/widgets/toast_notification.dart
}
