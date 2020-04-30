//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:label_storemax/helpers/shared_pref.dart';
import 'package:label_storemax/models/billing_details.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/models/payment_type.dart';
import 'package:label_storemax/models/shipping_type.dart';
import 'package:woosignal/models/response/tax_rate.dart';

import '../helpers/tools.dart';

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
