//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:label_storemax/models/customer_address.dart';

class BillingDetails {
  CustomerAddress billingAddress;
  CustomerAddress shippingAddress;
  bool rememberDetails;

  void initSession() {
    billingAddress = CustomerAddress();
    shippingAddress = CustomerAddress();
  }
}
