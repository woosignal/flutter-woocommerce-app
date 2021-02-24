//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:label_storemax/helpers/shared_pref.dart';

const keyUserId = "DEFAULT_SP_USERID";

storeUserId(String v) async {
  SharedPref sharedPref = SharedPref();
  await sharedPref.save(keyUserId, v);
}

Future<String> readUserId() async {
  SharedPref sharedPref = SharedPref();
  String val = await sharedPref.read(keyUserId);
  return val;
}

destroyUserId(BuildContext context) async {
  SharedPref sharedPref = SharedPref();
  await sharedPref.save(keyUserId, null);
}
