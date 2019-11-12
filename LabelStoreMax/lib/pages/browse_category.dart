//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2019 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/products.dart' as WS;
import 'package:woosignal/woosignal.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';

class BrowseCategoryPage extends StatefulWidget {
  BrowseCategoryPage();

  @override
  _BrowseCategoryPageState createState() => _BrowseCategoryPageState();
}

class _BrowseCategoryPageState extends State<BrowseCategoryPage> {
  _BrowseCategoryPageState();

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
        WooSignal.getInstance(config: wsConfig).then((wcStore) {
          waitForNextRequest = true;
          _page = _page + 1;
          wcStore
              .getProducts(perPage: 50, page: _page, status: "publish")
              .then((products) {
            waitForNextRequest = false;
            if (products.length == 0) {
              _shouldStopRequests = true;
            }
            _products.addAll(products.toList());
            setState(() {});
          });
        });
      }
    });
  }

  _fetchProductsForCategory() {
    WooSignal.getInstance(config: wsConfig).then((wcStore) {
      wcStore
          .getProducts(category: _selectedCategory.id.toString(), perPage: 50)
          .then((products) {
        _products = products;
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _selectedCategory = ModalRoute.of(context).settings.arguments;
      _fetchProductsForCategory();
    }
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
                style: Theme.of(context).primaryTextTheme.subhead),
            Text(_selectedCategory.name,
                style: Theme.of(context).primaryTextTheme.title)
          ],
        ),
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
