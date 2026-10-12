import 'package:flutter/material.dart';
import '/resources/widgets/app_loader_widget.dart';

/* Splash Screen
|--------------------------------------------------------------------------
| Rendered by bootstrap/boot.dart before your providers run, but only when
| SHOW_SPLASH_SCREEN is "true" in your .env file. It ships disabled, so by
| default the native launch screen stays up for the whole boot.
|
| Note: the store logo cannot be shown here. It is downloaded from WooSignal
| by AppProvider, which has not run yet at this point.
|-------------------------------------------------------------------------- */

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Create a new instance of the MaterialApp
  static MaterialApp app() {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: AppLoaderWidget()),
      );
}
