//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/app/models/billing_details.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/app/models/default_shipping.dart';
import '/app/models/payment_type.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/enums/symbol_position_enums.dart';
import '/bootstrap/extensions.dart';
import '/bootstrap/shared_pref/shared_key.dart';
import '/config/currency.dart';
import '/config/payment_gateways.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:status_alert/status_alert.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/woosignal.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import '../resources/themes/styles/color_styles.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<WpUser?> getUser() async {
  return await WPJsonAPI.wpUser();
}

Future appWooSignal(Function(WooSignal api) api) async {
  return await api(WooSignal.instance);
}

/// helper to find correct color from the [context].
class ThemeColor {
  static ColorStyles get(BuildContext context, {String? themeId}) =>
      nyColorStyle<ColorStyles>(context, themeId: themeId);

  static Color fromHex(String hexColor) => nyHexColor(hexColor);
}

/// helper to set colors on TextStyle
extension ColorsHelper on TextStyle {
  TextStyle setColor(
      BuildContext context, Color Function(BaseColorStyles? color) newColor) {
    return copyWith(color: newColor(ThemeColor.get(context)));
  }
}

Future<List<PaymentType?>> getPaymentTypes() async {
  List<PaymentType?> paymentTypes = [];
  for (var appPaymentGateway in appPaymentGateways) {
    if (paymentTypes.firstWhere(
            (paymentType) => paymentType!.name != appPaymentGateway,
            orElse: () => null) ==
        null) {
      paymentTypes.add(paymentTypeList.firstWhereOrNull(
          (paymentTypeList) => paymentTypeList.name == appPaymentGateway));
    }
  }

  if (!appPaymentGateways.contains('Stripe') &&
      AppHelper.instance.appConfig!.stripeEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "Stripe"));
  }
  if (!appPaymentGateways.contains('PayPal') &&
      AppHelper.instance.appConfig!.paypalEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "PayPal"));
  }
  if (!appPaymentGateways.contains('CashOnDelivery') &&
      AppHelper.instance.appConfig!.codEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "CashOnDelivery"));
  }

  return paymentTypes.where((v) => v != null).toList();
}

PaymentType addPayment(
        {required int id,
        required String name,
        required String description,
        required String assetImage,
        required Function pay}) =>
    PaymentType(
      id: id,
      name: name,
      desc: description,
      assetImage: assetImage,
      pay: pay,
    );

showStatusAlert(context,
    {required String title,
    required String subtitle,
    IconData? icon,
    int? duration}) {
  StatusAlert.show(
    context,
    duration: Duration(seconds: duration ?? 2),
    title: title,
    subtitle: subtitle,
    configuration: IconConfiguration(icon: icon ?? Icons.done, size: 50),
  );
}

String parseHtmlString(String? htmlString) {
  var document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}

String moneyFormatter(double amount) {
  MoneyFormatter fmf = MoneyFormatter(
    amount: amount,
    settings: MoneyFormatterSettings(
        symbol: AppHelper.instance.appConfig!.currencyMeta!.symbolNative,
        symbolAndNumberSeparator: ""),
  );
  if (appCurrencySymbolPosition == SymbolPositionType.left) {
    return fmf.output.symbolOnLeft;
  } else if (appCurrencySymbolPosition == SymbolPositionType.right) {
    return fmf.output.symbolOnRight;
  }
  return fmf.output.symbolOnLeft;
}

String formatDoubleCurrency({required double total}) {
  return moneyFormatter(total);
}

String formatStringCurrency({required String? total}) {
  double tmpVal = 0;
  if (total != null && total != "") {
    tmpVal = parseWcPrice(total);
  }
  return moneyFormatter(tmpVal);
}

String workoutSaleDiscount(
    {required String? salePrice, required String? priceBefore}) {
  double dSalePrice = parseWcPrice(salePrice);
  double dPriceBefore = parseWcPrice(priceBefore);
  return ((dPriceBefore - dSalePrice) * (100 / dPriceBefore))
      .toStringAsFixed(0);
}

openBrowserTab({required String url}) async {
  await FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      defaultColorSchemeParams:
          CustomTabsColorSchemeParams(toolbarColor: Colors.white70),
    ),
  );
}

