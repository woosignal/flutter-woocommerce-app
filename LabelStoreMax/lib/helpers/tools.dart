//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2019 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:label_storemax/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'dart:convert';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:woosignal/models/response/shipping_method.dart';
import 'package:woosignal/models/response/tax_rate.dart';

// CONFIG FOR WOOSIGNAL API
var wsConfig = {"appKey": app_key, "debugMode": app_debug};

// MARK: PaymentMethodType
class PaymentType {
  int id;
  String name;
  String assetImage;

  PaymentType({this.id, this.name, this.assetImage});
}

List<PaymentType> arrPaymentMethods = [
  (paymentMethods.contains("Stripe")
      ? (PaymentType(
          id: 1,
          name: "Debit or Credit Card",
          assetImage: "dark_powered_by_stripe.png"))
      : null)
];

List<PaymentType> getPaymentTypes() {
  return arrPaymentMethods;
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

class TextFieldMaker extends TextField {
  static TextField makeWith(labelTitle) {
    return TextField(
      decoration: InputDecoration(
          labelText: labelTitle,
          labelStyle: TextStyle(
              fontFamily: 'Overpass',
              fontWeight: FontWeight.bold,
              color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green))),
      keyboardAppearance: Brightness.light,
      keyboardType: TextInputType.emailAddress,
    );
  }
}

void showToastWith({String message, String statusType}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 3,
      backgroundColor:
          (statusType == "error" ? HexColor("#b5123a") : Colors.grey),
      textColor: (statusType == "error" ? Colors.white : Colors.black),
      fontSize: 16.0);
}

void showToastNetworkError() {
  showToastWith(message: "Oops, something went wrong");
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

Widget showAppLoader() {
  return SpinKitDoubleBounce(color: HexColor("#393318"));
}

Future delayFunction(void Function() action) {
  return Future.delayed(const Duration(milliseconds: 300), action);
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

void errorWithNetworkDefault(BuildContext context) {
  showEdgeAlertWith(context,
      title: trans(context, "Oops"),
      desc: trans(context, "Something went wrong"),
      style: EdgeAlertStyle.DANGER);
}

String parseHtmlString(String htmlString) {
  var document = parse(htmlString);
  String parsedString = parse(document.body.text).documentElement.text;
  return parsedString;
}

class CartLineItem {
  String name;
  int productId;
  int variationId;
  int quantity;
  bool isManagedStock;
  int stockQuantity;
  String shippingClassId;
  String taxStatus;
  String taxClass;
  bool shippingIsTaxable;
  String subtotal;
  String total;
  String imageSrc;
  String variationOptions;
  String stockStatus;
  Object metaData = {};

  CartLineItem(
      {this.name,
      this.productId,
      this.variationId,
      this.isManagedStock,
      this.stockQuantity,
      this.quantity,
      this.stockStatus,
      this.shippingClassId,
      this.taxStatus,
      this.taxClass,
      this.shippingIsTaxable,
      this.variationOptions,
      this.imageSrc,
      this.subtotal,
      this.total,
      this.metaData});

  CartLineItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        productId = json['product_id'],
        variationId = json['variation_id'],
        quantity = json['quantity'],
        shippingClassId = json['shipping_class_id'].toString(),
        taxStatus = json['tax_status'],
        stockQuantity = json['stock_quantity'],
        isManagedStock = json['is_managed_stock'],
        shippingIsTaxable = json['shipping_is_taxable'],
        subtotal = json['subtotal'],
        total = json['total'],
        taxClass = json['tax_class'],
        stockStatus = json['stock_status'],
        imageSrc = json['image_src'],
        variationOptions = json['variation_options'],
        metaData = json['metaData'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'product_id': productId,
        'variation_id': variationId,
        'quantity': quantity,
        'shipping_class_id': shippingClassId,
        'tax_status': taxStatus,
        'tax_class': taxClass,
        'stock_status': stockStatus,
        'is_managed_stock': isManagedStock,
        'stock_quantity': stockQuantity,
        'shipping_is_taxable': shippingIsTaxable,
        'image_src': imageSrc,
        'variation_options': variationOptions,
        'subtotal': subtotal,
        'total': total,
        'meta_data': metaData,
      };
}

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}

class CustomerAddress {
  String firstName;
  String lastName;
  String addressLine;
  String city;
  String postalCode;
  String country;
  String emailAddress;

  CustomerAddress(
      {this.firstName,
      this.lastName,
      this.addressLine,
      this.city,
      this.postalCode,
      this.country,
      this.emailAddress});

  void initAddress() {
    firstName = "";
    lastName = "";
    addressLine = "";
    city = "";
    postalCode = "";
    country = "";
    emailAddress = "";
  }

  bool hasMissingFields() {
    return (this.firstName.isEmpty ||
        this.lastName.isEmpty ||
        this.addressLine.isEmpty ||
        this.city.isEmpty ||
        this.postalCode.isEmpty);
  }

  String addressFull() {
    List<String> tmpArrAddress = new List<String>();
    if (addressLine != "") {
      tmpArrAddress.add(addressLine);
    }
    if (city != "") {
      tmpArrAddress.add(city);
    }
    if (postalCode != "") {
      tmpArrAddress.add(postalCode);
    }
    if (country != "") {
      tmpArrAddress.add(country);
    }
    return tmpArrAddress.join(", ");
  }

  String nameFull() {
    List<String> tmpArrName = new List<String>();
    if (firstName != "") {
      tmpArrName.add(firstName);
    }
    if (lastName != "") {
      tmpArrName.add(lastName);
    }
    return tmpArrName.join(", ");
  }

  CustomerAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    addressLine = json['address_line'];
    city = json['city'];
    postalCode = json['postal_code'];
    country = json['country'];
    emailAddress = json['email_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address_line'] = this.addressLine;
    data['city'] = this.city;
    data['postal_code'] = this.postalCode;
    data['country'] = this.country;
    data['email_address'] = this.emailAddress;
    return data;
  }
}

