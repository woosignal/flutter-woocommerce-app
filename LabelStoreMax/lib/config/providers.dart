import 'package:flutter_app/app/providers/app_provider.dart';
import 'package:flutter_app/app/providers/event_provider.dart';
import 'package:flutter_app/app/providers/route_provider.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| Providers
| Add your "app/providers" here.
| Providers are booted when your application start.
|
| Learn more: https://nylo.dev/docs/4.x/providers
|--------------------------------------------------------------------------
*/

final Map<Type, NyProvider> providers = {
  AppProvider: AppProvider(),
  RouteProvider: RouteProvider(),
  EventProvider: EventProvider(),
};
