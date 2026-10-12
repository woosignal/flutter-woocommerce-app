import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/toast_notification_widget.dart';

/* Toast Notification
|--------------------------------------------------------------------------
| Toast styles are registered with Nylo via
| `configure(toastNotifications: ToastNotificationConfig.styles)`.
|
| Each entry maps a style id ("success", "warning", "info", "danger") to a
| factory that renders the app's custom [ToastNotification] widget with a
| per-style icon + colour, keeping the title/description from the call site.
|
| Show a toast with:
|   showToastNotification(context, id: 'success', title: ..., description: ...)
| or the NyState / NyController helpers
|   (showToastSuccess, showToastDanger, showToastOops, ...).
|
| Learn more: https://nylo.dev/docs/7.x/configuration
|-------------------------------------------------------------------------- */

final class ToastNotificationConfig {
  static final Map<String, dynamic> styles = {
    'success': _toastStyle(
      defaultTitle: 'Success',
      icon: const Icon(Icons.check, color: Colors.green, size: 20),
      color: Colors.green.shade50,
    ),
    'warning': _toastStyle(
      defaultTitle: 'Warning',
      icon: const Icon(Icons.error_outline, color: Colors.orange, size: 20),
      color: Colors.orange.shade50,
    ),
    'info': _toastStyle(
      defaultTitle: 'Info',
      icon: const Icon(Icons.info, color: Colors.teal, size: 20),
      color: Colors.teal.shade50,
    ),
    'danger': _toastStyle(
      defaultTitle: 'Oops',
      icon: const Icon(Icons.warning, color: Colors.redAccent, size: 20),
      color: Colors.red.shade50,
    ),
  };
}

ToastStyleFactory _toastStyle({
  required String defaultTitle,
  required Widget icon,
  required Color color,
}) {
  return (ToastMeta meta, void Function(ToastMeta) updateMeta) {
    ToastMeta styled = ToastMeta(
      title: meta.title.isEmpty ? defaultTitle : meta.title,
      description: meta.description,
      icon: icon,
      color: color,
      action: meta.action,
    );
    return ToastNotification(styled, onDismiss: meta.dismiss);
  };
}
