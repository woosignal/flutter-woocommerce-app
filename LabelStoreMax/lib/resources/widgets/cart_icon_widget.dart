//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartIconWidget extends StatefulWidget {
  CartIconWidget({Key? key}) : super(key: key);

  @override
  _CartIconWidgetState createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: IconButton(
        icon: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Align(
                child: Icon(Icons.shopping_cart, size: 20),
                alignment: Alignment.bottomCenter,
              ),
              bottom: 0,
            ),
            Positioned.fill(
              child: Align(
                child: NyFutureBuilder<List<CartLineItem>>(
                  future: Cart.getInstance.getCart(),
                  child: (BuildContext context,
                      data) {
                    List<int?> cartItems =
                    data.map((e) => e.quantity).toList();
                    String cartValue = "0";
                    if (cartItems.isNotEmpty) {
                      cartValue = cartItems
                          .reduce((value, element) => value! + element!)
                          .toString();
                    }
                    return Text(
                      cartValue,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                alignment: Alignment.topCenter,
              ),
              top: 0,
            )
          ],
        ),
        onPressed: () => Navigator.pushNamed(context, "/cart")
            .then((value) => setState(() {})),
      ),
    );
  }
}
