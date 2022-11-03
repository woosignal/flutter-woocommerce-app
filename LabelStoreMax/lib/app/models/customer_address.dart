//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/default_shipping.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:wp_json_api/models/wp_meta_meta.dart';

class CustomerAddress {
  String? firstName;
  String? lastName;
  String? addressLine;
  String? city;
  String? postalCode;
  String? emailAddress;
  String? phoneNumber;
  CustomerCountry? customerCountry;

  CustomerAddress(
      {this.firstName,
      this.lastName,
      this.addressLine,
      this.city,
      this.postalCode,
      this.emailAddress,
      this.phoneNumber,
      this.customerCountry});

  void initAddress() {
    firstName = "";
    lastName = "";
    addressLine = "";
    city = "";
    postalCode = "";
    customerCountry = CustomerCountry();
    emailAddress = "";
    phoneNumber = "";
  }

  bool hasMissingFields() =>
      (firstName!.isEmpty ||
          lastName!.isEmpty ||
          addressLine!.isEmpty ||
          city!.isEmpty ||
          postalCode!.isEmpty) ||
      (customerCountry!.hasState() == true
          ? (customerCountry?.state?.name ?? "").isEmpty
          : false);

  String addressFull() {
    List<String?> tmpArrAddress = [];
    if (addressLine != null && addressLine != "") {
      tmpArrAddress.add(addressLine);
    }
    if (city != null && city != "") {
      tmpArrAddress.add(city);
    }
    if (postalCode != null && postalCode != "") {
      tmpArrAddress.add(postalCode);
    }
    if (customerCountry != null && customerCountry?.state?.name != null) {
      tmpArrAddress.add(customerCountry?.state?.name);
    }
    if (customerCountry != null && customerCountry?.name != null) {
      tmpArrAddress.add(customerCountry!.name);
    }
    return tmpArrAddress.join(", ");
  }

  String nameFull() {
    List<String?> tmpArrName = [];
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
    if (json['phone_number'] != null) {
      phoneNumber = json['phone_number'];
    }
    customerCountry = CustomerCountry.fromJson(json['customer_country']);
    emailAddress = json['email_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address_line'] = addressLine;
    data['city'] = city;
    data['postal_code'] = postalCode;
    data['state'] = customerCountry!.state;
    data['country'] = customerCountry!.name;
    if (phoneNumber != null && phoneNumber != "") {
      data['phone_number'] = phoneNumber;
    }
    data['email_address'] = emailAddress;
    data['customer_country'] = null;
    if (customerCountry != null) {
      data['customer_country'] = customerCountry!.toJson();
    }
    return data;
  }

  fromWpMetaData(Map<String, dynamic> data) async {
    if (data.containsKey('first_name')) {
      firstName = data['first_name'];
    }

    if (data.containsKey('last_name')) {
      lastName = data['last_name'];
    }

    if (data.containsKey('address_1')) {
      addressLine = data['address_1'];
    }

    if (data.containsKey('city')) {
      city = data['city'];
    }

    if (data.containsKey('postcode')) {
      postalCode = data['postcode'];
    }

    if (data.containsKey('email')) {
      emailAddress = data['email'];
    }

    if (data.containsKey('phone')) {
      phoneNumber = data['phone'];
    }

    if (data.containsKey('country')) {
      DefaultShipping? defaultShipping =
          await findCountryMetaForShipping(data['country']);
      if (defaultShipping == null) {
        return;
      }
      customerCountry = CustomerCountry.fromWpMeta(data, defaultShipping);
    }
  }

  List<UserMetaDataItem> toUserMetaDataItem(String type) {
    return [
      UserMetaDataItem(key: "${type}_first_name", value: firstName),
      UserMetaDataItem(key: "${type}_last_name", value: lastName),
      UserMetaDataItem(key: "${type}_address_1", value: addressLine),
      UserMetaDataItem(key: "${type}_city", value: city),
      UserMetaDataItem(key: "${type}_postcode", value: postalCode),
      UserMetaDataItem(key: "${type}_phone", value: phoneNumber),
      if (type != "shipping")
        UserMetaDataItem(key: "${type}_email", value: emailAddress),
      UserMetaDataItem(
          key: "${type}_country", value: customerCountry?.countryCode),
      UserMetaDataItem(
          key: "${type}_state",
          value: customerCountry?.state?.code
              ?.replaceAll("${customerCountry?.countryCode}:", "")),
    ];
  }
}