bool isNumeric(String? str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

checkout(
    TaxRate? taxRate,
    Function(String total, BillingDetails? billingDetails, Cart cart)
        completeCheckout) async {
  String cartTotal = await CheckoutSession.getInstance
      .total(withFormat: false, taxRate: taxRate);
  BillingDetails? billingDetails = CheckoutSession.getInstance.billingDetails;
  Cart cart = Cart.getInstance;
  return await completeCheckout(cartTotal, billingDetails, cart);
}

double? strCal({required String sum}) {
  if (sum == "") {
    return 0;
  }
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

Future<double?> workoutShippingCostWC({required String? sum}) async {
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
    String newSum = replace.group(1)!;

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent.groupCount >= 1) {
        String strPercentage =
            "( ($orderTotal * ${replacePercent.group(1)}) / 100 )";
        double? calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage! < doubleMinFee) {
            return "($doubleMinFee)";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage! > doubleMaxFee) {
            return "($doubleMaxFee)";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "($calPercentage)";
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

Future<double?> workoutShippingClassCostWC(
    {required String? sum, List<CartLineItem>? cartLineItem}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem!
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
    String newSum = replace.group(1)!;

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent.groupCount >= 1) {
        String strPercentage =
            "( ($orderTotal * ${replacePercent.group(1)}) / 100 )";
        double? calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage! < doubleMinFee) {
            return "($doubleMinFee)";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage! > doubleMaxFee) {
            return "($doubleMaxFee)";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "($calPercentage)";
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
  bool? strict,
}) {
  return RegExp(
    pattern,
    caseSensitive: strict ?? false,
    multiLine: false,
  );
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(em);
}

navigatorPush(BuildContext context,
    {required String routeName,
    Object? arguments,
    bool forgetAll = false,
    int? forgetLast}) {
  if (forgetAll) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
  if (forgetLast != null) {
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == forgetLast;
    });
  }
  Navigator.of(context).pushNamed(routeName, arguments: arguments);
}

DateTime parseDateTime(String strDate) => DateTime.parse(strDate);

DateFormat formatDateTime(String format) => DateFormat(format);

String dateFormatted({required String date, required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  dateTime,
  date,
  time,
}

String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.date:
      {
        return "yyyy-MM-dd";
      }
    case FormatType.dateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.time:
      {
        return "hh:mm a";
      }
    default:
      {
        return "";
      }
  }
}

double parseWcPrice(String? price) => (double.tryParse(price ?? "0") ?? 0);

class UserAuth {
  UserAuth._privateConstructor();
  static final UserAuth instance = UserAuth._privateConstructor();

  String redirect = "/home";
}

Future<List<DefaultShipping>> getDefaultShipping() async {
  String data =
      await rootBundle.loadString('public/assets/json/default_shipping.json');
  dynamic dataJson = json.decode(data);
  List<DefaultShipping> shipping = [];

  dataJson.forEach((key, value) {
    DefaultShipping defaultShipping =
        DefaultShipping(code: key, country: value['country'], states: []);
    if (value['states'] != null) {
      value['states'].forEach((key1, value2) {
        defaultShipping.states
            .add(DefaultShippingState(code: key1, name: value2));
      });
    }
    shipping.add(defaultShipping);
  });
  return shipping;
}

Future<DefaultShipping?> findCountryMetaForShipping(String countryCode) async {
  List<DefaultShipping> defaultShipping = await getDefaultShipping();
  List<DefaultShipping> shippingByCountryCode =
      defaultShipping.where((element) => element.code == countryCode).toList();
  if (shippingByCountryCode.isNotEmpty) {
    return shippingByCountryCode.first;
  }
  return null;
}

DefaultShippingState? findDefaultShippingStateByCode(
    DefaultShipping defaultShipping, String code) {
  List<DefaultShippingState> defaultShippingStates =
      defaultShipping.states.where((state) => state.code == code).toList();
  if (defaultShippingStates.isEmpty) {
    return null;
  }
  DefaultShippingState defaultShippingState = defaultShippingStates.first;
  return DefaultShippingState(
      code: defaultShippingState.code, name: defaultShippingState.name);
}

