//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
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
      (this.firstName.isEmpty ||
          this.lastName.isEmpty ||
          this.addressLine.isEmpty ||
          this.city.isEmpty ||
          this.postalCode.isEmpty) ||
      (this.customerCountry.hasState() == true
          ? (this.customerCountry?.state?.name ?? "").isEmpty
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
    if (this.customerCountry != null &&
        this.customerCountry?.state?.name != null) {
      tmpArrAddress.add(this.customerCountry?.state?.name);
    }
    if (this.customerCountry != null && this.customerCountry?.name != null) {
      tmpArrAddress.add(this.customerCountry.name);
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
    this.customerCountry = CustomerCountry.fromJson(json['customer_country']);
    emailAddress = json['email_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address_line'] = this.addressLine;
    data['city'] = this.city;
    data['postal_code'] = this.postalCode;
    data['state'] = this.customerCountry.state;
    data['country'] = this.customerCountry.name;
    data['email_address'] = this.emailAddress;
    data['customer_country'] = null;
    if (this.customerCountry != null) {
      data['customer_country'] = this.customerCountry.toJson();
    }
    return data;
  }
}
