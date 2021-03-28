//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/app/models/default_shipping.dart';

class CustomerCountry {
  String countryCode;
  String name;
  DefaultShippingState state;

  CustomerCountry({this.countryCode, this.name, this.state});

  CustomerCountry.fromDefaultShipping({DefaultShipping defaultShipping}) {
    countryCode = defaultShipping.code;
    name = defaultShipping.country;
    if ((defaultShipping.states?.length ?? 0) == 1) {
      state = defaultShipping.states.first;
    }
  }

  CustomerCountry.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    if (json['country_code'] != null) {
      countryCode = json['country_code'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['state'] != null) {
      state = DefaultShippingState.fromJson(json['state']);
    }
  }

  bool hasState() =>
      (this.state != null && this.state.name != null ? true : false);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_code'] = this.countryCode;
    data['name'] = this.name;
    data['state'] = null;
    if (this.state != null) {
      data['state'] = this.state.toJson();
    }
    return data;
  }
}
