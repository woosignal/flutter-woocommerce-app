//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/enums/sort_enums.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
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
    _fetchMoreProducts();
  }

  _fetchMoreProducts() async {
    waitForNextRequest = true;
    List<WS.Product> products = await appWooSignal((api) => api.getProducts(
        perPage: 50,
        category: _selectedCategory.id.toString(),
        page: _page,
        status: "publish",
        stockStatus: "instock"));
    _products.addAll(products);
    waitForNextRequest = false;
    _page = _page + 1;

    waitForNextRequest = false;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
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
            Text(parseHtmlString(_selectedCategory.name),
                style: Theme.of(context).primaryTextTheme.headline6)
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
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? Center(
                child: showAppLoader(),
              )
            : refreshableScroll(context,
                refreshController: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                products: _products,
                onTap: _showProduct),
      ),
    );
  }

  void _onRefresh() async {
    await _fetchMoreProducts();
    setState(() {});
    if (_shouldStopRequests) {
      _refreshController.resetNoData();
    } else {
      _refreshController.refreshCompleted();
    }
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

  _sortProducts({@required SortByType by}) {
    switch (by) {
      case SortByType.LowToHigh:
        _products.sort(
          (product1, product2) => (parseWcPrice(product1.price))
              .compareTo((parseWcPrice(product2.price))),
        );
        break;
      case SortByType.HighToLow:
        _products.sort(
          (product1, product2) => (parseWcPrice(product2.price))
              .compareTo((parseWcPrice(product1.price))),
        );
        break;
      case SortByType.NameAZ:
        _products.sort(
          (product1, product2) => product1.name.compareTo(product2.name),
        );
        break;
      case SortByType.NameZA:
        _products.sort(
          (product1, product2) => product2.name.compareTo(product1.name),
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
      title: trans(context, "Sort results"),
      bodyWidget: ListView(
        children: <Widget>[
          wsLinkButton(context,
              title: trans(context, "Sort: Low to high"),
              action: () => _sortProducts(by: SortByType.LowToHigh)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: High to low"),
              action: () => _sortProducts(by: SortByType.HighToLow)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: Name A-Z"),
              action: () => _sortProducts(by: SortByType.NameAZ)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: Name Z-A"),
              action: () => _sortProducts(by: SortByType.NameZA)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Cancel"), action: _dismissModal)
        ],
      ),
    );
  }

  _dismissModal() {
    Navigator.pop(context);
  }

  _showProduct(WS.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
