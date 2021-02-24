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
import 'package:label_storemax/helpers/shared_pref/sp_user_id.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/cart.dart';

const keyAuthCheck = "DEFAULT_SP_AUTHCHECK";

Future<bool> authCheck() async {
  SharedPref sharedPref = SharedPref();
  String val = await sharedPref.read(keyAuthCheck);
  return val != null ? true : false;
}

authUser(String v) async {
  SharedPref sharedPref = SharedPref();
  await sharedPref.save(keyAuthCheck, v);
}

Future<String> readAuthToken() async {
  SharedPref sharedPref = SharedPref();
  dynamic val = await sharedPref.read(keyAuthCheck);
  return val.toString();
}

authLogout(BuildContext context) async {
  SharedPref sharedPref = SharedPref();
  await sharedPref.save(keyAuthCheck, null);
  destroyUserId(context);
  Cart.getInstance.clear();
  navigatorPush(context, routeName: "/home", forgetAll: true);
}
