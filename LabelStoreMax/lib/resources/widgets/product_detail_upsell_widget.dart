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
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailUpsellWidget extends StatefulWidget {
  ProductDetailUpsellWidget(
      {required this.productIds, required this.wooSignalApp});
  final List<int>? productIds;
  final WooSignalApp? wooSignalApp;

  @override
  createState() => _ProductDetailUpsellWidgetState();
}

class _ProductDetailUpsellWidgetState
    extends NyState<ProductDetailUpsellWidget> {
  @override
  boot() async {}

  @override
  Widget build(BuildContext context) {
    if (widget.productIds!.isEmpty ||
        widget.wooSignalApp!.showUpsellProducts == false) {
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
                trans("${trans('You may also like')}…"),
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
            child: NyListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                child: (context, product) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    child: ProductItemContainer(product: product, onTap: () {
                      routeTo(ProductDetailPage.path, data: product);
                    },),
                  );
                },
                data: () {
                  return appWooSignal(
                      (api) => api.getProducts(include: widget.productIds));
                })),
      ],
    );
  }
}