bool hasKeyInMeta(WPUserInfoResponse wpUserInfoResponse, String key) {
  return (wpUserInfoResponse.data!.metaData ?? [])
      .where((meta) => meta.key == key)
      .toList()
      .isNotEmpty;
}

String fetchValueInMeta(WPUserInfoResponse wpUserInfoResponse, String key) {
  String value = "";
  List<dynamic>? metaDataValue = (wpUserInfoResponse.data!.metaData ?? [])
      .where((meta) => meta.key == key)
      .first
      .value;
  if (metaDataValue != null && metaDataValue.isNotEmpty) {
    return metaDataValue.first ?? "";
  }
  return value;
}

String truncateString(String data, int length) {
  return (data.length >= length) ? '${data.substring(0, length)}...' : data;
}

Future<List<dynamic>> getWishlistProducts() async {
  List<dynamic> favouriteProducts = [];
  String? currentProductsJSON =
      await (NyStorage.read(SharedKey.wishlistProducts));
  if (currentProductsJSON != null) {
    favouriteProducts = (jsonDecode(currentProductsJSON)).toList();
  }
  return favouriteProducts;
}

hasAddedWishlistProduct(int? productId) async {
  List<dynamic> favouriteProducts = await getWishlistProducts();
  List<int> productIds =
      favouriteProducts.map((e) => e['id']).cast<int>().toList();
  if (productIds.isEmpty) {
    return false;
  }
  return productIds.contains(productId);
}

saveWishlistProduct({required Product? product}) async {
  List<dynamic> products = await getWishlistProducts();
  if (products.any((wishListProduct) => wishListProduct['id'] == product!.id) ==
      false) {
    products.add({"id": product!.id});
  }
  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(SharedKey.wishlistProducts, json);
}

removeWishlistProduct({required Product? product}) async {
  List<dynamic> products = await getWishlistProducts();
  products.removeWhere((element) => element['id'] == product!.id);

  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(SharedKey.wishlistProducts, json);
}

Future<BillingDetails> billingDetailsFromWpUserInfoResponse(
    wpUserInfoResponse) async {
  List<String> metaDataAddress = [
    'billing_first_name',
    'billing_last_name',
    'billing_company',
    'billing_address_1',
    'billing_address_2',
    'billing_city',
    'billing_postcode',
    'billing_country',
    'billing_state',
    'billing_phone',
    'billing_email',
    'shipping_first_name',
    'shipping_last_name',
    'shipping_company',
    'shipping_address_1',
    'shipping_address_2',
    'shipping_city',
    'shipping_postcode',
    'shipping_country',
    'shipping_state',
    'shipping_phone',
  ];

  Map<String, String> metaData = {};

  for (var dataKey in metaDataAddress) {
    if (hasKeyInMeta(wpUserInfoResponse, dataKey)) {
      String value = fetchValueInMeta(wpUserInfoResponse, dataKey);
      metaData.addAll({dataKey: value});
    }
  }

  BillingDetails billingDetails = BillingDetails();
  await billingDetails.fromWpMeta(metaData);
  return billingDetails;
}

/// Check if the [Product] is new.
bool isProductNew(Product? product) {
  if (product?.dateCreatedGMT == null) false;
  try {
    DateTime dateTime = DateTime.parse(product!.dateCreatedGMT!);
    return dateTime.isBetween(
            DateTime.now().subtract(Duration(days: 2)), DateTime.now()) ??
        false;
  } on Exception catch (e) {
    NyLogger.error(e.toString());
  }
  return false;
}

bool shouldEncrypt() {
  String? encryptKey = getEnv('ENCRYPT_KEY', defaultValue: "");
  if (encryptKey == null || encryptKey == "") {
    return false;
  }
  String? encryptSecret = getEnv('ENCRYPT_KEY', defaultValue: "");
  if (encryptSecret == null || encryptSecret == "") {
    return false;
  }
  return true;
}

bool isFirebaseEnabled() {
  bool? firebaseFcmIsEnabled =
      AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
  firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

  return firebaseFcmIsEnabled == true;
}

