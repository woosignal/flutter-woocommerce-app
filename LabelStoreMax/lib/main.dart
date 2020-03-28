//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:label_storemax/pages/error_page.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/products.dart';
import 'labelconfig.dart';
import 'package:label_storemax/pages/checkout_details.dart';
import 'package:label_storemax/pages/home.dart';
import 'package:label_storemax/pages/about.dart';
import 'package:label_storemax/pages/checkout_confirmation.dart';
import 'package:label_storemax/pages/cart.dart';
import 'package:label_storemax/pages/checkout_status.dart';
import 'package:label_storemax/pages/checkout_payment_type.dart';
import 'package:label_storemax/pages/checkout_shipping_type.dart';
import 'package:label_storemax/pages/product_detail.dart';
import 'package:label_storemax/pages/browse_search.dart';
import 'package:label_storemax/pages/home_menu.dart';
import 'package:label_storemax/pages/home_search.dart';
import 'package:label_storemax/pages/browse_category.dart';
import 'package:flutter/services.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:page_transition/page_transition.dart';
import 'package:label_storemax/helpers/app_themes.dart';
import 'package:label_storemax/helpers/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    new MaterialApp(
      title: app_name,
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      initialRoute: "/home",
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/cart': (BuildContext context) => new CartPage(),
        '/error': (BuildContext context) => new ErrorPage(),
        '/checkout': (BuildContext context) => new CheckoutConfirmationPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/browse-category':
            if (settings.arguments != null) {
              final ProductCategory category =
                  settings.arguments as ProductCategory;
              return PageTransition(
                child: BrowseCategoryPage(productCategory: category),
                type: PageTransitionType.fade,
              );
            }
            return PageTransition(
              child: ErrorPage(),
              type: PageTransitionType.fade,
            );

          case '/product-search':
            if (settings.arguments != null) {
              final String search = settings.arguments as String;
              return PageTransition(
                child: BrowseSearchPage(search: search),
                type: PageTransitionType.fade,
              );
            }
            return PageTransition(
              child: ErrorPage(),
              type: PageTransitionType.fade,
            );

          case '/product-detail':
            if (settings.arguments != null) {
              final Product product = settings.arguments as Product;
              return PageTransition(
                child: ProductDetailPage(product: product),
                type: PageTransitionType.rightToLeftWithFade,
              );
            }
            return PageTransition(
              child: ErrorPage(),
              type: PageTransitionType.fade,
            );

          case '/checkout-status':
            if (settings.arguments != null) {
              final Order order = settings.arguments as Order;
              return PageTransition(
                child: CheckoutStatusPage(order: order),
                type: PageTransitionType.rightToLeftWithFade,
              );
            }
            return PageTransition(
              child: ErrorPage(),
              type: PageTransitionType.fade,
            );

          case '/home-menu':
            return PageTransition(
              child: HomeMenuPage(),
              type: PageTransitionType.leftToRightWithFade,
            );

          case '/checkout-details':
            return PageTransition(
              child: CheckoutDetailsPage(),
              type: PageTransitionType.downToUp,
            );

          case '/about':
            return PageTransition(
              child: AboutPage(),
              type: PageTransitionType.leftToRightWithFade,
            );

          case '/checkout-payment-type':
            return PageTransition(
              child: CheckoutPaymentTypePage(),
              type: PageTransitionType.downToUp,
            );

          case '/checkout-shipping-type':
            return PageTransition(
              child: CheckoutShippingTypePage(),
              type: PageTransitionType.downToUp,
            );

          case '/home-search':
            return PageTransition(
              child: HomeSearchPage(),
              type: PageTransitionType.downToUp,
            );
          default:
            return null;
        }
      },
      supportedLocales: [
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      theme: ThemeData(
        primaryColor: HexColor("#2f4ffe"),
        backgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(
          hoverColor: Colors.transparent,
          buttonColor: HexColor("#529cda"),
          colorScheme: colorSchemeButton(),
          minWidth: double.infinity,
          height: 70,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          textTheme: textThemeAppBar(),
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        accentColor: Colors.black,
        accentTextTheme: textThemeAccent(),
        textTheme: textThemeMain(),
        primaryTextTheme: textThemePrimary(),
      ),
    ),
  );
}
