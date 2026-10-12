import '/bootstrap/app_helper.dart';
import '/routes/router.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RouteProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    nylo.addRouter(appRouter());

    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    if (AppHelper.instance.appConfig?.appStatus == null) {
      nylo.initRoutes(initialRoute: '/no-connection');
      return;
    }
    nylo.initRoutes();
  }
}
