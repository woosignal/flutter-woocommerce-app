//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/browse_search_controller.dart';
import 'package:flutter_app/app/controllers/product_search_loader_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:woosignal/models/response/products.dart' as ws_product;

class BrowseSearchPage extends NyStatefulWidget {
  final BrowseSearchController controller = BrowseSearchController();
  BrowseSearchPage({Key? key}) : super(key: key);

  @override
  _BrowseSearchState createState() => _BrowseSearchState();
}

class _BrowseSearchState extends NyState<BrowseSearchPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ProductSearchLoaderController _productSearchLoaderController =
      ProductSearchLoaderController();

  String? _search;
  bool _shouldStopRequests = false, _isLoading = true;

  @override
  init() async {
    _search = widget.controller.data();
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
            Text(trans("Search results for"),
                style: Theme.of(context).textTheme.subtitle1),
            Text("\"" + _search! + "\"")
          ],
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: _isLoading
            ? Center(
                child: AppLoaderWidget(),
              )
            : refreshableScroll(
                context,
                refreshController: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                products: _productSearchLoaderController.getResults(),
                onTap: _showProduct,
              ),
      ),
    );
  }

  void _onRefresh() async {
    _productSearchLoaderController.clear();
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

  Future fetchProducts() async {
    await _productSearchLoaderController.loadProducts(
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
      search: _search,
    );
  }

  _showProduct(ws_product.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
