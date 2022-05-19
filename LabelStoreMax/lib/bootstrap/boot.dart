// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_app/firebase_options.dart';

/// boot application
import 'package:flutter_app/config/providers.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Boot {
  static Future<Nylo> nylo() async => await bootApplication(providers);
  static Future<void> finished(Nylo nylo) async => await bootFinished(nylo);
}
