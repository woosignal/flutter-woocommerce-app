//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/product_quantity_widget.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class ProductDetailFooterActionsWidget extends StatelessWidget {
  const ProductDetailFooterActionsWidget(
      {super.key,
      required this.product,
      required this.quantity,
      required this.onAddToCart,
      required this.onViewExternalProduct,
      required this.onAddQuantity,
      required this.onRemoveQuantity});
  final Product? product;
  final Function onViewExternalProduct;
  final Function onAddToCart;
  final Function onAddQuantity;
  final Function onRemoveQuantity;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.color.general.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15.0,
            spreadRadius: -17,
            offset: Offset(
              0,
              -10,
            ),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (product?.type != "external")
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  trans("Quantity"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.grey),
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 28,
                      ),
                      onPressed: onRemoveQuantity as void Function()?,
                    ),
                    ProductQuantity(),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 28,
                      ),
                      onPressed: onAddQuantity as void Function()?,
                    ),
                  ],
                )
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  formatStringCurrency(
                      total:
                          (parseWcPrice(product?.price) * quantity).toString()),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              )),
              product?.type == "external"
                  ? Flexible(
                      child: Button.primary(
                        text: trans("Buy Product"),
                        onPressed: () => onViewExternalProduct()),
                    )
                  : Flexible(
                      child: Button.primary(
                        text: trans("Add to cart"),
                        onPressed: () => onAddToCart()),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
