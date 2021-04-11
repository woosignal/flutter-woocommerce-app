import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cart_icon_widget.dart';
import 'package:flutter_app/resources/widgets/home_drawer_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/product_category.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WSProduct;

class MelloThemeWidget extends StatefulWidget {
  MelloThemeWidget(
      {Key key, @required this.globalKey, @required this.wooSignalApp})
      : super(key: key);
  final GlobalKey globalKey;
  final WooSignalApp wooSignalApp;

  @override
  _MelloThemeWidgetState createState() => _MelloThemeWidgetState();
}

class _MelloThemeWidgetState extends State<MelloThemeWidget> {
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
    widget.globalKey.currentState.setState(() {});
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
    List<String> bannerImages = widget.wooSignalApp.bannerImages;
    return Scaffold(
      drawer: HomeDrawerWidget(wooSignalApp: widget.wooSignalApp),
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              size: 35,
            ),
            onPressed: () => Navigator.pushNamed(context, "/home-search")
                .then((value) => widget.globalKey.currentState.setState(() {})),
          ),
          CartIconWidget(key: widget.globalKey),
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
      Navigator.pushNamed(context, "/product-detail", arguments: product)
          .then((value) => widget.globalKey.currentState.setState(() {}));
}
