//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:nylo_framework/nylo_framework.dart';

class User extends Storable {
  String? userId;
  String? token;

  User();
  User.fromUserAuthResponse({this.userId, this.token});

  @override
  toStorage() => {"token": token, "user_id": userId};

  @override
  fromStorage(dynamic data) {
    token = data['token'];
    userId = data['user_id'];
  }
}
