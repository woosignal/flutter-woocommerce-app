import 'package:flutter/services.dart';

/// boot application
Future<void> boot() async {

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

}