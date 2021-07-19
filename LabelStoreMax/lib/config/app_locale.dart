import 'package:flutter/cupertino.dart';

/*
|--------------------------------------------------------------------------
| APP LOCALE
|
| Configure the language by setting the locale.
|
| e.g. Change app_locale = Locale('es'); for Spanish.
| You can only use one of the supported locales below in app_locales_supported.
|--------------------------------------------------------------------------
*/

const Locale app_locale = null; // by default it will use the "DEFAULT_LOCALE" value from the /.env
// const Locale app_locale = Locale('en'); // uncomment to change the locale here too.

const List<Locale> app_locales_supported = [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hi'),
  Locale('it'),
  Locale('pt'),
  Locale('zh'),
];
