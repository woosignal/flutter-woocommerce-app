// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_app/bootstrap/app_helper.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (AppHelper.instance.appConfig?.firebaseOptionsAndroid == null) {
          throw UnsupportedError(
            'Add a valid Firebase json config on https://woosignal.com for your WooCommerce store',
          );
        }
        return FirebaseOptions(
          apiKey: AppHelper.instance.appConfig!.firebaseOptionsAndroid!['apiKey'],
          appId: AppHelper.instance.appConfig!.firebaseOptionsAndroid!['appId'],
          messagingSenderId: AppHelper.instance.appConfig!.firebaseOptionsAndroid!['messagingSenderId'],
          projectId: AppHelper.instance.appConfig!.firebaseOptionsAndroid!['projectId'],
          storageBucket: AppHelper.instance.appConfig!.firebaseOptionsAndroid!['storageBucket'],
        );
      case TargetPlatform.iOS:
        if (AppHelper.instance.appConfig?.firebaseOptionsIos == null) {
          throw UnsupportedError(
            'Add a valid Firebase plist config on https://woosignal.com for your WooCommerce store',
          );
        }
        return FirebaseOptions(
          apiKey: AppHelper.instance.appConfig!.firebaseOptionsIos!['apiKey'],
          appId: AppHelper.instance.appConfig!.firebaseOptionsIos!['appId'],
          messagingSenderId: AppHelper.instance.appConfig!.firebaseOptionsIos!['messagingSenderId'],
          projectId: AppHelper.instance.appConfig!.firebaseOptionsIos!['projectId'],
          storageBucket: AppHelper.instance.appConfig!.firebaseOptionsIos!['storageBucket'],
          iosClientId: AppHelper.instance.appConfig!.firebaseOptionsIos!['iosClientId'],
          iosBundleId: AppHelper.instance.appConfig!.firebaseOptionsIos!['iosBundleId'],
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
