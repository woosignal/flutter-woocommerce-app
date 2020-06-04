//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:label_storemax/app_payment_methods.dart';
import 'package:label_storemax/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:label_storemax/models/billing_details.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/payment_type.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:status_alert/status_alert.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/woosignal.dart';

appWooSignal(Function(WooSignal) api) async {
  WooSignal wooSignal = await WooSignal.getInstance(
      config: {"appKey": app_key, "debugMode": app_debug});
  return await api(wooSignal);
}

List<PaymentType> getPaymentTypes() =>
    arrPaymentMethods.where((v) => v != null).toList();

PaymentType addPayment(PaymentType paymentType) {
  return app_payment_methods.contains(paymentType.name) ? paymentType : null;
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

showStatusAlert(context,
    {@required String title, String subtitle, IconData icon, int duration}) {
  StatusAlert.show(
    context,
    duration: Duration(seconds: duration ?? 2),
    title: title,
    subtitle: subtitle,
    configuration: IconConfiguration(icon: icon ?? Icons.done, size: 50),
  );
}

class EdgeAlertStyle {
  static final int SUCCESS = 1;
  static final int WARNING = 2;
  static final int INFO = 3;
  static final int DANGER = 4;
}

void showEdgeAlertWith(context,
    {title = "", desc = "", int gravity = 1, int style = 1, IconData icon}) {
  switch (style) {
    case 1: // SUCCESS
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.green,
          icon: icon ?? Icons.check,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 2: // WARNING
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.orange,
          icon: icon ?? Icons.error_outline,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 3: // INFO
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.teal,
          icon: icon ?? Icons.info,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 4: // DANGER
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.redAccent,
          icon: icon ?? Icons.warning,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    default:
      break;
  }
}

String parseHtmlString(String htmlString) {
  var document = parse(htmlString);
  String parsedString = parse(document.body.text).documentElement.text;
  return parsedString;
}

String formatDoubleCurrency({double total}) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
    amount: total,
    settings: MoneyFormatterSettings(
      symbol: app_currency_symbol,
    ),
  );
  return fmf.output.symbolOnLeft;
}

String formatStringCurrency({@required String total}) {
  double tmpVal;
  if (total == null || total == "") {
    tmpVal = 0;
  } else {
    tmpVal = parseWcPrice(total);
  }
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
    amount: tmpVal,
    settings: MoneyFormatterSettings(
      symbol: app_currency_symbol,
    ),
  );
  return fmf.output.symbolOnLeft;
}

String workoutSaleDiscount(
    {@required String salePrice, @required String priceBefore}) {
  double dSalePrice = parseWcPrice(salePrice);
  double dPriceBefore = parseWcPrice(priceBefore);
  return ((dPriceBefore - dSalePrice) * (100 / dPriceBefore))
      .toStringAsFixed(0);
}

openBrowserTab({@required String url}) async {
  await FlutterWebBrowser.openWebPage(
      url: url, androidToolbarColor: Colors.white70);
}

EdgeInsets safeAreaDefault() {
  return EdgeInsets.only(left: 16, right: 16, bottom: 8);
}

String trans(BuildContext context, String key) {
  return AppLocalizations.of(context).trans(key);
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

checkout(
    TaxRate taxRate,
    Function(String total, BillingDetails billingDetails, Cart cart)
        completeCheckout) async {
  String cartTotal = await CheckoutSession.getInstance
      .total(withFormat: false, taxRate: taxRate);
  BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;
  Cart cart = Cart.getInstance;
  return await completeCheckout(cartTotal, billingDetails, cart);
}

double strCal({@required String sum}) {
  if (sum == null || sum == "") {
    return 0;
  }
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

Future<double> workoutShippingCostWC({@required String sum}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1);

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent != null && replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

Future<double> workoutShippingClassCostWC(
    {@required String sum, List<CartLineItem> cartLineItem}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1);

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent != null && replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

RegExp defaultRegex(
  String pattern, {
  bool strict,
}) {
  return new RegExp(
    pattern,
    caseSensitive: strict ?? false,
    multiLine: false,
  );
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(em);
}

// 6 LENGTH, 1 DIGIT
bool validPassword(String pw) {
  String p = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(pw);
}

navigatorPush(BuildContext context,
    {@required String routeName,
    Object arguments,
    bool forgetAll = false,
    int forgetLast}) {
  if (forgetAll) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments ?? null);
  }
  if (forgetLast != null) {
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == forgetLast;
    });
  }
  Navigator.of(context).pushNamed(routeName, arguments: arguments ?? null);
}

PlatformDialogAction dialogAction(BuildContext context,
    {@required title, ActionType actionType, Function() action}) {
  return PlatformDialogAction(
    actionType: actionType ?? ActionType.Default,
    child: Text(title ?? ""),
    onPressed: action ??
        () {
          Navigator.of(context).pop();
        },
  );
}

showPlatformAlertDialog(BuildContext context,
    {String title,
    String subtitle,
    List<PlatformDialogAction> actions,
    bool showDoneAction = true}) {
  if (showDoneAction) {
    actions
        .add(dialogAction(context, title: trans(context, "Done"), action: () {
      Navigator.of(context).pop();
    }));
  }
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return PlatformAlertDialog(
        title: Text(title ?? ""),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(subtitle ?? ""),
            ],
          ),
        ),
        actions: actions,
      );
    },
  );
}

DateTime parseDateTime(String strDate) => DateTime.parse(strDate);

DateFormat formatDateTime(String format) => DateFormat(format);

String dateFormatted({@required String date, @required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  DateTime,

  Date,

  Time,
}

String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.Date:
      {
        return "yyyy-MM-dd";
      }
    case FormatType.DateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.Time:
      {
        return "hh:mm a";
      }
    default:
      {
        return "";
      }
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

double parseWcPrice(String price) => (double.tryParse(price) ?? 0);

Widget refreshableScroll(context,
    {@required refreshController,
    @required VoidCallback onRefresh,
    @required VoidCallback onLoading,
    @required List<Product> products,
    @required onTap,
    key}) {
  return SmartRefresher(
    enablePullDown: true,
    enablePullUp: true,
    footer: CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text(trans(context, "pull up load"));
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text(trans(context, "Load Failed! Click retry!"));
        } else if (mode == LoadStatus.canLoading) {
          body = Text(trans(context, "release to load more"));
        } else {
          body = Text(trans(context, "No more products"));
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    ),
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoading,
    child: (products.length != null && products.length > 0
        ? GridView.count(
            crossAxisCount: 2,
            childAspectRatio: calAspectRatio(context),
            shrinkWrap: true,
            children: List.generate(
              products.length,
              (index) => wsCardProductItem(context,
                  index: index, product: products[index], onTap: onTap),
            ))
        : wsNoResults(context)),
  );
}

double calAspectRatio(BuildContext context) {
  if (MediaQuery.of(context).size.height > 800) {
    return MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.height / 1.75);
  }
  if (MediaQuery.of(context).size.height > 700) {
    return MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.height / 1.5);
  }
  return MediaQuery.of(context).size.width /
      (MediaQuery.of(context).size.height / 1.3);
}

class UserAuth {
  UserAuth._privateConstructor();
  static final UserAuth instance = UserAuth._privateConstructor();

  String redirect = "/home";
}
