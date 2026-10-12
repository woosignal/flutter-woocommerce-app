import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/api_service.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'support/boot_test_app.dart';

/// Example tests for Label StoreMax.
///
/// Run tests with:        flutter test
/// Run a single file:     flutter test test/example_test.dart
///
/// `lib/bootstrap/env.g.dart` is generated and git-ignored, so run
/// "dart run nylo_framework:main make:env" before the first test run
/// (and again after every .env change).
///
/// Documentation: https://nylo.dev/docs/7.x/testing
void main() {
  // Initialize Nylo's testing framework. This also calls
  // TestWidgetsFlutterBinding.ensureInitialized(), which installs Flutter's
  // mock HttpOverrides - every HTTP request in the suite fails fast with a 400
  // and no socket is ever opened. That is what keeps AppProvider's
  // `getApp()` call to WooSignal off the network: it returns null and the app
  // boots with the placeholder WooSignalApp that AppProvider sets first.
  NyTest.init();

  nySetUpAll(() async {
    // Mock the app's own ApiService (used by the PayPal flow) so nothing in a
    // test can reach a live endpoint even if the HTTP layer changes.
    NyMockApi.register<ApiService>((request) async => {});

    await bootTestApp();
  });

  nyGroup('Environment', () {
    nyTest('the encrypted env is readable', () async {
      expectEnvSet('APP_NAME');
      expectEnvSet('WOOSIGNAL_APP_KEY');
      expectEnvSet('ASSET_PATH');
    });

    nyTest('assets are served from assets/', () async {
      expect(getEnv('ASSET_PATH'), 'assets');
      expect(getAsset('json/default_shipping.json'),
          'assets/json/default_shipping.json');
    });

    nyTest('is in test mode', () async {
      expectTestMode();
    });
  });

  nyGroup('Routes', () {
    nyTest('the store\'s main routes are registered', () async {
      // NotFoundPage is deliberately absent: it is registered with
      // `unknownRoute: true`, which stores it in the router's unknown-route
      // map rather than its named-route map. `router_test.dart` asserts it.
      expectRoutesExist([
        HomePage.path.name,
        '/cart',
        '/checkout',
        '/product-detail',
        '/account-login',
        '/account-detail',
      ]);
    });
  });

  nyGroup('API Mocking', () {
    nyTest('responses can be mocked by URL pattern', () async {
      NyMockApi.respond('/v1/oauth2/token', {'access_token': 'test-token'});

      expect(NyMockApi.patternCount, greaterThan(0));
    });

    nyTest('calls made against a mock are recorded', () async {
      NyMockApi.respond('/v1/payments/payment', {'id': 'PAY-TEST'});
      NyMockApi.recordCall('/v1/payments/payment', method: 'POST');

      expect(NyMockApi.wasCalled('/v1/payments/payment', method: 'POST'),
          isTrue);
    });
  });

  nyGroup('Backpack State', () {
    nyTest('test data can be seeded', () async {
      NyTest.seedBackpack({'onboarding_complete': true});

      expectBackpackContains('onboarding_complete', value: true);
    });
  });
}
