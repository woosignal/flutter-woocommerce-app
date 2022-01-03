//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/helper.dart';

class NoResultsForProductsWidget extends StatelessWidget {
  const NoResultsForProductsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Text(
            trans("No results"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      );
}
