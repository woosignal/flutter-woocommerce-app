import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/routes/router.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RouteProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    nylo.addRouter(appRouter());

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {
    String initialRoute = AppHelper.instance.appConfig!.appStatus != null
        ? '/home'
        : '/no-connection';
    nylo.setInitialRoute(initialRoute);
  }
}
