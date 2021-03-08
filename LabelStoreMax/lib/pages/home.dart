//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/app_helper.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/cart_icon.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/product_category.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WSProduct;
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
  List<WSProduct.Product> _products = [];
  List<WS.ProductCategory> _categories = [];
  final GlobalKey _key = GlobalKey();

  int _page = 1;
  bool _shouldStopRequests, waitForNextRequest, _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        await appWooSignal((api) => api.getProductCategories(perPage: 100));
  }

  _fetchMoreProducts() async {
    if (_shouldStopRequests) {
      return;
    }
    if (waitForNextRequest) {
      return;
    }
    waitForNextRequest = true;

    List<WSProduct.Product> products = await appWooSignal((api) =>
        api.getProducts(
            perPage: 50,
            page: _page,
            status: "publish",
            stockStatus: "instock"));
    _page = _page + 1;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    waitForNextRequest = false;
    setState(() {
      _products.addAll(products.toList());
    });
  }

  _modalBottomSheetMenu() {
    _key.currentState.setState(() {});
    wsModalBottom(
      context,
      title: trans(context, "Categories"),
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
    List<String> bannerImages = AppHelper.instance.appConfig.bannerImages;
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
        title: StoreLogo(height: 55),
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
            (_isLoading
                ? Expanded(child: showAppLoader())
                : Expanded(
                    child: RefreshableScrollContainer(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      products: _products,
                      onTap: _showProduct,
                      bannerHeight: MediaQuery.of(context).size.height / 3.5,
                      bannerImages: bannerImages,
                      modalBottomSheetMenu: _modalBottomSheetMenu,
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

  _onLoading() async {
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

  _showProduct(WSProduct.Product product) =>
      Navigator.pushNamed(context, "/product-detail", arguments: product)
          .then((value) => _key.currentState.setState(() {}));
}
