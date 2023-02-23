//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/future_build_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailRelatedProductsWidget extends StatelessWidget {
  const ProductDetailRelatedProductsWidget(
      {Key? key, required this.product, required this.wooSignalApp})
      : super(key: key);

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
                style:
                    Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: FutureBuildWidget<List<Product>>(
            asyncFuture: fetchRelated(),
            onValue: (relatedProducts) {
              if (relatedProducts == null) {
                return SizedBox.shrink();
              }
              return ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: relatedProducts
                    .map((e) => Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: ProductItemContainer(product: e)))
                    .toList(),
              );
            },
            onLoading: AppLoaderWidget(),
          ),
        ),
      ],
    );
  }

  Future<List<Product>> fetchRelated() async {
    return await (appWooSignal(
      (api) => api.getProducts(perPage: 100, include: product!.relatedIds),
    ));
  }
}
