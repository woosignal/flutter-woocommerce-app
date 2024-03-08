//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:woosignal/models/response/product_category_collection.dart';
import '/app/controllers/product_loader_controller.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cart_icon_widget.dart';
import '/resources/widgets/home_drawer_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/product_category.dart' as ws_category;
import 'package:woosignal/models/response/product.dart' as ws_product;

class MelloThemeWidget extends StatefulWidget {
  MelloThemeWidget(
      {super.key, required this.globalKey, required this.wooSignalApp});
  final GlobalKey globalKey;
  final WooSignalApp? wooSignalApp;

  @override
  createState() => _MelloThemeWidgetState();
}

class _MelloThemeWidgetState extends NyState<MelloThemeWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ProductLoaderController _productLoaderController =
      ProductLoaderController();

  List<ws_category.ProductCategory> _categories = [];

  bool _shouldStopRequests = false;

  @override
  void init() async {
    super.init();
  }

  @override
  boot() async {
    await _home();
  }

  _home() async {
    await fetchProducts();
    await _fetchCategories();
  }

  _fetchCategories() async {
    if ((widget.wooSignalApp?.productCategoryCollections ?? []).isNotEmpty) {
      List<int> productCategoryId = widget.wooSignalApp?.productCategoryCollections.map((e) => int.parse(e.collectionId!)).toList() ?? [];
      _categories = await (appWooSignal((api) =>
          api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true, include: productCategoryId)));
      _categories.sort((category1, category2) {
        ProductCategoryCollection? productCategoryCollection1 = widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull((element) => element.collectionId == category1.id.toString());
        ProductCategoryCollection? productCategoryCollection2 = widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull((element) => element.collectionId == category2.id.toString());

        if (productCategoryCollection1 == null) return 0;
        if (productCategoryCollection2 == null) return 0;

        if (productCategoryCollection1.position == null) return 0;
        if (productCategoryCollection2.position == null) return 0;

        return productCategoryCollection1.position!.compareTo(productCategoryCollection2.position!);
      });
    } else {
      _categories = await (appWooSignal((api) =>
          api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true)));
      _categories.sort((category1, category2) =>
          category1.menuOrder!.compareTo(category2.menuOrder!));
    }
  }

  _modalBottomSheetMenu() {
    widget.globalKey.currentState!.setState(() {});
    wsModalBottom(
      context,
      title: trans("Categories"),
      bodyWidget: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (cxt, i) => Divider(),
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(parseHtmlString(_categories[index].name)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/browse-category",
                    arguments: _categories[index])
                .then((value) => setState(() {}));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? bannerImages = widget.wooSignalApp!.bannerImages;
    return Scaffold(
      drawer: HomeDrawerWidget(wooSignalApp: widget.wooSignalApp, productCategories: _categories,),
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              size: 35,
            ),
            onPressed: () => Navigator.pushNamed(context, "/home-search").then(
                (value) => widget.globalKey.currentState!.setState(() {})),
          ),
          CartIconWidget(key: widget.globalKey),
        ],
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: afterLoad(child: () => RefreshableScrollContainer(
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                products: _productLoaderController.getResults(),
                onTap: _showProduct,
                bannerHeight: MediaQuery.of(context).size.height / 3.5,
                bannerImages: bannerImages,
                modalBottomSheetMenu: _modalBottomSheetMenu,
              )),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  _onRefresh() async {
    _productLoaderController.clear();
    await fetchProducts();

    setState(() {
      _shouldStopRequests = false;
      _refreshController.refreshCompleted(resetFooterState: true);
    });
  }

  _onLoading() async {
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

  Future fetchProducts() async {
    await _productLoaderController.loadProducts(
        hasResults: (result) {
          if (result == false) {
            setState(() {
              _shouldStopRequests = true;
            });
            return false;
          }
          return true;
        },
        didFinish: () => setState(() {}));
  }

  _showProduct(ws_product.Product product) =>
      Navigator.pushNamed(context, "/product-detail", arguments: product)
          .then((value) => widget.globalKey.currentState!.setState(() {}));
}
