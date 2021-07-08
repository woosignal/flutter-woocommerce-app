//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';
import 'package:flutter_app/app/models/billing_details.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/models/shipping_type.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/shared_key.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:woosignal/models/response/tax_rate.dart';

class CheckoutSession {
  bool shipToDifferentAddress = false;

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

  void clear() {
    billingDetails = null;
    shippingType = null;
    paymentType = null;
  }

  void saveBillingAddress() async {
    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails.billingAddress;

    if (customerAddress == null) {
      return;
    }

    String billingAddress = jsonEncode(customerAddress.toJson());
    await NyStorage.store(SharedKey.customerBillingDetails, billingAddress);
  }

  Future<CustomerAddress> getBillingAddress() async {
    String strCheckoutDetails =
        await NyStorage.read(SharedKey.customerBillingDetails);

    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  void clearBillingAddress() async =>
      await NyStorage.delete(SharedKey.customerBillingDetails);

  saveShippingAddress() async {
    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails.shippingAddress;
    if (customerAddress == null) {
      return;
    }
    String shippingAddress = jsonEncode(customerAddress.toJson());
    await NyStorage.store(SharedKey.customerShippingDetails, shippingAddress);
  }

  Future<CustomerAddress> getShippingAddress() async {
    String strCheckoutDetails =
        await NyStorage.read(SharedKey.customerShippingDetails);
    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  void clearShippingAddress() async =>
      NyStorage.delete(SharedKey.customerShippingDetails);

  Future<String> total({bool withFormat = false, TaxRate taxRate}) async {
    double totalCart = parseWcPrice(await Cart.getInstance.getTotal());
    double totalShipping = 0;
    if (shippingType != null && shippingType.object != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        case "free_shipping":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        case "local_pickup":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        default:
          break;
      }
    }

    double total = totalCart + totalShipping;

    if (taxRate != null) {
      String taxAmount = await Cart.getInstance.taxAmount(taxRate);
      total += parseWcPrice(taxAmount);
    }

    if (withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }
}
