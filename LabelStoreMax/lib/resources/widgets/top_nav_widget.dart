//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TopNavWidget extends StatelessWidget {
  const TopNavWidget({Key? key, this.onPressBrowseCategories})
      : super(key: key);
  final Function()? onPressBrowseCategories;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "${(trans("Shop").capitalize())} / ",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              AutoSizeText(
                trans("Newest"),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
            ],
          ),
          Flexible(
            child: MaterialButton(
              minWidth: 100,
              height: 60,
              child: AutoSizeText(
                trans("Browse categories"),
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
              onPressed: onPressBrowseCategories,
            ),
          )
        ],
      );
}
