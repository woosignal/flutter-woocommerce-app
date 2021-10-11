//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.


import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';

class AppLoaderWidget extends StatelessWidget {
  const AppLoaderWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = (Theme.of(context).brightness == Brightness.dark);
    return SpinKitDoubleBounce(
      color: HexColor(!isDark ? "#424242" : "#c7c7c7")
    );
  }
}
