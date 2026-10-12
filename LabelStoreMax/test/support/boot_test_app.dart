import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/bootstrap/env.g.dart';
import 'package:flutter_app/bootstrap/providers.dart';

/// Boots the app the way `Boot.nylo()` does, minus `runApp`.
///
/// Call this from `nySetUpAll`. It is deliberately not a `_test.dart` file so
/// `flutter test` does not try to run it as a suite.
///
/// Nothing here touches the network: `NyTest.init()` installs Flutter's mock
/// `HttpOverrides`, so `AppProvider`'s `getApp()` call to WooSignal fails fast
/// with a 400, returns null, and the app carries on with the placeholder
/// `WooSignalApp` that `AppProvider` sets up first.
Future<Nylo> bootTestApp() async {
  NyEnvRegistry.register(getter: Env.get);

  // `Nylo.init()` does these two before it runs the setup phase, and tests call
  // the setup phase directly. Without them `intl` has no locale data, so
  // anything that formats a date - `toDateTimeString()` inside
  // `NyNotification.addNotification`, for one - throws LocaleDataException.
  Intl.defaultLocale = getEnv('DEFAULT_LOCALE', defaultValue: 'en');
  await initializeDateFormatting();

  mockDeviceInfoChannel();

  Nylo nylo = await setupApplication(providers);

  // `setupApplication` runs the providers' `setup`; it is `bootFinished` that
  // parks Nylo in the Backpack, and tests do not boot providers (that would
  // start Firebase). Every `NyStatefulWidget` constructor reads
  // `Backpack.instance.nylo()`, so save it here instead.
  Backpack.instance.save("nylo", nylo);

  // `EventProvider.boot` is what normally installs the event bus, and tests
  // skip the boot phase. Without it every `event<...>()` and every
  // `stateAction(...)` logs "Event bus not defined" and does nothing, so a
  // test covering either would pass while asserting nothing.
  nylo.addEventBus();

  return nylo;
}

/// `WooSignal.init()` reads the device meta, which goes through
/// `device_info_plus`. That plugin has no implementation in a test process, so
/// stand in for it. `NyMockChannels.setup()` (run by `NyTest.init()`) already
/// covers secure storage, path_provider, sqflite and local notifications.
void mockDeviceInfoChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/device_info'),
    (MethodCall methodCall) async {
      if (methodCall.method != 'getDeviceInfo') return null;
      return _deviceInfoForHost();
    },
  );
}

/// The shape `device_info_plus` expects back for the host running the tests.
/// Only the desktop hosts a developer or CI machine can be are covered - add a
/// branch here if you run the suite somewhere else.
Map<String, dynamic> _deviceInfoForHost() {
  if (Platform.isMacOS) {
    return <String, dynamic>{
      'computerName': 'test-mac',
      'hostName': 'test-mac.local',
      'arch': 'arm64',
      'model': 'Mac0,0',
      'modelName': 'Test Mac',
      'kernelVersion': 'Darwin Kernel Version 0.0.0',
      'osRelease': '0.0.0',
      'majorVersion': 0,
      'minorVersion': 0,
      'patchVersion': 0,
      'activeCPUs': 1,
      'memorySize': 0,
      'cpuFrequency': 0,
      'systemGUID': 'test-system-guid',
    };
  }
  if (Platform.isLinux) {
    return <String, dynamic>{
      'name': 'Test Linux',
      'version': '1',
      'id': 'test',
      'idLike': <String>[],
      'versionCodename': 'test',
      'versionId': '1',
      'prettyName': 'Test Linux 1',
      'buildId': 'test',
      'variant': 'test',
      'variantId': 'test',
      'machineId': 'test-machine-id',
    };
  }
  return <String, dynamic>{};
}
