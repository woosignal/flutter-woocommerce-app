//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

class PaymentType {
  int id;
  String name;
  String desc;
  String assetImage;
  Function pay;

  PaymentType({this.id, this.name, this.desc, this.assetImage, this.pay});
}
