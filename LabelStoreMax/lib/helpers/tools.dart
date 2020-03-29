//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:label_storemax/app_payment_methods.dart';
import 'package:label_storemax/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:math_expressions/math_expressions.dart';
import 'package:status_alert/status_alert.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/woosignal.dart';

appWooSignal(Function(WooSignal) api) async {
  WooSignal wooSignal = await WooSignal.getInstance(
      config: {"appKey": app_key, "debugMode": app_debug});
  return await api(wooSignal);
}

List<PaymentType> getPaymentTypes() {
  return arrPaymentMethods.where((v) => v != null).toList();
}

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

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

void showToastWith({String message, String statusType}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor:
          (statusType == "error" ? HexColor("#b5123a") : Colors.grey),
      textColor: (statusType == "error" ? Colors.white : Colors.black),
      fontSize: 16.0);
}

void showToastNetworkError() {
  showToastWith(message: "Oops, something went wrong");
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

class PaymentMethodType {
  static final int STRIPE = 1;
  static final int APPLEPAY = 2;
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

String formatStringCurrency({String total}) {
  double tmpVal;
  if (total == null || total == "") {
    tmpVal = 0;
  } else {
    tmpVal = double.parse(total);
  }
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
    amount: tmpVal,
    settings: MoneyFormatterSettings(
      symbol: app_currency_symbol,
    ),
  );
  return fmf.output.symbolOnLeft;
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
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

Future<double> workoutShippingCostWC({@required String sum}) async {
  List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem.map((f) => f.quantity).toList().reduce((i,d) => i+d).toString();
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
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem.length.toString();
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
