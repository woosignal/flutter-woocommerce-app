//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:package_info/package_info.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text("");
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text("");
          case ConnectionState.done:
            if (snapshot.hasError) return Text("");
            return Padding(
              child: Text(
                  "${trans(context, "Version")}: ${snapshot.data.version}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.w300)),
              padding: EdgeInsets.only(top: 15, bottom: 15),
            );
        }
        return null; // unreachable
      },
    );
  }
}
