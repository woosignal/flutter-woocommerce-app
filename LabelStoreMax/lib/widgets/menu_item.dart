//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';

Widget wsMenuItem(BuildContext context,
    {String title, Widget leading, void Function() action}) {
  return Flexible(
    child: InkWell(
      child: Card(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 15, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              leading,
              Text(" " + title,
                  style: Theme.of(context).primaryTextTheme.bodyText2),
            ],
          ),
        ),
        elevation: 1,
        margin: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      ),
      onTap: action,
    ),
  );
}
