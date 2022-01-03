//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/app/models/customer_country.dart';

class CustomerAddress {
  String firstName;
  String lastName;
  String addressLine;
  String city;
  String postalCode;
  String emailAddress;
  CustomerCountry customerCountry;

  CustomerAddress(
      {this.firstName,
      this.lastName,
      this.addressLine,
      this.city,
      this.postalCode,
      this.emailAddress,
      this.customerCountry});

  void initAddress() {
    firstName = "";
    lastName = "";
    addressLine = "";
    city = "";
    postalCode = "";
    customerCountry = CustomerCountry();
    emailAddress = "";
  }

  bool hasMissingFields() =>
      (firstName.isEmpty ||
          lastName.isEmpty ||
          addressLine.isEmpty ||
          city.isEmpty ||
          postalCode.isEmpty) ||
      (customerCountry.hasState() == true
          ? (customerCountry?.state?.name ?? "").isEmpty
          : false);

  String addressFull() {
    List<String> tmpArrAddress = [];
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
      tmpArrAddress.add(customerCountry.name);
    }
    return tmpArrAddress.join(", ");
  }

  String nameFull() {
    List<String> tmpArrName = [];
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
    data['state'] = customerCountry.state;
    data['country'] = customerCountry.name;
    data['email_address'] = emailAddress;
    data['customer_country'] = null;
    if (customerCountry != null) {
      data['customer_country'] = customerCountry.toJson();
    }
    return data;
  }
}
