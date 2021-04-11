import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/home_drawer_widget.dart';
import 'package:flutter_app/resources/widgets/no_results_for_products_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/product_category.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WSProduct;

class NoticHomeWidget extends StatefulWidget {
  NoticHomeWidget({Key key, @required this.wooSignalApp}) : super(key: key);

  final WooSignalApp wooSignalApp;

  @override
  _NoticHomeWidgetState createState() => _NoticHomeWidgetState();
}

class _NoticHomeWidgetState extends State<NoticHomeWidget> {
  Widget activeWidget;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<WSProduct.Product> _products = [];
  List<WS.ProductCategory> _categories = [];

  int _page = 1;
  bool _shouldStopRequests = false,
      waitForNextRequest = false,
      _isLoading = true;

  @override
  void initState() {
    super.initState();
    _home();
  }

  _home() async {
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
    return Scaffold(
      drawer: HomeDrawerWidget(wooSignalApp: widget.wooSignalApp),
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 8),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: _modalBottomSheetMenu,
                child: Text(
                  trans(context, "Categories"),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            (_isLoading
                ? Expanded(child: AppLoaderWidget())
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return CachedImageWidget(
                                image: widget.wooSignalApp.bannerImages[index],
                                fit: BoxFit.cover,
                              );
                            },
                            itemCount: widget.wooSignalApp.bannerImages.length,
                            viewportFraction: 0.8,
                            scale: 0.9,
                          ),
                          height: MediaQuery.of(context).size.height / 2.5,
                        ),
                        Container(
                          height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trans(context, "Must have")),
                              Text(
                                trans(context, "Our selection of new items"),
                                style: Theme.of(context).textTheme.headline4,
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 250,
                          child: SmartRefresher(
                            enablePullDown: true,
                            enablePullUp: true,
                            footer: CustomFooter(
                              builder: (BuildContext context, LoadStatus mode) {
                                Widget body;
                                if (mode == LoadStatus.idle) {
                                  body = Text(trans(context, "pull up load"));
                                } else if (mode == LoadStatus.loading) {
                                  body = CupertinoActivityIndicator();
                                } else if (mode == LoadStatus.failed) {
                                  body = Text(trans(
                                      context, "Load Failed! Click retry!"));
                                } else if (mode == LoadStatus.canLoading) {
                                  body = Text(
                                      trans(context, "release to load more"));
                                } else {
                                  body =
                                      Text(trans(context, "No more products"));
                                }
                                return Container(
                                  height: 55.0,
                                  child: Center(child: body),
                                );
                              },
                            ),
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            onLoading: _onLoading,
                            child: (_products.length != null &&
                                    _products.length > 0
                                ? StaggeredGridView.countBuilder(
                                    crossAxisCount: 2,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _products.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 250,
                                        child: ProductItemContainer(
                                          index: index,
                                          product: _products[index],
                                          onTap: _showProduct,
                                        ),
                                      );
                                    },
                                    staggeredTileBuilder: (int index) {
                                      return new StaggeredTile.fit(2);
                                    },
                                    mainAxisSpacing: 4.0,
                                    crossAxisSpacing: 4.0,
                                  )
                                : NoResultsForProductsWidget()),
                          ),
                        )
                      ],
                    ),
                    flex: 1,
                  )),
          ],
        ),
      ),
    );
  }

  _onRefresh() async {
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
      Navigator.pushNamed(context, "/product-detail", arguments: product);
}
