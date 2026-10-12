//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProductQuantity extends StatefulWidget {
  const ProductQuantity({super.key});

  static String state = "product_quantity";

  @override
  createState() => _ProductQuantityState();
}

class _ProductQuantityState extends NyState<ProductQuantity> {
  int quantity = 1;

  _ProductQuantityState() {
    stateName = ProductQuantity.state;
  }

  @override
  Map<String, Function> get stateActions => {
        "set_quantity": (quantity) {
          this.quantity = quantity;
        },
      };

  @override
  Widget view(BuildContext context) {
    return Text(
      quantity.toString(),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
