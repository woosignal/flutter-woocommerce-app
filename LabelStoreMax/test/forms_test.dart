import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/forms/login_form.dart';
import 'package:flutter_app/app/forms/register_form.dart';
import 'package:flutter_app/resources/widgets/buttons/buttons.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Form tests.
///
/// The login and registration forms are the only two in the app, and both feed
/// a WordPress request. What matters is that the fields carry the keys the
/// pages read back (`data['email']`, `data['first_name']`) and that the
/// validators reject before anything is sent.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    NyWidgetTest.configure(testTheme: NyWidgetTest.simpleTestTheme);
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    recordToasts();
  });

  /// Flatten a form's fields; a nested list is a row of fields.
  List<Field> fieldsOf(NyFormWidget form) {
    List<Field> flat = [];
    for (Object? entry in form.fields()) {
      if (entry is List) {
        flat.addAll(entry.cast<Field>());
      } else {
        flat.add(entry as Field);
      }
    }
    return flat;
  }

  nyGroup('the login form', () {
    nyTest('is named so the page can address it', () async {
      // The submit button is wired with ("login", ...) and the page reads
      // LoginForm.actions.
      expect(LoginForm().formName, "login");
      expect(LoginForm.actions.formName, "login");
    });

    nyTest('takes an email and a password', () async {
      List<Field> fields = fieldsOf(LoginForm());

      expect(fields.length, 2);
      expect(fields.map((field) => field.key), ["Email", "Password"]);
    });

    nyTest('validates both fields', () async {
      List<Field> fields = fieldsOf(LoginForm());

      for (Field field in fields) {
        expect(field.validator, isNotNull,
            reason: '"${field.key}" must be validated before login is sent');
      }
    });

    nyTest('can be given a name of its own', () async {
      expect(LoginForm(name: "second_login").formName, "second_login");
    });
  });

  nyGroup('the registration form', () {
    nyTest('is named so the page can address it', () async {
      expect(RegisterForm().formName, "register");
      expect(RegisterForm.actions.formName, "register");
    });

    nyTest('takes a first name, last name, email and password', () async {
      List<Field> fields = fieldsOf(RegisterForm());

      expect(fields.length, 4);
      // The key is what the submitted data is snake-cased from; the label is
      // only what the customer reads.
      expect(fields.map((field) => field.key),
          ["First Name", "Last Name", "Email", "Password"]);
      expect(fields[2].label, "Email address");
    });

    nyTest('puts the two names side by side', () async {
      // A nested list renders as one row, which is the two column layout the
      // page had before.
      List<dynamic> entries = RegisterForm().fields();

      expect(entries.first, isA<List>());
      expect((entries.first as List).length, 2);
    });

    nyTest('validates the email and the password, and only those', () async {
      List<Field> fields = fieldsOf(RegisterForm());
      Map<String, bool> validated = {
        for (Field field in fields) field.key: field.validator != null
      };

      expect(validated["Email"], isTrue);
      expect(validated["Password"], isTrue);
      // The two names are optional; the page defaults them to "" instead.
      expect(validated["First Name"], isFalse);
      expect(validated["Last Name"], isFalse);
    });
  });

  nyGroup('the email rule', () {
    nyTest('accepts a real address', () async {
      for (String email in [
        "test@example.com",
        "first.last+tag@sub.example.co.uk",
      ]) {
        expect(FormValidator.email().check(email).isValid, isTrue,
            reason: '"$email" is a valid address');
      }
    });

    nyTest('rejects anything that is not one', () async {
      for (String email in ["", "test", "test@", "test@example", "@a.com"]) {
        expect(FormValidator.email().check(email).isValid, isFalse,
            reason: '"$email" is not a valid address');
      }
    });

    nyTest('rejects a field that was never typed in', () async {
      // A field the customer never touched holds null, not "". This is what
      // stops the login request going out with a null email.
      expect(FormValidator.email().check(null).isValid, isFalse);
    });
  });

  nyGroup('the password rule', () {
    nyTest('accepts a password at strength 1', () async {
      // Strength 1 wants a capital and a digit, which is worth knowing: it is
      // what a customer has to satisfy to register.
      for (String password in ["Secret123", "Secret123!", "aA1!aA1!"]) {
        expect(FormValidator.password(strength: 1).check(password).isValid,
            isTrue,
            reason: '"$password" should be accepted');
      }
    });

    nyTest('refuses fewer than the store\'s 8 characters', () async {
      // WP JSON API 5 rejects passwords under 8 characters
      // (wpapp_weak_password), so registration must not let one through.
      expect(FormValidator.password(strength: 1).check("Secre12").isValid,
          isFalse);
      expect(FormValidator.password(strength: 1).check("Secre123").isValid,
          isTrue);
    });

    nyTest('rejects a weak or missing password', () async {
      for (String? password in ["", "ab", "abcdefgh", "secret123", null]) {
        expect(FormValidator.password(strength: 1).check(password).isValid,
            isFalse,
            reason: '"$password" should be refused');
      }
    });
  });

  nyGroup('submitting', () {
    nyWidgetTest('a valid login hands the data to the page', (tester) async {
      Map<String, dynamic>? submitted;

      await tester.pumpNyWidgetSimple(Scaffold(
        body: LoginForm(
          footer: Button.primary(
            text: "Login",
            submitForm: ("login", (data) async => submitted = data),
          ),
        ),
      ));

      await tester.enterText(find.byType(TextField).first, "test@example.test");
      await tester.enterText(find.byType(TextField).last, "Secret123");
      await tester.pump();

      await tester.tap(find.text("Login"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isNotNull);
      // The page reads data['email'] and data['password'], so the keys have to
      // arrive snake-cased.
      expect(submitted!['email'], "test@example.test");
      expect(submitted!['password'], "Secret123");
      await settleToasts(tester);
    });

    nyWidgetTest('an invalid login is not sent, and says why', (tester) async {
      bool submitted = false;

      await tester.pumpNyWidgetSimple(Scaffold(
        body: LoginForm(
          footer: Button.primary(
            text: "Login",
            submitForm: ("login", (data) async => submitted = true),
          ),
        ),
      ));

      await tester.enterText(find.byType(TextField).first, "not-an-email");
      await tester.enterText(find.byType(TextField).last, "Secret123");
      await tester.pump();

      await tester.tap(find.text("Login"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isFalse,
          reason: 'a bad address must never reach WordPress');
      await settleToasts(tester);
    });

    nyWidgetTest('an empty login is not sent', (tester) async {
      bool submitted = false;

      await tester.pumpNyWidgetSimple(Scaffold(
        body: LoginForm(
          footer: Button.primary(
            text: "Login",
            submitForm: ("login", (data) async => submitted = true),
          ),
        ),
      ));

      await tester.tap(find.text("Login"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isFalse);
      await settleToasts(tester);
    });

    nyWidgetTest('a valid registration hands over all four values',
        (tester) async {
      Map<String, dynamic>? submitted;

      await tester.pumpNyWidgetSimple(Scaffold(
        body: RegisterForm(
          footer: Button.primary(
            text: "Register",
            submitForm: ("register", (data) async => submitted = data),
          ),
        ),
      ));

      List<Finder> fields = [
        find.byType(TextField).at(0),
        find.byType(TextField).at(1),
        find.byType(TextField).at(2),
        find.byType(TextField).at(3),
      ];
      await tester.enterText(fields[0], "Anthony");
      await tester.enterText(fields[1], "Gordon");
      await tester.enterText(fields[2], "test@example.test");
      await tester.enterText(fields[3], "Secret123");
      await tester.pump();

      await tester.tap(find.text("Register"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isNotNull);
      expect(submitted!['first_name'], "Anthony");
      expect(submitted!['last_name'], "Gordon");
      expect(submitted!['email'], "test@example.test");
      expect(submitted!['password'], "Secret123");
      await settleToasts(tester);
    });

    nyWidgetTest('a registration with no name still goes through',
        (tester) async {
      // The two name fields carry no validator on purpose, and the page
      // defaults them to "" rather than letting a null through.
      Map<String, dynamic>? submitted;

      await tester.pumpNyWidgetSimple(Scaffold(
        body: RegisterForm(
          footer: Button.primary(
            text: "Register",
            submitForm: ("register", (data) async => submitted = data),
          ),
        ),
      ));

      await tester.enterText(
          find.byType(TextField).at(2), "test@example.test");
      await tester.enterText(find.byType(TextField).at(3), "Secret123");
      await tester.pump();

      await tester.tap(find.text("Register"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isNotNull);
      expect(submitted!['email'], "test@example.test");
      // Null here is exactly what used to crash the registration page.
      expect(submitted!['first_name'] ?? "", "");
      await settleToasts(tester);
    });
  });
}
