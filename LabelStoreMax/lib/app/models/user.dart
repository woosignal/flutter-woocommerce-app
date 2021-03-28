//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:nylo_framework/helpers/helper.dart';

class User extends Storable {
  String userId;
  String token;

  User();
  User.fromUserAuthResponse({this.userId, this.token});

  @override
  toStorage() => {"token": this.token, "user_id": this.userId};

  @override
  fromStorage(dynamic data) {
    this.token = data['token'];
    this.userId = data['user_id'];
  }
}
