//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:woosignal/models/response/products.dart';

class ProductDetailHeaderWidget extends StatelessWidget {
  const ProductDetailHeaderWidget({Key? key, required this.product})
      : super(key: key);

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              product!.name!,
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 20),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            flex: 4,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatStringCurrency(total: product!.price),
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.right,
                ),
                if (product!.onSale == true && product!.type != "variable")
                  Text(
                    formatStringCurrency(total: product!.regularPrice),
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  )
              ],
            ),
            flex: 2,
          )
        ],
      ),
    );
  }
}
