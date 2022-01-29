//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_loader_controller.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/no_results_for_products_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailUpsellWidget extends StatefulWidget {
  ProductDetailUpsellWidget(
      {@required this.productIds, @required this.wooSignalApp});
  final List<int> productIds;
  final WooSignalApp wooSignalApp;

  @override
  _ProductDetailUpsellWidgetState createState() =>
      _ProductDetailUpsellWidgetState();
}

class _ProductDetailUpsellWidgetState extends State<ProductDetailUpsellWidget> {
  final RefreshController _refreshControllerUpsell =
      RefreshController(initialRefresh: false);

  final ProductLoaderController _productLoaderController =
      ProductLoaderController();

  bool _shouldStopRequests = false, _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> products = _productLoaderController.getResults();
    if (widget.productIds.isEmpty ||
        products.isEmpty ||
        widget.wooSignalApp.showUpsellProducts == false) {
      return SizedBox.shrink();
    }
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                trans("${trans('You may also like')}…"),
                style:
                    Theme.of(context).textTheme.caption.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        _isLoading == true
            ? AppLoaderWidget()
            : Container(
                height: 200,
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text(trans("pull up load"));
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = Text(trans("Load Failed! Click retry!"));
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text(trans("release to load more"));
                      } else {
                        return SizedBox.shrink();
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshControllerUpsell,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: (products.length != null && products.isNotEmpty
                      ? StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 250,
                              child: ProductItemContainer(
                                product: products[index],
                              ),
                            );
                          },
                          staggeredTileBuilder: (int index) {
                            return StaggeredTile.fit(2);
                          },
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                        )
                      : NoResultsForProductsWidget()),
                ),
              ),
      ],
    );
  }

  _onRefresh() async {
    _productLoaderController.clear();
    _shouldStopRequests = false;

    await fetchProducts();
    _refreshControllerUpsell.refreshCompleted();
  }

  _onLoading() async {
    await fetchProducts();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshControllerUpsell.loadNoData();
      } else {
        _refreshControllerUpsell.loadComplete();
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
        didFinish: () => setState(() {
              _isLoading = false;
            }),
        productIds: widget.productIds);
  }
}
