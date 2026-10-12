import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/resources/pages/account_delete_page.dart';
import 'package:flutter_app/resources/pages/account_detail_page.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/pages/account_profile_update_page.dart';
import 'package:flutter_app/resources/pages/account_shipping_details_page.dart';
import 'package:flutter_app/routes/guards/auth_route_guard.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Route guard tests.
///
/// [AuthRouteGuard] stands in front of the four account pages that need a
/// WordPress session. When it turns someone away it has to remember where they
/// were going, or they sign in and land back on the home page instead of the
/// page they asked for.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    await clearWpUser();
  });

  /// Ask the guard about a route, as the router does.
  Future<GuardResult> ask(AuthRouteGuard guard,
          {String routeName = "/account-detail", dynamic data}) =>
      guard.onBefore(RouteContext(routeName: routeName, data: data));

  nyGroup('when WordPress logins are switched off', () {
    nyTest('the guarded pages stay open', () async {
      // A store with no WordPress login has no account to sign in to, so
      // guarding these pages would lock them out of the app entirely.
      seedAppConfig(wooSignalApp: wooSignalAppFixture(wpLoginEnabled: 0));

      expect(await ask(AuthRouteGuard()), GuardResult.next);
    });

    nyTest('the same holds when the store config has not loaded', () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(wpLoginEnabled: 0));

      expect(await ask(AuthRouteGuard()), GuardResult.next);
    });
  });

  nyGroup('when the customer is signed in', () {
    nyTest('the route is allowed through', () async {
      await seedWpUser();

      AuthRouteGuard guard = AuthRouteGuard();
      expect(await ask(guard), GuardResult.next);
      expect(guard.redirectConfig, isNull);
    });
  });

  nyGroup('when the customer is signed out', () {
    nyTest('the route is intercepted and sent to the login page', () async {
      AuthRouteGuard guard = AuthRouteGuard();

      expect(await ask(guard), GuardResult.handled);
      expect(guard.redirectConfig, isNotNull);
      expect(guard.redirectConfig!.path, AccountLoginPage.path.name);
    });

    nyTest('the login page is pushed, not swapped in', () async {
      AuthRouteGuard guard = AuthRouteGuard();
      await ask(guard);

      // Push keeps whatever the customer was looking at underneath, which is
      // what the old routeTo(AccountLoginPage.path) call sites did.
      expect(guard.redirectConfig!.navigationType, NavigationType.push);
    });

    nyTest('it remembers the route the customer asked for', () async {
      AuthRouteGuard guard = AuthRouteGuard();
      await ask(guard, routeName: AccountDeletePage.path.name);

      Map data = guard.redirectConfig!.data as Map;
      expect(data[intendedRouteKey], AccountDeletePage.path.name);
    });

    nyTest('it remembers the data that route was called with', () async {
      AuthRouteGuard guard = AuthRouteGuard();
      await ask(guard,
          routeName: AccountDetailPage.path.name, data: {"tab": 1});

      Map data = guard.redirectConfig!.data as Map;
      expect(data[intendedRouteDataKey], {"tab": 1});
    });

    nyTest('a route called with no data remembers null', () async {
      AuthRouteGuard guard = AuthRouteGuard();
      await ask(guard);

      Map data = guard.redirectConfig!.data as Map;
      expect(data.containsKey(intendedRouteDataKey), isTrue);
      expect(data[intendedRouteDataKey], isNull);
    });

    nyTest('it turns every guarded page away', () async {
      for (String path in [
        AccountDetailPage.path.name,
        AccountProfileUpdatePage.path.name,
        AccountDeletePage.path.name,
        AccountShippingDetailsPage.path.name,
      ]) {
        AuthRouteGuard guard = AuthRouteGuard();

        expect(await ask(guard, routeName: path), GuardResult.handled,
            reason: 'Route "$path" must be guarded');
        expect((guard.redirectConfig!.data as Map)[intendedRouteKey], path);
      }
    });
  });

  nyGroup('the keys the login page reads back', () {
    nyTest('are the strings the guard writes', () async {
      // The guard writes these and account_login_page reads them back through
      // routeToIntended(widget.data()), so they have to agree.
      expect(intendedRouteKey, "intended_route");
      expect(intendedRouteDataKey, "intended_route_data");
    });

    nyTest('the guard writes exactly those two and nothing else', () async {
      AuthRouteGuard guard = AuthRouteGuard();
      await ask(guard);

      expect((guard.redirectConfig!.data as Map).keys.toSet(),
          {intendedRouteKey, intendedRouteDataKey});
    });
  });

  nyGroup('mock guards', () {
    nyTest('a passing guard lets the route through', () async {
      NyMockRouteGuard guard = NyMockRouteGuard.pass();

      expect(await guard.onBefore(RouteContext(routeName: "/anywhere")),
          GuardResult.next);
      expect(guard.wasCalled, isTrue);
      expect(guard.callCount, 1);
    });

    nyTest('a redirecting guard reports where it sent the customer', () async {
      NyMockRouteGuard guard =
          NyMockRouteGuard.redirect(AccountLoginPage.path.name);

      expect(await guard.onBefore(RouteContext(routeName: "/anywhere")),
          GuardResult.handled);
      expect(guard.redirectConfig!.path, AccountLoginPage.path.name);
    });

    nyTest('a custom guard can decide from the route context', () async {
      NyMockRouteGuard guard = NyMockRouteGuard.custom((context) async =>
          context.data == null ? GuardResult.handled : GuardResult.next);

      expect(await guard.onBefore(RouteContext(routeName: "/a")),
          GuardResult.handled);
      expect(
          await guard.onBefore(RouteContext(routeName: "/a", data: {"x": 1})),
          GuardResult.next);
      expect(guard.callCount, 2);

      guard.reset();
      expect(guard.wasCalled, isFalse);
    });
  });
}
