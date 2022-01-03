//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';

class PaymentType {
  int id;
  String name;
  String desc;
  String assetImage;
  Function pay;

  PaymentType(
      {@required this.id,
      @required this.name,
      @required this.desc,
      @required this.assetImage,
      @required this.pay});
}
