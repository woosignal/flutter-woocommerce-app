//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/store_logo_widget.dart';

class CheckoutStoreHeadingWidget extends StatelessWidget {
  const CheckoutStoreHeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: StoreLogo(height: 65),
      ),
    );
  }
}
