import 'dart:async';

import '/app/models/cart.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/account_login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/wp_json_api.dart';

/// Logs the customer out.
///
/// Fire it with `data: {"session_expired": true}` when the store rejected the
/// customer's token (wp_json_api's `InvalidUserTokenException`). The session is
/// cleared on this device, the cart is kept and the customer is sent to the
/// login page.
class LogoutEvent implements NyEvent {
  @override
  final listeners = {DefaultListener: DefaultListener()};
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    bool sessionExpired = data is Map && data['session_expired'] == true;

    if (sessionExpired) {
      // The token is no longer valid on the store, only clear this device.
      await WPJsonAPI.wpLogout();
      clearWooSignalCustomer();
      // routeToInitial() only completes once the home page is popped, so
      // don't wait on it: rebuild home, then put the login page on top.
      unawaited(routeToInitial());
      await Future<void>.delayed(Duration.zero);
      unawaited(routeTo(AccountLoginPage.path));
      return;
    }

    await _revokeTokenAndLogout();
    clearWooSignalCustomer();
    await Cart.getInstance.clear();
    await routeToInitial();
  }

  /// Revokes the token on the store (WP JSON API 5.0+), then always clears the
  /// session on this device, even if the request fails or times out.
  Future<void> _revokeTokenAndLogout() async {
    try {
      if (AppHelper.instance.appConfig?.wpLoginEnabled == 1) {
        await WPJsonAPI.instance
            .api((request) => request.wpLogout())
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      // Logging out must never fail for the customer.
      NyLogger.error(e.toString());
    } finally {
      await WPJsonAPI.wpLogout();
    }
  }
}
