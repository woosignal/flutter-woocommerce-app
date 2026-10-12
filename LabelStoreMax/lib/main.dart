import '/bootstrap/env.g.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'bootstrap/boot.dart';

/// Nylo - Framework for Flutter Developers
/// Docs: https://nylo.dev/docs/7.x

/// Main entry point for the application.
///
/// The `env.g.dart` import above is generated from the .env file, run
/// "dart run nylo_framework:main make:env" to (re)build it.
void main() async {
  await Nylo.init(
    env: Env.get,
    setup: Boot.nylo(),
    appLifecycle: {
      // Uncomment the code below to enable app lifecycle events
      // (AppLifecycleState lives in 'dart:ui', import it when you do)
      // AppLifecycleState.resumed: () {
      //   print("App resumed");
      // },
      // AppLifecycleState.paused: () {
      //   print("App paused");
      // },
    },
  );
}
