//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/browse_search_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/products.dart' as WS;

class BrowseSearchPage extends NyStatefulWidget {
  final BrowseSearchController controller = BrowseSearchController();
  BrowseSearchPage({Key key}) : super(key: key);

  @override
  _BrowseSearchState createState() => _BrowseSearchState();
}

class _BrowseSearchState extends NyState<BrowseSearchPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<WS.Product> _products = [];
  String _search;
  int _page = 1;
  bool _shouldStopRequests = false,
      waitForNextRequest = false,
      _isLoading = true;

  @override
  widgetDidLoad() async {
    super.widgetDidLoad();
    _search = widget.controller.data();
    await _fetchProductsForSearch();
  }

  _fetchProductsForSearch() async {
    if (waitForNextRequest || _shouldStopRequests) {
      return;
    }
    waitForNextRequest = true;

    List<WS.Product> products = await appWooSignal(
      (api) => api.getProducts(
        perPage: 100,
        search: _search,
        page: _page,
        status: "publish",
        stockStatus: "instock",
      ),
    );

    if (products.length == 0) {
      _shouldStopRequests = true;
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      _products.addAll(products);
    }
    waitForNextRequest = false;
    _page = _page + 1;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans("Search results for"),
                style: Theme.of(context).textTheme.subtitle1),
            Text("\"" + _search + "\"")
          ],
        ),
        centerTitle: true,
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
                products: _products,
                onTap: _showProduct),
      ),
    );
  }

  void _onRefresh() async {
    _products = [];
    _page = 1;
    _shouldStopRequests = false;
    waitForNextRequest = false;
    await _fetchProductsForSearch();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await _fetchProductsForSearch();

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
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
