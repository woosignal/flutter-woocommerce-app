import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/bootstrap/extensions.dart';
import 'package:flutter_app/resources/widgets/buttons/buttons.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/gradient_button_widget.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/icon_button_widget.dart'
    as app;
import 'package:flutter_app/resources/widgets/buttons/partials/outlined_button_widget.dart'
    as app;
import 'package:flutter_app/resources/widgets/buttons/partials/primary_button_widget.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/rounded_button_widget.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/secondary_button_widget.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/text_only_button_widget.dart';
import 'package:flutter_app/resources/widgets/buttons/partials/transparency_button_widget.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Button tests.
///
/// `Button` is the factory every call site in the app goes through. The three
/// the store actually uses - primary, secondary and text-only - reproduce the
/// pre-v7 buttons, including the height rule that sizes them off the screen
/// width. The async behaviour matters most: a checkout button that can be
/// double-tapped places two orders.
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

  /// Pump a button on its own.
  Future<void> pumpButton(WidgetTester tester, Widget button) =>
      tester.pumpNyWidgetSimple(Scaffold(body: Center(child: button)));

  nyGroup('every factory builds its partial', () {
    nyWidgetTest('and renders the text it was given', (tester) async {
      Map<Widget, Type> buttons = {
        Button.primary(text: "Primary"): PrimaryButton,
        Button.secondary(text: "Secondary"): SecondaryButton,
        Button.textOnly(text: "Text only"): TextOnlyButton,
        Button.outlined(text: "Outlined"): app.OutlinedButton,
        Button.icon(text: "Icon", icon: const Icon(Icons.star)):
            app.IconButton,
        Button.gradient(text: "Gradient"): GradientButton,
        Button.rounded(text: "Rounded"): RoundedButton,
        Button.transparency(text: "Transparency"): TransparencyButton,
      };

      for (MapEntry<Widget, Type> entry in buttons.entries) {
        await pumpButton(tester, entry.key);

        expect(find.byType(entry.value), findsOneWidget,
            reason: 'the factory must build a ${entry.value}');
        expect(find.byType(ButtonState), findsOneWidget,
            reason: '${entry.value} must be wrapped in the framework\'s '
                'ButtonState, or it cannot lock itself');
      }
    });
  });

  nyGroup('the primary button', () {
    nyWidgetTest('renders its label', (tester) async {
      await pumpButton(tester, Button.primary(text: "PROCEED TO CHECKOUT"));

      expect(find.text("PROCEED TO CHECKOUT"), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(AutoSizeText), findsOneWidget);
    });

    nyWidgetTest('is 55 high on a normal screen', (tester) async {
      // The pre-v7 button sized itself the same way: 55 at 385pt and above,
      // 49 below. The default test surface is 800 wide.
      await pumpButton(tester, Button.primary(text: "Buy"));

      expect(tester.getSize(find.byType(ElevatedButton)).height, 55);
    });

    nyWidgetTest('drops to 49 high on a narrow screen', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpButton(tester, Button.primary(text: "Buy"));

      expect(tester.getSize(find.byType(ElevatedButton)).height, 49);
    });

    nyWidgetTest('takes its colours from the store theme', (tester) async {
      late BuildContext buttonContext;
      await tester.pumpNyWidgetSimple(Scaffold(
          body: Builder(builder: (context) {
        buttonContext = context;
        return Button.primary(text: "Buy");
      })));

      ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(
          button.style!.backgroundColor!.resolve({}),
          buttonContext.color.button.background,
          reason: 'the primary button must use the store\'s button colour');

      AutoSizeText label = tester.widget(find.byType(AutoSizeText));
      expect(label.style!.color, buttonContext.color.button.content);
      expect(label.style!.fontSize, 16);
      expect(label.style!.fontWeight, FontWeight.bold);
    });

    nyWidgetTest('an explicit colour wins over the theme', (tester) async {
      await pumpButton(tester,
          Button.primary(text: "Buy", color: Colors.pink, textColor: Colors.teal));

      ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(button.style!.backgroundColor!.resolve({}), Colors.pink);
      expect(
          (tester.widget(find.byType(AutoSizeText)) as AutoSizeText)
              .style!
              .color,
          Colors.teal);
    });

    nyWidgetTest('takes a width and a height when given them', (tester) async {
      await pumpButton(
          tester, Button.primary(text: "Buy", width: 120, height: 40));

      expect(tester.getSize(find.byType(ElevatedButton)),
          const Size(120, 40));
    });
  });

  nyGroup('the text only button', () {
    nyWidgetTest('renders its label', (tester) async {
      await pumpButton(tester, Button.textOnly(text: "Forgot Password"));

      expect(find.text("Forgot Password"), findsOneWidget);
    });

    nyWidgetTest('goes bold when it is the selected one', (tester) async {
      await pumpButton(tester, Button.textOnly(text: "Newest", selected: true));
      Text selected = tester.widget(find.text("Newest"));
      expect(selected.style!.fontWeight, FontWeight.bold);

      await pumpButton(
          tester, Button.textOnly(text: "Newest", selected: false));
      Text unselected = tester.widget(find.text("Newest"));
      expect(unselected.style!.fontWeight, isNot(FontWeight.bold));
    });
  });

  nyGroup('pressing a button', () {
    nyWidgetTest('runs the callback', (tester) async {
      int taps = 0;
      await pumpButton(
          tester, Button.primary(text: "Buy", onPressed: () => taps += 1));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(taps, 1);
    });

    nyWidgetTest('shows the loader while an async action runs, then comes back',
        (tester) async {
      Completer<void> finished = Completer<void>();
      await pumpButton(
          tester,
          Button.primary(
              text: "Buy", onPressed: () async => await finished.future));

      expect(find.byType(AppLoaderWidget), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // The button swaps itself for the loader and stops responding, which is
      // what stops a double tap placing two orders.
      expect(find.byType(AppLoaderWidget), findsOneWidget);
      expect(find.text("Buy"), findsNothing);

      finished.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppLoaderWidget), findsNothing);
      expect(find.text("Buy"), findsOneWidget);
    });

    nyWidgetTest('a second tap while it is working is ignored', (tester) async {
      int runs = 0;
      Completer<void> finished = Completer<void>();
      await pumpButton(
          tester,
          Button.primary(
              text: "Buy",
              onPressed: () async {
                runs += 1;
                await finished.future;
              }));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(runs, 1);

      finished.complete();
      await tester.pump();
    });

    nyWidgetTest('a button with no callback does nothing when tapped',
        (tester) async {
      await pumpButton(tester, Button.primary(text: "Buy"));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No action means nothing to wait for, so no loader and no lock.
      expect(find.byType(AppLoaderWidget), findsNothing);
      expect(find.text("Buy"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  nyGroup('form submission', () {
    nyWidgetTest('a submitForm tuple is carried onto the button',
        (tester) async {
      // This is how the login and register pages wire their button to their
      // form: Button.primary(submitForm: ("login", (data) { ... })).
      PrimaryButton button = Button.primary(
          text: "Login",
          submitForm: ("login", (dynamic data) async {})) as PrimaryButton;

      expect(button.submitForm, isNotNull);
      expect(button.submitForm!.$1, "login");

      await pumpButton(tester, button);
      expect(find.text("Login"), findsOneWidget);
    });

    nyWidgetTest('withSubmitForm attaches one after the fact', (tester) async {
      PrimaryButton button = Button.primary(text: "Login") as PrimaryButton;
      expect(button.submitForm, isNull);

      button.withSubmitForm(("register", (dynamic data) async {}));

      expect(button.submitForm!.$1, "register");
    });

    nyWidgetTest('toast on error is on by default', (tester) async {
      // A submit that fails validation has to say why.
      PrimaryButton button = Button.primary(text: "Login") as PrimaryButton;

      expect(button.showToastError, isTrue);
    });
  });
}
