import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/home_drawer_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/models/response/products.dart';

class CompoHomeWidget extends StatefulWidget {
  CompoHomeWidget({Key? key, required this.wooSignalApp}) : super(key: key);

  final WooSignalApp? wooSignalApp;

  @override
  _CompoHomeWidgetState createState() => _CompoHomeWidgetState();
}

class _CompoHomeWidgetState extends State<CompoHomeWidget> {
  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  _loadHome() async {
    categories = await (appWooSignal((api) =>
        api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true)));
    categories.sort((category1, category2) =>
        category1.menuOrder!.compareTo(category2.menuOrder!));

    for (var category in categories) {
      List<Product> products = await (appWooSignal(
        (api) => api.getProducts(
            perPage: 10,
            category: category.id.toString(),
            status: "publish",
            stockStatus: "instock"),
      ));
      if (products.isNotEmpty) {
        categoryAndProducts.addAll({category: products});
        setState(() {});
      }
    }
  }

  List<ProductCategory> categories = [];
  Map<ProductCategory, List<Product>> categoryAndProducts = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String>? bannerImages = widget.wooSignalApp!.bannerImages;
    return Scaffold(
      drawer: HomeDrawerWidget(wooSignalApp: widget.wooSignalApp),
      appBar: AppBar(
        centerTitle: true,
        title: StoreLogo(),
        elevation: 0,
      ),
      body: SafeArea(
        child: categoryAndProducts.isEmpty
            ? AppLoaderWidget()
            : ListView(
                shrinkWrap: true,
                children: [
                  if (bannerImages!.isNotEmpty)
                    Container(
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return CachedImageWidget(
                            image: bannerImages[index],
                            fit: BoxFit.cover,
                          );
                        },
                        itemCount: bannerImages.length,
                        viewportFraction: 0.8,
                        scale: 0.9,
                      ),
                      height: size.height / 2.5,
                    ),
                  ...categoryAndProducts.entries.map((catProds) {
                    double containerHeight = size.height / 1.1;
                    bool hasImage = catProds.key.image != null;
                    if (hasImage == false) {
                      containerHeight = (containerHeight / 2);
                    }
                    return Container(
                      height: containerHeight,
                      width: size.width,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          if (hasImage)
                            InkWell(
                              child: CachedImageWidget(
                                image: catProds.key.image!.src,
                                height: containerHeight / 2,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                              onTap: () => _showCategory(catProds.key),
                            ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 50,
                              minWidth: double.infinity,
                              maxHeight: 80.0,
                              maxWidth: double.infinity,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      catProds.key.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                      maxLines: 1,
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      width: size.width / 4,
                                      child: LinkButton(
                                        title: trans("View All"),
                                        action: () =>
                                            _showCategory(catProds.key),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: hasImage
                                ? (containerHeight / 2) / 1.2
                                : containerHeight / 1.2,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: false,
                              itemBuilder: (cxt, i) {
                                Product product = catProds.value[i];
                                return Container(
                                  height: MediaQuery.of(cxt).size.height,
                                  width: size.width / 2.5,
                                  child: ProductItemContainer(
                                      product: product, onTap: _showProduct),
                                );
                              },
                              itemCount: catProds.value.length,
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }

  _showCategory(ProductCategory productCategory) =>
      Navigator.pushNamed(context, "/browse-category",
          arguments: productCategory);

  _showProduct(Product product) =>
      Navigator.pushNamed(context, "/product-detail", arguments: product);
}
