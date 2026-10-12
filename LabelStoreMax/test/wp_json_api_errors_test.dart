import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/bootstrap/wp_json_api_errors.dart';
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
import 'package:wp_json_api/exceptions/wp_server_exception.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// WP JSON API (wp_json_api 5) error and session tests.
///
/// The store answers every failed request with a typed exception. Each one has
/// to reach the customer as a translated sentence rather than a raw server
/// code, and a session the store no longer accepts has to end on the device.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    await clearWpUser();
  });

  nyGroup('the message a customer sees', () {
    nyTest('each wp_json_api 5 exception maps to its own message', () async {
      expect(wpJsonApiErrorMessage(InvalidCredentialsException()),
          "Invalid login credentials");
      expect(wpJsonApiErrorMessage(PrivilegedUserException()),
          "This account can't be used in the app");
      expect(wpJsonApiErrorMessage(RegistrationDisabledException()),
          "Registration is currently disabled for this store");
      expect(wpJsonApiErrorMessage(WeakPasswordException()),
          "Password must be at least 8 characters");
      expect(wpJsonApiErrorMessage(UserAlreadyExistException()),
          "That email is taken, try another");
      expect(wpJsonApiErrorMessage(UsernameTakenException()),
          "That username is taken, try another");
      expect(wpJsonApiErrorMessage(InvalidEmailException("bad")),
          "That email address is not valid");
      expect(wpJsonApiErrorMessage(IncorrectPasswordException("wrong")),
          "That password does not match our records");
      expect(
          wpJsonApiErrorMessage(
              MetaKeyNotAllowedException(null, "billing_secret")),
          "Some of your details could not be saved, please contact our store");
      expect(wpJsonApiErrorMessage(WPNetworkException("offline")),
          "Unable to connect, please check your connection and try again");
      expect(wpJsonApiErrorMessage(InvalidUserTokenException()),
          "Your session has expired, please login again");
    });

    nyTest('too many attempts says how long to wait', () async {
      expect(wpJsonApiErrorMessage(TooManyAttemptsException()),
          "Too many attempts, please try again later");
      expect(wpJsonApiErrorMessage(TooManyAttemptsException(null, 30)),
          "Too many attempts, please try again in 30 seconds");
      expect(wpJsonApiErrorMessage(TooManyAttemptsException(null, 900)),
          "Too many attempts, please try again in 15 minutes");
    });

    nyTest('a blocked login shows the store\'s reason, without HTML',
        () async {
      // Two-factor and login-limit plugins explain themselves in the message.
      expect(
          wpJsonApiErrorMessage(LoginBlockedException(
              "<strong>Error:</strong> Too many failed login attempts.")),
          "Error: Too many failed login attempts.");
      expect(wpJsonApiErrorMessage(LoginBlockedException("")),
          "Login is not available right now, please try again later");
    });

    nyTest('anything else falls back to the given message', () async {
      expect(wpJsonApiErrorMessage(WPServerException("boom")),
          "Something went wrong");
      expect(
          wpJsonApiErrorMessage(Exception("x"),
              fallback: "Invalid login credentials"),
          "Invalid login credentials");
    });
  });

  nyGroup('sessions from before WP JSON API 5', () {
    nyTest('a wp_json_api 4.x session is cleared on boot', () async {
      // 4.x stored no expiry; those tokens don't work with the v4 API.
      await seedWpUser(legacySession: true);
      expect(await WPJsonAPI.wpUser(), isNotNull);
      expect(await WPJsonAPI.wpUserLoggedIn(), isFalse);

      await clearExpiredWpSession();

      expect(await WPJsonAPI.wpUser(), isNull);
    });

    nyTest('an expired session is cleared on boot', () async {
      await seedWpUser(
          expiresAt: DateTime.now()
                  .subtract(const Duration(minutes: 1))
                  .millisecondsSinceEpoch ~/
              1000);

      await clearExpiredWpSession();

      expect(await WPJsonAPI.wpUser(), isNull);
    });

    nyTest('a valid session is kept', () async {
      await seedWpUser(id: 42);

      await clearExpiredWpSession();

      expect(await WPJsonAPI.wpUserLoggedIn(), isTrue);
      expect(await WPJsonAPI.wpUserId(), "42");
    });
  });

  nyGroup('an expired session', () {
    nyTest('is only acted on for InvalidUserTokenException', () async {
      await seedWpUser(id: 42);

      expect(await logoutIfWpSessionExpired(InvalidCredentialsException()),
          isFalse);
      expect(await logoutIfWpSessionExpired(WPNetworkException("offline")),
          isFalse);

      expect(await WPJsonAPI.wpUserLoggedIn(), isTrue);
    });
  });
}
