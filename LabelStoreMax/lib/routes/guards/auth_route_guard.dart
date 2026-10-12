//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import '/bootstrap/app_helper.dart';
import '/resources/pages/account_login_page.dart';
import '/resources/pages/account_register_page.dart';
import '/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/wp_json_api.dart';

/* Auth Route Guard
|--------------------------------------------------------------------------
| Blocks the routes that need a WordPress user session and sends the visitor
| to the login page instead, remembering where they were heading.
|
| * [Tip] Create new route guards using the CLI 🚀
| Run the below in the terminal to create a new route guard.
| "dart run nylo_framework:main make:route_guard check_subscription"
|
| Learn more https://nylo.dev/docs/7.x/route-guards
|-------------------------------------------------------------------------- */

class AuthRouteGuard extends NyRouteGuard {
  AuthRouteGuard();

  @override
  Future<GuardResult> onBefore(RouteContext<dynamic> context) async {
    // Stores can turn WordPress logins off in the WooSignal dashboard. When
    // they do there is no account to sign in to, so the route stays open -
    // this is the same check every call site made before the guard existed.
    if (AppHelper.instance.appConfig?.wpLoginEnabled != 1) {
      return next();
    }

    if (await WPJsonAPI.wpUserLoggedIn()) {
      return next();
    }

    return redirect(
      AccountLoginPage.path,
      data: {
        intendedRouteKey: context.routeName,
        intendedRouteDataKey: context.data,
      },
      // Push, don't replace: the visitor keeps whatever they were looking at
      // underneath the login page, exactly like the old
      // `routeTo(AccountLoginPage.path)` call sites did.
      navigationType: NavigationType.push,
    );
  }
}

/// Key holding the route [AuthRouteGuard] blocked, inside the data it hands to
/// [AccountLoginPage].
const String intendedRouteKey = "intended_route";

/// Key holding the data that route was called with.
const String intendedRouteDataKey = "intended_route_data";

/// Send a freshly authenticated user on to the route they originally asked for.
///
/// [routeData] is the login/registration page's own route data, i.e. the map
/// [AuthRouteGuard] built. Pass it straight from `widget.data()`.
///
/// The login and registration pages are dropped from the back stack on the way
/// through, so the back button returns to whatever the visitor was doing before
/// they were asked to sign in.
///
/// With no intended route - the account tab in the `notic`/`compo` themes
/// builds [AccountLoginPage] directly rather than routing to it - the whole
/// stack is replaced with a fresh home page, so the tab bar rebuilds and the
/// account tab picks up the new session.
Future<void> routeToIntended(dynamic routeData) async {
  if (routeData is Map && routeData[intendedRouteKey] is String) {
    await routeTo(routeData[intendedRouteKey],
        data: routeData[intendedRouteDataKey],
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (route) =>
            route.settings.name != AccountLoginPage.path.name &&
            route.settings.name != AccountRegistrationPage.path.name);
    return;
  }
  await routeTo(HomePage.path,
      navigationType: NavigationType.pushAndForgetAll);
}
