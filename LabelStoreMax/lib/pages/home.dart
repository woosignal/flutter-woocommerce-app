//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/cart_icon.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<WS.Product> _products = [];
  List<WS.ProductCategory> _categories = [];
  final GlobalKey _key = GlobalKey();

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
  }

  _home() async {
    _shouldStopRequests = false;
    waitForNextRequest = false;
    await _fetchMoreProducts();
    await _fetchCategories();
    setState(() {
      _isLoading = false;
    });
  }

  _fetchCategories() async {
    _categories =
        await appWooSignal((api) => api.getProductCategories(page: 100));
  }

  _fetchMoreProducts() async {
    if (_shouldStopRequests) {
      return;
    }
    if (waitForNextRequest) {
      return;
    }
    waitForNextRequest = true;
    List<WS.Product> products = await appWooSignal((api) => api.getProducts(
        perPage: 50, page: _page, status: "publish", stockStatus: "instock"));
    _page = _page + 1;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    waitForNextRequest = false;
    setState(() {
      _products.addAll(products.toList());
    });
  }

  void _modalBottomSheetMenu() {
    _key.currentState.setState(() {});
    wsModalBottom(
      context,
      title: trans(context, "Categories"),
      bodyWidget: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (cxt, i) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(parseHtmlString(_categories[index].name)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/browse-category",
                      arguments: _categories[index])
                  .then((value) => setState(() {}));
            },
          );
        },
      ),
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
            onPressed: () => Navigator.pushNamed(context, "/home-menu"),
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
            onPressed: () => Navigator.pushNamed(context, "/home-search")
                .then((value) => _key.currentState.setState(() {})),
          ),
          wsCartIcon(context, key: _key),
        ],
      ),
      backgroundColor: Colors.white,
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
                    Text(
                      capitalize(trans(context, "Shop")) + " / ",
                      style: Theme.of(context).primaryTextTheme.subtitle1,
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      trans(context, "Newest"),
                      style: Theme.of(context).primaryTextTheme.bodyText2,
                      maxLines: 1,
                    ),
                  ],
                ),
                Flexible(
                  child: MaterialButton(
                    minWidth: 100,
                    height: 60,
                    child: AutoSizeText(
                      trans(context, "Browse categories"),
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                    onPressed: _modalBottomSheetMenu,
                  ),
                )
              ],
            ),
            (_isLoading
                ? Expanded(child: showAppLoader())
                : Expanded(
                    child: refreshableScroll(
                      context,
                      refreshController: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      products: _products,
                      onTap: _showProduct,
                    ),
                    flex: 1,
                  )),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    _products = [];
    _page = 1;
    _shouldStopRequests = false;
    waitForNextRequest = false;
    await _fetchMoreProducts();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await _fetchMoreProducts();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _showProduct(WS.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product)
        .then((value) => _key.currentState.setState(() {}));
  }
}