class BillingDetails {
  CustomerAddress billingAddress;
  CustomerAddress shippingAddress;
  bool rememberDetails;

  void initSession() {
    billingAddress = CustomerAddress();
    shippingAddress = CustomerAddress();
  }
}

class PaymentDetails {
  String method;
}

String formatDoubleCurrency({double total}) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
      amount: total,
      settings: MoneyFormatterSettings(
        symbol: app_currency_symbol,
      ));
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
      ));
  return fmf.output.symbolOnLeft;
}

class ShippingType {
  String methodId;
  String cost;
  dynamic object;

  ShippingType({this.methodId, this.object, this.cost});

  Map<String, dynamic> toJson() =>
      {'methodId': methodId, 'object': object, 'cost': cost};

  String getTotal({bool withFormatting}) {
    if (this.methodId != null && this.object != null) {
      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : flatRate.cost);
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : freeShipping.cost);
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : localPickup.cost);
        default:
          return "0";
          break;
      }
    }
    return "0";
  }

  String getTitle() {
    if (this.methodId != null && this.object != null) {
      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          return flatRate.title;
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          return freeShipping.title;
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          return localPickup.title;
        default:
          return "";
          break;
      }
    }
    return "";
  }

  Map<String, dynamic> toShippingLineFee() {
    if (this.methodId != null && this.object != null) {
      Map<String, dynamic> tmpShippingLinesObj = {};

      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          tmpShippingLinesObj["method_title"] = flatRate.title;
          tmpShippingLinesObj["method_id"] = flatRate.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          tmpShippingLinesObj["method_title"] = freeShipping.title;
          tmpShippingLinesObj["method_id"] = freeShipping.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          tmpShippingLinesObj["method_title"] = localPickup.title;
          tmpShippingLinesObj["method_id"] = localPickup.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        default:
          return null;
          break;
      }
      return tmpShippingLinesObj;
    }

    return null;
  }
}

class CheckoutSession {
  String sfKeyCheckout = "CS_BILLING_DETAILS";
  CheckoutSession._privateConstructor();
  static final CheckoutSession getInstance =
      CheckoutSession._privateConstructor();

  BillingDetails billingDetails;
  ShippingType shippingType;
  PaymentType paymentType;

  void initSession() {
    billingDetails = BillingDetails();
    shippingType = null;
  }

  void saveBillingAddress() {
    SharedPref sharedPref = SharedPref();
    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails.billingAddress;

    String billingAddress = jsonEncode(customerAddress.toJson());
    sharedPref.save(sfKeyCheckout, billingAddress);
  }

  Future<CustomerAddress> getBillingAddress() async {
    SharedPref sharedPref = SharedPref();

    String strCheckoutDetails = await sharedPref.read(sfKeyCheckout);

    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  void clearBillingAddress() {
    SharedPref sharedPref = SharedPref();
    sharedPref.remove(sfKeyCheckout);
  }

  Future<String> total({bool withFormat, TaxRate taxRate}) async {
    double totalCart = double.parse(await Cart.getInstance.getTotal());
    double totalShipping = 0;
    if (shippingType != null && shippingType.object != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          totalShipping = double.parse(shippingType.cost);
          break;
        case "free_shipping":
          totalShipping = double.parse(shippingType.cost);
          break;
        case "local_pickup":
          totalShipping = double.parse(shippingType.cost);
          break;
        default:
          break;
      }
    }

    double total = totalCart + totalShipping;

    if (taxRate != null) {
      String taxAmount = await Cart.getInstance.taxAmount(taxRate);
      total += double.parse(taxAmount);
    }

    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toString();
  }
}

class Cart {
  String _keyCart = "CART_SESSION";

  Cart._privateConstructor();
  static final Cart getInstance = Cart._privateConstructor();

  Future<List<CartLineItem>> getCart() async {
    List<CartLineItem> cartLineItems = [];
    SharedPref sharedPref = SharedPref();
    String currentCartArrJSON = (await sharedPref.read(_keyCart) as String);
    if (currentCartArrJSON == null) {
      cartLineItems = List<CartLineItem>();
    } else {
      cartLineItems = (jsonDecode(currentCartArrJSON) as List<dynamic>)
          .map((i) => CartLineItem.fromJson(i))
          .toList();
    }
    return cartLineItems;
  }

