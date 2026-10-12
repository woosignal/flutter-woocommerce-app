//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:html/parser.dart' as html_parser;
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_credentials_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/login_blocked_exception.dart';
import 'package:wp_json_api/exceptions/meta_key_not_allowed_exception.dart';
import 'package:wp_json_api/exceptions/privileged_user_exception.dart';
import 'package:wp_json_api/exceptions/registration_disabled_exception.dart';
import 'package:wp_json_api/exceptions/too_many_attempts_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/exceptions/weak_password_exception.dart';
import 'package:wp_json_api/exceptions/wp_network_exception.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/app/events/logout_event.dart';

/* WP JSON API errors
|--------------------------------------------------------------------------
| wp_json_api 5 (WP JSON API WordPress plugin 5.0+) throws a typed exception
| for every failed request. These helpers turn them into translated toasts,
| and log the customer out when their session is no longer valid.
|-------------------------------------------------------------------------- */

/// Minimum password length enforced by the WP JSON API plugin (its default).
const int wpMinPasswordLength = 8;

/// Returns a translated, customer-facing message for an error thrown by
/// wp_json_api. [fallback] (a translation key) is used for any other error.
String wpJsonApiErrorMessage(Object error,
    {String fallback = "Something went wrong"}) {
  if (error is InvalidCredentialsException) {
    return trans("Invalid login credentials");
  }
  if (error is TooManyAttemptsException) {
    int? retryAfter = error.retryAfter;
    if (retryAfter == null || retryAfter <= 0) {
      return trans("Too many attempts, please try again later");
    }
    if (retryAfter < 120) {
      return trans("Too many attempts, please try again in seconds seconds",
          arguments: {"seconds": retryAfter.toString()});
    }
    return trans("Too many attempts, please try again in minutes minutes",
        arguments: {"minutes": (retryAfter / 60).ceil().toString()});
  }
  if (error is LoginBlockedException) {
    // Set by another plugin on the store (e.g. two-factor or a login
    // limiter), which is the only place that knows why.
    String message = _plainText(error.message);
    return message.isNotEmpty
        ? message
        : trans("Login is not available right now, please try again later");
  }
  if (error is PrivilegedUserException) {
    return trans("This account can't be used in the app");
  }
  if (error is RegistrationDisabledException) {
    return trans("Registration is currently disabled for this store");
  }
  if (error is WeakPasswordException) {
    return trans("Password must be at least minLength characters",
        arguments: {"minLength": wpMinPasswordLength.toString()});
  }
  if (error is UserAlreadyExistException) {
    return trans("That email is taken, try another");
  }
  if (error is UsernameTakenException) {
    return trans("That username is taken, try another");
  }
  if (error is InvalidEmailException) {
    return trans("That email address is not valid");
  }
  if (error is IncorrectPasswordException) {
    return trans("That password does not match our records");
  }
  if (error is MetaKeyNotAllowedException) {
    return trans(
        "Some of your details could not be saved, please contact our store");
  }
  if (error is WPNetworkException) {
    return trans(
        "Unable to connect, please check your connection and try again");
  }
  if (error is InvalidUserTokenException) {
    return trans("Your session has expired, please login again");
  }
  return trans(fallback);
}

/// Logs the customer out on this device and sends them to the login page when
/// [error] means their session is no longer valid (the token expired, was
/// revoked, or the password was changed elsewhere).
///
/// Returns true if it did, so the caller can stop what it was doing.
Future<bool> logoutIfWpSessionExpired(Object error) async {
  if (error is! InvalidUserTokenException) return false;
  await event<LogoutEvent>(data: {"session_expired": true});
  return true;
}

/// Clears a stored WordPress session that can no longer be used: one saved by
/// wp_json_api 4.x (those tokens don't work with the WP JSON API 5.0 plugin's
/// `wpapp/v4` API) or one whose token has expired. The customer is treated as
/// logged out and signs in again.
Future<void> clearExpiredWpSession() async {
  try {
    WpUser? wpUser = await WPJsonAPI.wpUser();
    if (wpUser != null && !(await WPJsonAPI.wpUserLoggedIn())) {
      await WPJsonAPI.wpLogout();
    }
  } catch (e) {
    // Unreadable session data, start logged out.
    NyLogger.error(e.toString());
    try {
      await WPJsonAPI.wpLogout();
    } catch (e) {
      NyLogger.error(e.toString());
    }
  }
}

extension WpJsonApiErrorToast on NyBaseState {
  /// Shows a danger toast for an error thrown by wp_json_api, then logs the
  /// customer out if their session is no longer valid.
  ///
  /// Returns true if the session expired - the customer is on their way to
  /// the login page, so the caller should stop (and not `pop()`).
  Future<bool> showWpJsonApiError(Object error,
      {String title = "Oops!", String fallback = "Something went wrong"}) async {
    NyLogger.error(error.toString());
    showToast(
      id: 'danger',
      title: trans(title),
      description: wpJsonApiErrorMessage(error, fallback: fallback),
    );
    return await logoutIfWpSessionExpired(error);
  }
}

/// Strips any HTML from a server message.
String _plainText(String message) =>
    (html_parser.parseFragment(message).text ?? "").trim();
