//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

class CustomerAddress {
  String firstName;
  String lastName;
  String addressLine;
  String city;
  String postalCode;
  String state;
  String country;
  String emailAddress;

  CustomerAddress(
      {this.firstName,
      this.lastName,
      this.addressLine,
      this.city,
      this.postalCode,
      this.state,
      this.country,
      this.emailAddress});

  void initAddress() {
    firstName = "";
    lastName = "";
    addressLine = "";
    city = "";
    postalCode = "";
    state = "";
    country = "";
    emailAddress = "";
  }

  bool hasMissingFields() =>
      (this.firstName.isEmpty ||
          this.lastName.isEmpty ||
          this.addressLine.isEmpty ||
          this.city.isEmpty ||
          this.postalCode.isEmpty) ||
      (this.country == "United States" ? this.state.isEmpty : false);

  String addressFull() {
    List<String> tmpArrAddress = new List<String>();
    if (addressLine != null && addressLine != "") {
      tmpArrAddress.add(addressLine);
    }
    if (city != null && city != "") {
      tmpArrAddress.add(city);
    }
    if (postalCode != null && postalCode != "") {
      tmpArrAddress.add(postalCode);
    }
    if (state != null && state != "") {
      tmpArrAddress.add(state);
    }
    if (country != null && country != "") {
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
    state = json['state'];
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
    data['state'] = this.state;
    data['country'] = this.country;
    data['email_address'] = this.emailAddress;
    return data;
  }
}