class NotificationItem extends Model {
  String? id;
  String? title;
  String? message;
  bool? hasRead;
  String? type;
  Map<String, dynamic>? meta;
  String? createdAt;

  NotificationItem(
      {this.title,
      this.message,
      this.id,
      this.type,
      this.meta,
      this.createdAt,
      this.hasRead = false});

  NotificationItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        type = json['type'],
        meta = json['meta'],
        message = json['message'],
        hasRead = json['has_read'],
        createdAt = json['created_at'];

  fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    meta = json['meta'];
    message = json['message'];
    hasRead = json['has_read'];
    createdAt = json['created_at'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'meta': meta,
        'message': message,
        'has_read': hasRead,
        "created_at": createdAt
      };
}

class NyNotification {
  static final String _storageKey = "app_notifications";

  static String storageKey() => _storageKey;

  /// Add a notification
  static addNotification(String title, String message,
      {String? id, Map<String, dynamic>? meta}) async {
    NotificationItem notificationItem = NotificationItem.fromJson({
      "id": id,
      "title": title,
      "message": message,
      "meta": meta,
      "has_read": false,
      "created_at": DateTime.now().toDateTimeString()
    });
    await NyStorage.addToCollection<NotificationItem>(storageKey(),
        item: notificationItem,
        allowDuplicates: false,
        modelDecoders: {
          NotificationItem: (data) => NotificationItem.fromJson(data),
        });
  }

  /// Get all notifications
  static Future<List<NotificationItem>> allNotifications() async {
    List<NotificationItem> notifications =
        await NyStorage.readCollection<NotificationItem>("app_notifications",
            modelDecoders: {
          NotificationItem: (data) => NotificationItem.fromJson(data),
        });
    String? userId = await WPJsonAPI.wpUserId();
    notifications.removeWhere((notification) {
      if (notification.meta != null &&
          notification.meta!.containsKey('user_id')) {
        if (notification.meta?['user_id'] != userId) {
          return true;
        }
      }
      return false;
    });

    await NyStorage.saveCollection(storageKey(), notifications);

    return notifications;
  }

  /// Get all notifications not read
  static Future<List<NotificationItem>> allNotificationsNotRead() async {
    List<NotificationItem> notifications = await allNotifications();
    return notifications.where((element) => element.hasRead == false).toList();
  }

  /// Mark notification as read by index
  static markReadByIndex(int index) async {
    await NyStorage.updateCollectionByIndex(index, (item) {
      item as NotificationItem;
      item.hasRead = true;
      return item;
    }, key: storageKey());
  }

  /// Mark all notifications as read
  static markReadAll() async {
    List<NotificationItem> notifications = await allNotifications();
    for (var i = 0; i < notifications.length; i++) {
      await markReadByIndex(i);
    }
  }

  /// Clear all notifications
  static clearAllNotifications() async {
    await NyStorage.deleteCollection(storageKey());
  }

  /// Render notifications
  static Widget renderNotifications(
      Widget Function(List<NotificationItem> notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return child(data);
        },
        loading: loading);
  }

  /// Render list of notifications
  static Widget renderListNotifications(
      Widget Function(NotificationItem notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return NyListView(child: (context, item) {
            item as NotificationItem;
            return child(item);
          }, data: () async {
            return data.reversed.toList();
          });
        },
        loading: loading);
  }

  /// Render list of notifications
  static Widget renderListNotificationsWithSeparator(
      Widget Function(NotificationItem notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return NyListView.separated(
            child: (context, item) {
              item as NotificationItem;
              return child(item);
            },
            data: () async {
              return data.reversed.toList();
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey.shade100,
              );
            },
          );
        },
        loading: loading);
  }
}

Future<bool> canSeeRemoteMessage(RemoteMessage message) async {
  if (!message.data.containsKey('user_id')) {
    return true;
  }

  String userId = message.data['user_id'];

  if ((await WPJsonAPI.wpUserLoggedIn()) != true) {
    return false;
  }

  String? currentUserId = await WPJsonAPI.wpUserId();
  if (currentUserId != userId) {
    return false;
  }
  return true;
}
