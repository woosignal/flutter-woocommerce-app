//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2020 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/products.dart' as WS;
import 'package:label_storemax/widgets/woosignal_ui.dart';

class BrowseCategoryPage extends StatefulWidget {
  final ProductCategory productCategory;
  const BrowseCategoryPage({Key key, @required this.productCategory})
      : super(key: key);

  @override
  _BrowseCategoryPageState createState() =>
      _BrowseCategoryPageState(productCategory);
}

class _BrowseCategoryPageState extends State<BrowseCategoryPage> {
  _BrowseCategoryPageState(this._selectedCategory);

  List<WS.Product> _products = [];
  var _productsController = ScrollController();

  ProductCategory _selectedCategory;
  bool _isLoading;
  int _page;
  bool _shouldStopRequests;
  bool waitForNextRequest;

  @override
  void initState() {
    super.initState();

    _isLoading = true;

    _page = 1;
    _shouldStopRequests = false;
    waitForNextRequest = false;

    _fetchProductsForCategory();
    _addScrollListener();
  }

  _addScrollListener() async {
    _productsController.addListener(() {
      double maxScroll = _productsController.position.maxScrollExtent;
      double currentScroll = _productsController.position.pixels;
      double delta = 50.0;
      if (maxScroll - currentScroll <= delta) {
        if (_shouldStopRequests) {
          return;
        }
        if (waitForNextRequest) {
          return;
        }

        _fetchMoreProducts();
      }
    });
  }

  _fetchMoreProducts() async {
    waitForNextRequest = true;
    List<WS.Product> products = await appWooSignal((api) {
      return api.getProducts(perPage: 50, page: _page, status: "publish");
    });
    _products.addAll(products);
    waitForNextRequest = false;
    _page = _page + 1;

    waitForNextRequest = false;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
  }

  _fetchProductsForCategory() async {
    _products = await appWooSignal((api) {
      return api.getProducts(
          category: _selectedCategory.id.toString(), perPage: 50);
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans(context, "Browse"),
                style: Theme.of(context).primaryTextTheme.subtitle1),
            Text(_selectedCategory.name,
                style: Theme.of(context).primaryTextTheme.title)
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? Center(
                child: showAppLoader(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: (_products.length != null && _products.length > 0
                        ? GridView.count(
                            crossAxisCount: 2,
                            controller: _productsController,
                            children: List.generate(_products.length, (index) {
                              return wsCardProductItem(context,
                                  index: index, product: _products[index]);
                            }))
                        : wsNoResults(context)),
                    flex: 1,
                  ),
                ],
              ),
      ),
    );
  }
}
