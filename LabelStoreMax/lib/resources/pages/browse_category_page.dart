//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/resources/pages/product_detail_page.dart';
import '/bootstrap/enums/sort_enums.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;

class BrowseCategoryPage extends NyStatefulWidget {
  static String path = "/browse-category";

  BrowseCategoryPage({Key? key})
      : super(path, key: key, child: _BrowseCategoryPageState());
}

class _BrowseCategoryPageState extends NyState<BrowseCategoryPage> {
  ProductCategory? productCategory;
  _BrowseCategoryPageState();

  SortByType? _sortByType;

  @override
  init() async {
    productCategory = widget.controller.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans("Browse"),
                style: Theme.of(context).textTheme.titleMedium),
            afterNotNull(productCategory,
                child: () => Text(parseHtmlString(productCategory!.name)),
                loading: CupertinoActivityIndicator())
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: _modalSheetTune,
          )
        ],
      ),
      body: SafeAreaWidget(
          child: NyPullToRefresh.grid(
        data: (page) async {
          List<ws_product.Product> products =
              await appWooSignal((api) => api.getProducts(
                    perPage: 25,
                    category: productCategory?.id.toString(),
                    page: page,
                    status: "publish",
                    stockStatus: "instock",
                  ));
          return products;
        },
        child: (context, product) {
          return Container(
            height: 300,
            child: ProductItemContainer(
              product: product,
              onTap: () => _showProduct(product),
            ),
          );
        },
        stateName: 'browse_category_pull_to_refresh',
        sort: (products) {
          return _sortProducts(products,
              by: _sortByType ?? SortByType.dateDesc);
        },
      )),
    );
  }

  _sortProducts(List<ws_product.Product> products, {required SortByType by}) {
    switch (by) {
      case SortByType.lowToHigh:
        products.sort(
          (product1, product2) => (parseWcPrice(product1.price))
              .compareTo((parseWcPrice(product2.price))),
        );
        break;
      case SortByType.highToLow:
        products.sort(
          (product1, product2) => (parseWcPrice(product2.price))
              .compareTo((parseWcPrice(product1.price))),
        );
        break;
      case SortByType.nameAZ:
        products.sort(
          (product1, product2) => product1.name!.compareTo(product2.name!),
        );
        break;
      case SortByType.nameZA:
        products.sort(
          (product1, product2) => product2.name!.compareTo(product1.name!),
        );
        break;
      case SortByType.dateAsc:
        products.sort((product1, product2) {
          DateTime? date1 = product1.dateCreated.toDateTime();
          DateTime? date2 = product2.dateCreated.toDateTime();
          return date1.compareTo(date2);
        });
      case SortByType.dateDesc:
        products.sort((product1, product2) {
          DateTime? date1 = product1.dateCreated.toDateTime();
          DateTime? date2 = product2.dateCreated.toDateTime();
          return date2.compareTo(date1);
        });
        break;
    }
    return products;
  }

  _modalSheetTune() {
    wsModalBottom(
      context,
      title: trans("Sort results"),
      bodyWidget: ListView(
        children: [
          LinkButton(
            title: trans("Sort: Low to high"),
            selected: _sortByType == SortByType.lowToHigh,
            action: () {
              _sortByType = SortByType.lowToHigh;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: High to low"),
            selected: _sortByType == SortByType.highToLow,
            action: () {
              _sortByType = SortByType.highToLow;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Name A-Z"),
            selected: _sortByType == SortByType.nameAZ,
            action: () {
              _sortByType = SortByType.nameAZ;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Name Z-A"),
            selected: _sortByType == SortByType.nameZA,
            action: () {
              _sortByType = SortByType.nameZA;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Date New to Old"),
            selected: _sortByType == SortByType.dateDesc,
            action: () {
              _sortByType = SortByType.dateDesc;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Date Old to New"),
            selected: _sortByType == SortByType.dateAsc,
            action: () {
              _sortByType = SortByType.dateAsc;
              StateAction.refreshPage('browse_category_pull_to_refresh',
                  setState: () {});
              pop();
            },
          ),
          Divider(
            height: 0,
          ),
          LinkButton(title: trans("Cancel"), action: pop)
        ],
      ),
    );
  }

  _showProduct(ws_product.Product product) {
    routeTo(ProductDetailPage.path, data: product);
  }
}
