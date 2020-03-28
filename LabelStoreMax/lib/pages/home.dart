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
import 'package:label_storemax/widgets/cart_icon.dart';
import 'package:woosignal/models/response/product_category.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WS;
import 'package:label_storemax/widgets/woosignal_ui.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  List<WS.Product> _products = [];
  List<WS.ProductCategory> _categories = [];

  var _productsController = ScrollController();

  int _page;
  bool _shouldStopRequests;
  bool waitForNextRequest;
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = true;

    _page = 1;
    _home();
    _addScrollListener();
  }

  _home() async {
    await _fetchProducts();
    await _fetchCategories();
    _shouldStopRequests = false;
    waitForNextRequest = false;
    setState(() {
      _isLoading = false;
    });
  }

  _fetchProducts() async {
    _products = await appWooSignal((api) {
      return api.getProducts(perPage: 50, page: _page, status: "publish");
    });
  }

  _fetchCategories() async {
    _categories = await appWooSignal((api) {
      return api.getProductCategories();
    });
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
      _page = _page + 1;
      return api.getProducts(perPage: 50, page: _page, status: "publish");
    });
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    setState(() {
      _products.addAll(products.toList());
    });
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return new Container(
          height: double.infinity,
          width: double.infinity - 10,
          color: Colors.transparent,
          child: new Container(
            padding: EdgeInsets.only(top: 25, left: 18, right: 18),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0)),
            ),
            child: Column(
              children: <Widget>[
                Text(trans(context, "Categories"),
                    style: Theme.of(context).primaryTextTheme.display1,
                    textAlign: TextAlign.left),
                Expanded(
                  child: new ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: Container(
                            child: Text(_categories[index].name),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: HexColor("#f2f2f2"), width: 2),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/browse-category",
                                arguments: _categories[index]);
                          },
                        );
                      }),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, "/home-menu");
            },
          ),
          margin: EdgeInsets.only(left: 0),
        ),
        title: storeLogo(height: 50),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              color: Colors.black,
              size: 35,
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/home-search");
            },
          ),
          wsCartIcon(context)
        ],
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(trans(context, "Shop") + " / ",
                        style: Theme.of(context).primaryTextTheme.subhead),
                    Text(
                      trans(context, "Newest"),
                      style: Theme.of(context).primaryTextTheme.body1,
                    )
                  ],
                ),
                MaterialButton(
                  minWidth: 100,
                  height: 60,
                  child: Text(
                    trans(context, "Browse categories"),
                    style: Theme.of(context).primaryTextTheme.body2,
                  ),
                  onPressed: () {
                    _modalBottomSheetMenu();
                  },
                )
              ],
            ),
            (_isLoading
                ? Expanded(child: showAppLoader())
                : Expanded(
                    child: GridView.count(
                      controller: _productsController,
                      crossAxisCount: 2,
                      children: List.generate(_products.length, (index) {
                        return wsCardProductItem(context,
                            index: index, product: _products[index]);
                      }),
                    ),
                    flex: 1,
                  )),
          ],
        ),
      ),
    );
  }
}
