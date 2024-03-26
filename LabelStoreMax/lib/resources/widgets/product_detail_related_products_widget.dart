//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailRelatedProductsWidget extends StatelessWidget {
  const ProductDetailRelatedProductsWidget(
      {super.key, required this.product, required this.wooSignalApp});

  final Product? product;
  final WooSignalApp? wooSignalApp;

  @override
  Widget build(BuildContext context) {
    if (wooSignalApp!.showRelatedProducts == false) {
      return SizedBox.shrink();
    }
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                trans("Related products"),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Container(
          height: 300,
          child: NyFutureBuilder<List<Product>>(
            future: fetchRelated(),
            child: (context, relatedProducts) {
              if (relatedProducts == null) return SizedBox.shrink();

              if (relatedProducts.isEmpty) {
                return SizedBox.shrink();
              }
              return ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: relatedProducts
                    .map((product) => Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: ProductItemContainer(
                          product: product,
                          onTap: () {
                            routeTo(ProductDetailPage.path, data: product);
                          },
                        )))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Product>> fetchRelated() async => await (appWooSignal(
        (api) => api.getProducts(
            perPage: 100,
            include: product?.relatedIds,
            stockStatus: "instock",
            status: "publish"),
      ));
}
