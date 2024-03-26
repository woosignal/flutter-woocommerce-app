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
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/resources/pages/browse_category_page.dart';
import '/resources/pages/home_search_page.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/cached_image_widget.dart';
import '/resources/widgets/top_nav_widget.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import '/resources/widgets/notification_icon_widget.dart';
import 'package:woosignal/models/response/product_category_collection.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cart_icon_widget.dart';
import '/resources/widgets/home_drawer_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/product_category.dart' as ws_category;
import 'package:woosignal/models/response/product.dart' as ws_product;

class MelloThemeWidget extends StatefulWidget {
  MelloThemeWidget({super.key, required this.wooSignalApp});
  final WooSignalApp? wooSignalApp;

  @override
  createState() => _MelloThemeWidgetState();
}

class _MelloThemeWidgetState extends NyState<MelloThemeWidget> {
  List<ws_category.ProductCategory> _categories = [];

  @override
  boot() async {
    await _fetchCategories();
  }

  _fetchCategories() async {
    if ((widget.wooSignalApp?.productCategoryCollections ?? []).isNotEmpty) {
      List<int> productCategoryId = widget
              .wooSignalApp?.productCategoryCollections
              .map((e) => int.parse(e.collectionId!))
              .toList() ??
          [];
      _categories = await (appWooSignal((api) => api.getProductCategories(
          parent: 0,
          perPage: 50,
          hideEmpty: true,
          include: productCategoryId)));
      _categories.sort((category1, category2) {
        ProductCategoryCollection? productCategoryCollection1 =
            widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull(
                (element) => element.collectionId == category1.id.toString());
        ProductCategoryCollection? productCategoryCollection2 =
            widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull(
                (element) => element.collectionId == category2.id.toString());

        if (productCategoryCollection1 == null) return 0;
        if (productCategoryCollection2 == null) return 0;

        if (productCategoryCollection1.position == null) return 0;
        if (productCategoryCollection2.position == null) return 0;

        return productCategoryCollection1.position!
            .compareTo(productCategoryCollection2.position!);
      });
    } else {
      _categories = await (appWooSignal((api) =>
          api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true)));
      _categories.sort((category1, category2) =>
          category1.menuOrder!.compareTo(category2.menuOrder!));
    }
  }

  _modalBottomSheetMenu() {
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
            routeTo(BrowseCategoryPage.path, data: _categories[index]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? bannerImages = widget.wooSignalApp!.bannerImages;
    return Scaffold(
      drawer: HomeDrawerWidget(
        wooSignalApp: widget.wooSignalApp,
        productCategories: _categories,
      ),
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
        actions: [
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              size: 35,
            ),
            onPressed: () {
              routeTo(HomeSearchPage.path);
            },
          ),
          Flexible(child: NotificationIcon()),
          CartIconWidget(),
        ],
      ),
      body: SafeAreaWidget(
        child: NyPullToRefresh.grid(
          header: Column(
            children: [
              if (bannerImages!.isNotEmpty)
                Container(
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return CachedImageWidget(
                        image: bannerImages[index],
                        fit: BoxFit.contain,
                      );
                    },
                    itemCount: bannerImages.length,
                    viewportFraction: 0.8,
                    scale: 0.9,
                  ),
                  height: 300,
                ),
              TopNavWidget(onPressBrowseCategories: _modalBottomSheetMenu),
            ],
          ),
          child: (context, product) {
            product as ws_product.Product;
            return Container(
              height: 300,
              child: ProductItemContainer(
                product: product,
                onTap: () => _showProduct(product),
              ),
            );
          },
          data: (page) async {
            return await appWooSignal((api) => api.getProducts(
                  perPage: 50,
                  page: page,
                  status: "publish",
                  stockStatus: "instock",
                ));
          },
        ),
      ),
    );
  }

  _showProduct(ws_product.Product product) {
    routeTo(ProductDetailPage.path, data: product);
  }
}
