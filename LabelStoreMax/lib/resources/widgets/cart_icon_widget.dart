//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/cart_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/cart_quantity_widget.dart';

class CartIconWidget extends StatelessWidget {
  const CartIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: IconButton(
        icon: Stack(
          children: <Widget>[
            Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Icon(Icons.shopping_cart, size: 20),
              ),
            ),
            Positioned.fill(
              top: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: CartQuantity(),
              ),
            )
          ],
        ),
        onPressed: () => routeTo(CartPage.path),
      ),
    );
  }
}
