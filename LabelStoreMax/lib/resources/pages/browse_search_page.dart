//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;

class BrowseSearchPage extends NyStatefulWidget {
  static RouteView path = ("/product-search", (_) => BrowseSearchPage());

  BrowseSearchPage({super.key}) : super(child: () => _BrowseSearchState());
}

class _BrowseSearchState extends NyPage<BrowseSearchPage> {
  String? _search;

  @override
  get init => () {
        _search = widget.controller.data();
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans("Search results for"),
                style: Theme.of(context).textTheme.titleMedium),
            afterNotNull(_search,
                child: () => Text("\"${_search!}\""),
                loading: CupertinoActivityIndicator())
          ],
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
          child: CollectionView<ws_product.Product>.pullableGrid(
              builder: (context, item) {
        ws_product.Product product = item.data;
        return SizedBox(
          height: 300,
          child: ProductItemContainer(
            product: product,
            onTap: () {
              routeTo(ProductDetailPage.path, data: product);
            },
          ),
        );
      }, data: (page) {
        return appWooSignal((api) => api.getProducts(
              perPage: 100,
              search: _search,
              page: page,
              status: "publish",
              stockStatus: "instock",
            ));
      })),
    );
  }
}
