import 'package:flutter/material.dart';
import '/bootstrap/app.dart';
import '/bootstrap/boot.dart';
import 'package:nylo_framework/nylo_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Nylo nylo = await Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished);

  runApp(
    AppBuild(
      navigatorKey: NyNavigator.instance.router.navigatorKey,
      onGenerateRoute: nylo.router!.generator(),
      initialRoute: nylo.getInitialRoute(),
      navigatorObservers: [
        ...nylo.getNavigatorObservers(),
      ],
      debugShowCheckedModeBanner: false,
    ),
  );
}
