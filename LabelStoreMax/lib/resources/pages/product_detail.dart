//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_detail_controller.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/cart_icon_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_variation.dart'
    as ws_product_variation;
import 'package:woosignal/models/response/products.dart' as ws_product;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailPage extends NyStatefulWidget {
  @override
  final ProductDetailController controller = ProductDetailController();
  ProductDetailPage({Key key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends NyState<ProductDetailPage> {
  bool _isLoading = false;
  ws_product.Product _product;
  bool isInFavourites = false;
  int _quantityIndicator = 1;
  List<ws_product_variation.ProductVariation> _productVariations = [];
  final Map<int, dynamic> _tmpAttributeObj = {};
  final WooSignalApp _wooSignalApp = AppHelper.instance.appConfig;

  @override
  widgetDidLoad() async {
    _product = widget.controller.data();

    if (_product.type == "variable") {
      _isLoading = true;
      await _fetchProductVariations();
    }
  }

  _fetchProductVariations() async {
    List<ws_product_variation.ProductVariation> tmpVariations = [];
    int currentPage = 1;

    bool isFetching = true;
    while (isFetching) {
      List<ws_product_variation.ProductVariation> tmp = await appWooSignal(
        (api) => api.getProductVariations(_product.id,
            perPage: 100, page: currentPage),
      );
      if (tmp != null && tmp.isNotEmpty) {
        tmpVariations.addAll(tmp);
      }

      if (tmp != null && tmp.length >= 100) {
        currentPage += 1;
      } else {
        isFetching = false;
      }
    }
    _productVariations = tmpVariations;
    setState(() {
      _isLoading = false;
    });
  }

  ws_product_variation.ProductVariation findProductVariation() {
    ws_product_variation.ProductVariation tmpProductVariation;

    Map<String, dynamic> tmpSelectedObj = {};
    for (var attributeObj in _tmpAttributeObj.values) {
      tmpSelectedObj[attributeObj["name"]] = attributeObj["value"];
    }

    for (var productVariation in _productVariations) {
      Map<String, dynamic> tmpVariations = {};

      for (var attr in productVariation.attributes) {
        tmpVariations[attr.name] = attr.option;
      }

      if (tmpVariations.toString() == tmpSelectedObj.toString()) {
        tmpProductVariation = productVariation;
      }
    }

    return tmpProductVariation;
  }

  _modalBottomSheetOptionsForAttribute(int attributeIndex) {
    wsModalBottom(
      context,
      title: "${trans("Select a")} ${_product.attributes[attributeIndex].name}",
      bodyWidget: ListView.separated(
        itemCount: _product.attributes[attributeIndex].options.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _product.attributes[attributeIndex].options[index],
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(attributeIndex) &&
                    _tmpAttributeObj[attributeIndex]["value"] ==
                        _product.attributes[attributeIndex].options[index])
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () {
              _tmpAttributeObj[attributeIndex] = {
                "name": _product.attributes[attributeIndex].name,
                "value": _product.attributes[attributeIndex].options[index]
              };
              Navigator.pop(context, () {});
              Navigator.pop(context);
              _modalBottomSheetAttributes();
            },
          );
        },
      ),
    );
  }

  _itemAddToCart({CartLineItem cartLineItem}) async {
    await Cart.getInstance.addToCart(cartLineItem: cartLineItem);
    showStatusAlert(context,
        title: trans("Success"),
        subtitle: trans("Added to cart"),
        duration: 1,
        icon: Icons.add_shopping_cart);
    setState(() {});
  }

  _modalBottomSheetAttributes() {
    ws_product_variation.ProductVariation productVariation =
        findProductVariation();
    wsModalBottom(
      context,
      title: trans("Options"),
      bodyWidget: ListView.separated(
        itemCount: _product.attributes.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
          color: Colors.black12,
          thickness: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_product.attributes[index].name,
                style: Theme.of(context).textTheme.subtitle1),
            subtitle: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(index))
                ? Text(_tmpAttributeObj[index]["value"],
                    style: Theme.of(context).textTheme.bodyText1)
                : Text(
                    "${trans("Select a")} ${_product.attributes[index].name}"),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(index))
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () => _modalBottomSheetOptionsForAttribute(index),
          );
        },
      ),
      extraWidget: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12, width: 1))),
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Text(
              (productVariation != null
                  ? "${trans("Price")}: ${formatStringCurrency(total: productVariation.price)}"
                  : (((_product.attributes.length ==
                              _tmpAttributeObj.values.length) &&
                          productVariation == null)
                      ? trans("This variation is unavailable")
                      : trans("Choose your options"))),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              (productVariation != null
                  ? productVariation.stockStatus != "instock"
                      ? trans("Out of stock")
                      : ""
                  : ""),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            PrimaryButton(
                title: trans("Add to cart"),
                action: () {
                  if (_product.attributes.length !=
                      _tmpAttributeObj.values.length) {
                    showToastNotification(context,
                        title: trans("Oops"),
                        description: trans("Please select valid options first"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  if (productVariation == null) {
                    showToastNotification(context,
                        title: trans("Oops"),
                        description: trans("Product variation does not exist"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  if (productVariation.stockStatus != "instock") {
                    showToastNotification(context,
                        title: trans("Sorry"),
                        description: trans("This item is not in stock"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  List<String> options = [];
                  _tmpAttributeObj.forEach((k, v) {
                    options.add("${v["name"]}: ${v["value"]}");
                  });

                  CartLineItem cartLineItem = CartLineItem.fromProductVariation(
                      quantityAmount: _quantityIndicator,
                      options: options,
                      product: _product,
                      productVariation: productVariation);

                  _itemAddToCart(cartLineItem: cartLineItem);
                  Navigator.of(context).pop();
                }),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10),
      ),
    );
  }

  _modalBottomSheetMenu() {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: Text(
          parseHtmlString(_product.description),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (_wooSignalApp.wishlistEnabled)
            IconButton(
              onPressed: _toggleWishList,
              icon: isInFavourites
                  ? Icon(Icons.favorite, color: Colors.red)
                  : Icon(Icons.favorite_border, color: Colors.black54),
            ),
          CartIconWidget(),
        ],
        title: StoreLogo(
            height: 55,
            showBgWhite: (Theme.of(context).brightness == Brightness.dark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? AppLoaderWidget()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.40,
                          child: SizedBox(
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) =>
                                  CachedImageWidget(
                                image: _product.images.isNotEmpty
                                    ? _product.images[index].src
                                    : getEnv("PRODUCT_PLACEHOLDER_IMAGE"),
                              ),
                              itemCount: _product.images.isEmpty
                                  ? 1
                                  : _product.images.length,
                              viewportFraction: 0.85,
                              scale: 0.9,
                              onTap: (int i) => widget.controller
                                  .viewProductImages(i, _product),
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  _product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 20),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                flex: 4,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      formatStringCurrency(
                                          total: _product.price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          .copyWith(
                                            fontSize: 20,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
                                    (_product.onSale == true &&
                                            _product.type != "variable"
                                        ? Text(
                                            formatStringCurrency(
                                                total: _product.regularPrice),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          )
                                        : null)
                                  ].where((t) => t != null).toList(),
                                ),
                                flex: 2,
                              )
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ThemeColor.get(context).background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          height: 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    trans("Description"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(fontSize: 18),
                                    textAlign: TextAlign.left,
                                  ),
                                  MaterialButton(
                                    child: Text(
                                      trans("Full description"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(fontSize: 14),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    height: 50,
                                    minWidth: 60,
                                    onPressed: _modalBottomSheetMenu,
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  (_product.shortDescription != null &&
                                          _product.shortDescription != ""
                                      ? parseHtmlString(
                                          _product.shortDescription)
                                      : parseHtmlString(_product.description)),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                flex: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context).background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15.0,
                          spreadRadius: -17,
                          offset: Offset(
                            0,
                            -10,
                          ),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        (_product.type != "external"
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    trans("Quantity"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(color: Colors.grey),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          size: 28,
                                        ),
                                        onPressed: _removeQuantityTapped,
                                      ),
                                      Text(
                                        _quantityIndicator.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          size: 28,
                                        ),
                                        onPressed: _addQuantityTapped,
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : null),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                                child: Align(
                              child: Text(
                                formatStringCurrency(
                                    total: (parseWcPrice(_product.price) *
                                            _quantityIndicator)
                                        .toString()),
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.center,
                              ),
                              alignment: Alignment.centerLeft,
                            )),
                            _product.type == "external"
                                ? Flexible(
                                    child: PrimaryButton(
                                      title: trans("Buy Product"),
                                      action: () => widget.controller
                                          .viewExternalProduct(_product),
                                    ),
                                  )
                                : Flexible(
                                    child: PrimaryButton(
                                      title: trans("Add to cart"),
                                      action: () => _addItemToCart(),
                                    ),
                                  ),
                          ],
                        ),
                      ].where((e) => e != null).toList(),
                    ),
                    height: 140,
                  ),
                ],
              ),
      ),
    );
  }

  _addItemToCart() {
    if (_product.type != "simple") {
      _modalBottomSheetAttributes();
      return;
    }
    if (_product.stockStatus != "instock") {
      showToastNotification(context,
          title: trans("Sorry"),
          description: trans("This item is out of stock"),
          style: ToastNotificationStyleType.WARNING,
          icon: Icons.local_shipping);
      return;
    }
    _itemAddToCart(
        cartLineItem: CartLineItem.fromProduct(
            quantityAmount: _quantityIndicator, product: _product));
  }

  _addQuantityTapped() {
    if (_product.manageStock != null && _product.manageStock == true) {
      if (_quantityIndicator >= _product.stockQuantity) {
        showToastNotification(context,
            title: trans("Maximum quantity reached"),
            description:
                "${trans("Sorry, only")} ${_product.stockQuantity} ${trans("left")}",
            style: ToastNotificationStyleType.INFO);
        return;
      }
    }
    if (_quantityIndicator != 0) {
      setState(() {
        _quantityIndicator++;
      });
    }
  }

  _removeQuantityTapped() {
    if ((_quantityIndicator - 1) >= 1) {
      setState(() {
        _quantityIndicator--;
      });
    }
  }

  _toggleWishList() async {
    String subtitleMsg;
    if (isInFavourites) {
      await removeWishlistProduct(product: _product);
      subtitleMsg = trans("This product has been removed from your wishlist");
    } else {
      await saveWishlistProduct(product: _product);
      subtitleMsg = trans("This product has been added to your wishlist");
    }
    showStatusAlert(context,
        title: trans("Success"),
        subtitle: subtitleMsg,
        icon: Icons.favorite,
        duration: 1);

    isInFavourites = !isInFavourites;
    setState(() {});
  }
}
