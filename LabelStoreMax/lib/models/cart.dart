//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:label_storemax/helpers/app_helper.dart';
import 'package:label_storemax/helpers/shared_pref.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/shipping_type.dart';
import 'package:woosignal/models/response/shipping_method.dart';
import 'package:woosignal/models/response/tax_rate.dart';

import '../helpers/tools.dart';

class Cart {
  String _keyCart = "CART_SESSION";

  Cart._privateConstructor();
  static final Cart getInstance = Cart._privateConstructor();

  Future<List<CartLineItem>> getCart() async {
    List<CartLineItem> cartLineItems = [];
    SharedPref sharedPref = SharedPref();
    String currentCartArrJSON = (await sharedPref.read(_keyCart) as String);
    if (currentCartArrJSON == null) {
      cartLineItems = [];
    } else {
      cartLineItems = (jsonDecode(currentCartArrJSON) as List<dynamic>)
          .map((i) => CartLineItem.fromJson(i))
          .toList();
    }
    return cartLineItems;
  }

  void addToCart({@required CartLineItem cartLineItem}) async {
    List<CartLineItem> cartLineItems = await getCart();

    if (cartLineItem.variationId != null) {
      if (cartLineItems.firstWhere(
              (i) => (i.productId == cartLineItem.productId &&
                  i.variationId == cartLineItem.variationId),
              orElse: () => null) !=
          null) {
        return;
      }
    } else {
      CartLineItem firstCartItem = cartLineItems.firstWhere(
          (i) => i.productId == cartLineItem.productId,
          orElse: () => null);
      if (firstCartItem != null) {
        return;
      }
    }
    cartLineItems.add(cartLineItem);

    saveCartToPref(cartLineItems: cartLineItems);
  }

  Future<String> getTotal({bool withFormat = false}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double total = 0;
    cartLineItems.forEach((cartItem) {
      total += (parseWcPrice(cartItem.total) * cartItem.quantity);
    });

    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }

  Future<String> getSubtotal({bool withFormat = false}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double subtotal = 0;
    cartLineItems.forEach((cartItem) {
      subtotal += (parseWcPrice(cartItem.subtotal) * cartItem.quantity);
    });
    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: subtotal);
    }
    return subtotal.toStringAsFixed(2);
  }

  void updateQuantity(
      {@required CartLineItem cartLineItem,
      @required int incrementQuantity}) async {
    List<CartLineItem> cartLineItems = await getCart();
    List<CartLineItem> tmpCartItem = [];
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
    return cartLineItems
        .map((cartItem) =>
            "${cartItem.quantity.toString()} x | ${cartItem.name}")
        .toList()
        .join(",");
  }

  void removeCartItemForIndex({@required int index}) async {
    List<CartLineItem> cartLineItems = await getCart();
    cartLineItems.removeAt(index);
    saveCartToPref(cartLineItems: cartLineItems);
  }

  void clear() {
    SharedPref sharedPref = SharedPref();
    List<CartLineItem> cartLineItems = [];
    String jsonArrCartItems =
        jsonEncode(cartLineItems.map((i) => i.toJson()).toList());
    sharedPref.save(_keyCart, jsonArrCartItems);
  }

  void saveCartToPref({@required List<CartLineItem> cartLineItems}) {
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

    if (AppHelper.instance.appConfig.productPricesIncludeTax == 1 &&
        taxableCartLines.length > 0) {
      cartSubtotal = taxableCartLines
          .map<double>((m) => parseWcPrice(m.subtotal) * m.quantity)
          .reduce((a, b) => a + b);
    }

    subtotal = cartSubtotal;

    ShippingType shippingType = CheckoutSession.getInstance.shippingType;

    if (shippingType != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          FlatRate flatRate = (shippingType.object as FlatRate);
          if (flatRate.taxable != null && flatRate.taxable) {
            shippingTotal += parseWcPrice(
                shippingType.cost == null || shippingType.cost == ""
                    ? "0"
                    : shippingType.cost);
          }
          break;
        case "local_pickup":
          LocalPickup localPickup = (shippingType.object as LocalPickup);
          if (localPickup.taxable != null && localPickup.taxable) {
            shippingTotal += parseWcPrice(
                (localPickup.cost == null || localPickup.cost == ""
                    ? "0"
                    : localPickup.cost));
          }
          break;
        default:
          break;
      }
    }

    double total = 0;
    if (subtotal != 0) {
      total += ((parseWcPrice(taxRate.rate) * subtotal) / 100);
    }
    if (shippingTotal != 0) {
      total += ((parseWcPrice(taxRate.rate) * shippingTotal) / 100);
    }
    return (total).toStringAsFixed(2);
  }
}
