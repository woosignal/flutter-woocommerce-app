import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_loader_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cart_icon_widget.dart';
import 'package:flutter_app/resources/widgets/home_drawer_widget.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/product_category.dart' as ws_category;
import 'package:woosignal/models/response/products.dart' as ws_product;

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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ProductLoaderController _productLoaderController =
      ProductLoaderController();

  List<ws_category.ProductCategory> _categories = [];

  bool _shouldStopRequests = false, _isLoading = true;

  @override
  void initState() {
    super.initState();
    _home();
  }

  _home() async {
    await fetchProducts();
    await _fetchCategories();
    setState(() {
      _isLoading = false;
    });
  }

  _fetchCategories() async {
    _categories =
        await appWooSignal((api) => api.getProductCategories(perPage: 100));
  }

  _modalBottomSheetMenu() {
    widget.globalKey.currentState.setState(() {});
    wsModalBottom(
      context,
      title: trans("Categories"),
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
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _isLoading
                  ? AppLoaderWidget()
                  : RefreshableScrollContainer(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      products: _productLoaderController.getResults(),
                      onTap: _showProduct,
                      bannerHeight: MediaQuery.of(context).size.height / 3.5,
                      bannerImages: bannerImages,
                      modalBottomSheetMenu: _modalBottomSheetMenu,
                    ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  _onRefresh() async {
    _productLoaderController.clear();
    _shouldStopRequests = false;

    await fetchProducts();
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
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
        didFinish: () => setState(() {}));
  }

  _showProduct(ws_product.Product product) =>
      Navigator.pushNamed(context, "/product-detail", arguments: product)
          .then((value) => widget.globalKey.currentState.setState(() {}));
}
