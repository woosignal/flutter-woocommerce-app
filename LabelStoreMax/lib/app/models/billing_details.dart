//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/app/models/customer_address.dart';

class BillingDetails {
  CustomerAddress? billingAddress;
  CustomerAddress? shippingAddress;
  bool? rememberDetails;

  BillingDetails();

  void initSession() {
    billingAddress = CustomerAddress();
    shippingAddress = CustomerAddress();
  }

  Map<String, String?> getShippingAddressStripe() => {
        "name": shippingAddress?.nameFull(),
        "line1": shippingAddress!.addressLine,
        "city": shippingAddress!.city,
        "postal_code": shippingAddress!.postalCode,
        "country": (shippingAddress?.customerCountry?.name ?? "")
      };

  fromWpMeta(Map<String, String> data) async {
    final Map<String, String> shippingDetailsWpMeta = <String, String>{},
        billingDetailsWpMeta = <String, String>{};

    shippingDetailsWpMeta.addEntries(data.entries
        .where((element) => element.key.startsWith("shipping_"))
        .map((shippingMeta) => MapEntry(
            shippingMeta.key.replaceAll("shipping_", ""), shippingMeta.value)));
    billingDetailsWpMeta.addEntries(data.entries
        .where((element) => element.key.startsWith("billing_"))
        .map((billingMeta) => MapEntry(
            billingMeta.key.replaceAll("billing_", ""), billingMeta.value)));

    CustomerAddress billingCustomerAddress = CustomerAddress();
    await billingCustomerAddress.fromWpMetaData(billingDetailsWpMeta);

    CustomerAddress shippingCustomerAddress = CustomerAddress();
    await shippingCustomerAddress.fromWpMetaData(shippingDetailsWpMeta);

    billingAddress = billingCustomerAddress;
    shippingAddress = shippingCustomerAddress;
  }
}
