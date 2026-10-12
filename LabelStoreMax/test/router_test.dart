import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/resources/pages/account_delete_page.dart';
import 'package:flutter_app/resources/pages/account_detail_page.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/pages/account_profile_update_page.dart';
import 'package:flutter_app/resources/pages/account_shipping_details_page.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/pages/not_found_page.dart';
import 'package:flutter_app/routes/guards/auth_route_guard.dart';
import 'support/boot_test_app.dart';

/// Router smoke tests.
///
/// Every route registered in `lib/routes/router.dart` must still resolve to a
/// page - this is the test that catches a `router.add()` left pointing at a
/// page that was renamed, moved or deleted.
///
/// Documentation: https://nylo.dev/docs/7.x/router
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nyGroup('Router', () {
    nyTest('routes are registered', () async {
      expect(NyNavigator.instance.router.getRegisteredRouteNames(), isNotEmpty);
    });

    nyWidgetTest('every registered route builds a page', (tester) async {
      Map<String, NyRouterRoute> routes = {
        ...NyNavigator.instance.router.getRegisteredRoutes(),
        ...NyNavigator.instance.router.getUnknownRoutes(),
      };

      late BuildContext buildContext;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          buildContext = context;
          return SizedBox.shrink();
        }),
      ));

      for (MapEntry<String, NyRouterRoute> route in routes.entries) {
        // Throws if the page's constructor is broken, which is the whole point.
        Widget page = route.value.view(buildContext);
        expect(page, isNotNull,
            reason: 'Route "${route.key}" did not build a page');
      }
    });

    nyTest('there is exactly one initial route and it is the home page',
        () async {
      Map<String, NyRouterRoute> routes =
          NyNavigator.instance.router.getRegisteredRoutes();

      List<String> initialRoutes = routes.entries
          .where((route) => route.value.getInitialRoute())
          .map((route) => route.key)
          .toList();

      expect(initialRoutes, [HomePage.path.name]);
    });

    nyTest('an unknown route is registered for bad deep links', () async {
      // The router only consults its *unknown route* map when it cannot match
      // a route name, so the page has to be in that map - being in the normal
      // route map with the unknown flag set is not enough.
      Map<String, NyRouterRoute> unknownRoutes =
          NyNavigator.instance.router.getUnknownRoutes();

      expect(unknownRoutes.keys, [NotFoundPage.path.name]);
      expect(unknownRoutes.values.first.getUnknownRoute(), isTrue);

      // What the framework hands back for a route name nothing matches.
      expect(NyRouter.getUnknownRoute().name, NotFoundPage.path.name);
    });

    nyTest('the pages that need a WordPress session are guarded', () async {
      Map<String, NyRouterRoute> routes =
          NyNavigator.instance.router.getRegisteredRoutes();

      for (String path in [
        AccountDetailPage.path.name,
        AccountProfileUpdatePage.path.name,
        AccountDeletePage.path.name,
        AccountShippingDetailsPage.path.name,
      ]) {
        expect(routes[path]?.getRouteGuards().whereType<AuthRouteGuard>(),
            isNotEmpty,
            reason: 'Route "$path" is missing its AuthRouteGuard');
      }

      // The login page itself must never be guarded, or it could not be
      // reached when the guard redirects to it.
      expect(routes[AccountLoginPage.path.name]?.getRouteGuards(), isEmpty);
    });
  });
}