  void addToCart({CartLineItem cartLineItem}) async {
    List<CartLineItem> cartLineItems = await getCart();
    var firstCartItem = cartLineItems.firstWhere(
        (i) =>
            i.productId == cartLineItem.productId ||
            i.productId == cartLineItem.productId &&
                i.variationId == cartLineItem.variationId, orElse: () {
      return null;
    });
    if (firstCartItem != null) {
      return;
    }
    cartLineItems.add(cartLineItem);

    saveCartToPref(cartLineItems: cartLineItems);
  }

  Future<String> getTotal({bool withFormat}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double total = 0;
    cartLineItems.forEach((cartItem) {
      total += (double.parse(cartItem.total) * cartItem.quantity);
    });

    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toString();
  }

  Future<String> getSubtotal({bool withFormat}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double subtotal = 0;
    cartLineItems.forEach((cartItem) {
      subtotal += (double.parse(cartItem.subtotal) * cartItem.quantity);
    });
    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: subtotal);
    }
    return subtotal.toString();
  }

  void updateQuantity(
      {CartLineItem cartLineItem, int incrementQuantity}) async {
    List<CartLineItem> cartLineItems = await getCart();
    List<CartLineItem> tmpCartItem = new List<CartLineItem>();
    cartLineItems.forEach((cartItem) {
      if (cartItem.variationId == cartLineItem.variationId &&
          cartItem.productId == cartLineItem.productId) {
        if ((cartItem.quantity + incrementQuantity) > 0) {
          cartItem.quantity += incrementQuantity;
        }
      }
      tmpCartItem.add(cartItem);
    });
    saveCartToPref(cartLineItems: tmpCartItem);
  }

  Future<String> cartShortDesc() async {
    List<CartLineItem> cartLineItems = await getCart();
    var tmpShortItemDesc = [];
    cartLineItems.forEach((cartItem) {
      tmpShortItemDesc
          .add(cartItem.quantity.toString() + " x | " + cartItem.name);
    });
    return tmpShortItemDesc.join(",");
  }

  void removeCartItemForIndex({int index}) async {
    List<CartLineItem> cartLineItems = await getCart();
    cartLineItems.removeAt(index);
    saveCartToPref(cartLineItems: cartLineItems);
  }

  void clear() {
    SharedPref sharedPref = SharedPref();
    List<CartLineItem> cartLineItems = new List<CartLineItem>();
    String jsonArrCartItems =
        jsonEncode(cartLineItems.map((i) => i.toJson()).toList());
    sharedPref.save(_keyCart, jsonArrCartItems);
  }

  void saveCartToPref({List<CartLineItem> cartLineItems}) {
    SharedPref sharedPref = SharedPref();
    String jsonArrCartItems =
        jsonEncode(cartLineItems.map((i) => i.toJson()).toList());
    sharedPref.save(_keyCart, jsonArrCartItems);
  }

  Future<String> taxAmount(TaxRate taxRate) async {
    double subtotal = 0;
    double shippingTotal = 0;

    List<CartLineItem> cartItems = await Cart.getInstance.getCart();
    if (cartItems.every((c) => c.taxStatus == 'none')) {
      return "0";
    }
    List<CartLineItem> taxableCartLines =
        cartItems.where((c) => c.taxStatus == 'taxable').toList();
    double cartSubtotal = 0;

    if (taxableCartLines.length > 0) {
      cartSubtotal = taxableCartLines
          .map<double>((m) => double.parse(m.subtotal))
          .reduce((a, b) => a + b);
    }

    subtotal = cartSubtotal;

    ShippingType shippingType = CheckoutSession.getInstance.shippingType;

    if (shippingType != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          FlatRate flatRate = (shippingType.object as FlatRate);
          if (flatRate.taxable) {
            shippingTotal += double.parse(shippingType.cost);
          }
          break;
        case "local_pickup":
          LocalPickup localPickup = (shippingType.object as LocalPickup);
          if (localPickup.taxable) {
            shippingTotal += double.parse(localPickup.cost);
          }
          break;
        default:
          break;
      }
    }

    double total = 0;
    if (subtotal != 0) {
      total += ((double.parse(taxRate.rate) * subtotal) / 100);
    }
    if (shippingTotal != 0) {
      total += ((double.parse(taxRate.rate) * shippingTotal) / 100);
    }
    return (total).toString();
  }
}

openBrowserTab({String url}) async {
  await FlutterWebBrowser.openWebPage(
      url: url, androidToolbarColor: Colors.white70);
}

EdgeInsets safeAreaDefault() {
  return EdgeInsets.only(left: 16, right: 16, bottom: 8);
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  SlideRightRoute({this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        });
}

String trans(BuildContext context, String key) {
  return AppLocalizations.of(context).trans(key);
}
