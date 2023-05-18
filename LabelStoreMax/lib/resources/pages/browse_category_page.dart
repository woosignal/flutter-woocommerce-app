//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_category_search_loader_controller.dart';
import 'package:flutter_app/app/controllers/browse_category_controller.dart';
import 'package:flutter_app/bootstrap/enums/sort_enums.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/products.dart' as ws_product;

class BrowseCategoryPage extends NyStatefulWidget {
  final BrowseCategoryController controller = BrowseCategoryController();
  BrowseCategoryPage({Key? key}) : super(key: key);

  @override
  _BrowseCategoryPageState createState() => _BrowseCategoryPageState();
}

class _BrowseCategoryPageState extends NyState<BrowseCategoryPage> {
  ProductCategory? productCategory;
  _BrowseCategoryPageState();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ProductCategorySearchLoaderController
      _productCategorySearchLoaderController =
      ProductCategorySearchLoaderController();

  bool _shouldStopRequests = false;
  bool _isLoading = true;

  @override
  init() async {
    productCategory = widget.controller.data();
    await fetchProducts();
  }

  @override
  void dispose() {
    super.dispose();
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
            Text(parseHtmlString(productCategory!.name))
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
        child: _isLoading
            ? Center(
                child: AppLoaderWidget(),
              )
            : refreshableScroll(context,
                refreshController: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                products: _productCategorySearchLoaderController.getResults(),
                onTap: _showProduct,
        ),
      ),
    );
  }

  void _onRefresh() async {
    _productCategorySearchLoaderController.clear();
    await fetchProducts();

    setState(() {
      _shouldStopRequests = false;
      _refreshController.refreshCompleted(resetFooterState: true);
    });
  }

  void _onLoading() async {
    await fetchProducts();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _sortProducts({required SortByType by}) {
    List<ws_product.Product> products =
        _productCategorySearchLoaderController.getResults();
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
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  _modalSheetTune() {
    wsModalBottom(
      context,
      title: trans("Sort results"),
      bodyWidget: ListView(
        children: <Widget>[
          LinkButton(
            title: trans("Sort: Low to high"),
            action: () => _sortProducts(by: SortByType.lowToHigh),
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: High to low"),
            action: () => _sortProducts(by: SortByType.highToLow),
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Name A-Z"),
            action: () => _sortProducts(by: SortByType.nameAZ),
          ),
          Divider(
            height: 0,
          ),
          LinkButton(
            title: trans("Sort: Name Z-A"),
            action: () => _sortProducts(by: SortByType.nameZA),
          ),
          Divider(
            height: 0,
          ),
          LinkButton(title: trans("Cancel"), action: _dismissModal)
        ],
      ),
    );
  }

  Future fetchProducts() async {
    await _productCategorySearchLoaderController.loadProducts(
      hasResults: (result) {
        if (result == false) {
          setState(() {
            _isLoading = false;
            _shouldStopRequests = true;
          });
          return false;
        }
        return true;
      },
      didFinish: () => setState(() {
        _isLoading = false;
      }),
      productCategory: productCategory,
    );
  }

  _dismissModal() => Navigator.pop(context);

  _showProduct(ws_product.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
