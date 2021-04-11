//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/app/controllers/product_detail_controller.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/cart_icon_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:nylo_framework/widgets/ny_state.dart';
import 'package:nylo_framework/widgets/ny_stateful_widget.dart';
import 'package:woosignal/models/response/product_variation.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WSProduct;
import 'package:flutter_swiper/flutter_swiper.dart';

class ProductDetailPage extends NyStatefulWidget {
  final ProductDetailController controller = ProductDetailController();
  ProductDetailPage({Key key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends NyState<ProductDetailPage> {
  bool _isLoading = false;
  WSProduct.Product _product;
  int _quantityIndicator = 1;
  List<WS.ProductVariation> _productVariations = [];
  Map<int, dynamic> _tmpAttributeObj = {};
  AppTheme _appTheme = AppTheme();

  @override
  widgetDidLoad() async {
    _product = widget.controller.data();

    if (_product.type == "variable") {
      _isLoading = true;
      await _fetchProductVariations();
    }
  }

  _fetchProductVariations() async {
    List<WS.ProductVariation> tmpVariations = [];
    int currentPage = 1;

    bool isFetching = true;
    while (isFetching) {
      List<WS.ProductVariation> tmp = await appWooSignal(
        (api) => api.getProductVariations(_product.id,
            perPage: 100, page: currentPage),
      );
      if (tmp != null && tmp.length > 0) {
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

  WS.ProductVariation findProductVariation() {
    WS.ProductVariation tmpProductVariation;

    Map<String, dynamic> tmpSelectedObj = {};
    (_tmpAttributeObj.values).forEach((attributeObj) {
      tmpSelectedObj[attributeObj["name"]] = attributeObj["value"];
    });

    _productVariations.forEach((productVariation) {
      Map<String, dynamic> tmpVariations = {};

      productVariation.attributes.forEach((attr) {
        tmpVariations[attr.name] = attr.option;
      });

      if (tmpVariations.toString() == tmpSelectedObj.toString()) {
        tmpProductVariation = productVariation;
      }
    });

    return tmpProductVariation;
  }

  _modalBottomSheetOptionsForAttribute(int attributeIndex) {
    wsModalBottom(
      context,
      title:
          "${trans(context, "Select a")} ${_product.attributes[attributeIndex].name}",
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
        title: trans(context, "Success"),
        subtitle: trans(context, "Added to cart"),
        duration: 1,
        icon: Icons.add_shopping_cart);
    setState(() {});
  }

  _modalBottomSheetAttributes() {
    wsModalBottom(
      context,
      title: trans(context, "Options"),
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
                    "${trans(context, "Select a")} ${_product.attributes[index].name}"),
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
              (findProductVariation() != null
                  ? "${trans(context, "Price")}: ${formatStringCurrency(total: findProductVariation().price)}"
                  : (((_product.attributes.length ==
                              _tmpAttributeObj.values.length) &&
                          findProductVariation() == null)
                      ? trans(context, "This variation is unavailable")
                      : trans(context, "Choose your options"))),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              (findProductVariation() != null
                  ? findProductVariation().stockStatus != "instock"
                      ? trans(context, "Out of stock")
                      : ""
                  : ""),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            PrimaryButton(
                title: trans(context, "Add to cart"),
                action: () {
                  if (_product.attributes.length !=
                      _tmpAttributeObj.values.length) {
                    showToastNotification(context,
                        title: trans(context, "Oops"),
                        description:
                            trans(context, "Please select valid options first"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  WS.ProductVariation productVariation = findProductVariation();
                  if (productVariation == null) {
                    showToastNotification(context,
                        title: trans(context, "Oops"),
                        description:
                            trans(context, "Product variation does not exist"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  if (productVariation.stockStatus != "instock") {
                    showToastNotification(context,
                        title: trans(context, "Sorry"),
                        description:
                            trans(context, "This item is not in stock"),
                        style: ToastNotificationStyleType.WARNING);
                    return;
                  }

                  List<String> options = [];
                  _tmpAttributeObj.forEach((k, v) {
                    options.add("${v["name"]}: ${v["value"]}");
                  });

                  CartLineItem cartLineItem = CartLineItem(
                    name: _product.name,
                    productId: _product.id,
                    variationId: productVariation.id,
                    quantity: _quantityIndicator,
                    taxStatus: productVariation.taxStatus,
                    shippingClassId:
                        productVariation.shippingClassId.toString(),
                    subtotal: productVariation.price,
                    stockQuantity: productVariation.stockQuantity,
                    isManagedStock: productVariation.manageStock,
                    taxClass: productVariation.taxClass,
                    imageSrc: (productVariation.image != null
                        ? productVariation.image.src
                        : _product.images.length == 0
                            ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                            : _product.images.first.src),
                    shippingIsTaxable: _product.shippingTaxable,
                    variationOptions: options.join(", "),
                    total: productVariation.price,
                  );

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
      title: trans(context, "Description"),
      bodyWidget: SingleChildScrollView(
        child: Text(
          parseHtmlString(_product.description),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          CartIconWidget(),
        ],
        title: StoreLogo(height: 55, showBgWhite: !adaptiveTheme.isLight),
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
                                image: _product.images[index].src,
                              ),
                              itemCount: _product.images.length == 0
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
                            color: adaptiveTheme.isLight
                                ? Colors.white
                                : Colors.black26,
                            // boxShadow: wsBoxShadow(),
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
                                    trans(context, "Description"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(fontSize: 18),
                                    textAlign: TextAlign.left,
                                  ),
                                  MaterialButton(
                                    child: Text(
                                      trans(context, "Full description"),
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
                      color: adaptiveTheme.isLight
                          ? Colors.white
                          : _appTheme.scaffoldColor(
                              brightness: Brightness.dark),
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
                                    trans(context, "Quantity"),
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
                                      title: trans(context, "Buy Product"),
                                      action: () => widget.controller
                                          .viewExternalProduct(_product),
                                    ),
                                  )
                                : Flexible(
                                    child: PrimaryButton(
                                      title: trans(context, "Add to cart"),
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
          title: trans(context, "Sorry"),
          description: trans(context, "This item is out of stock"),
          style: ToastNotificationStyleType.WARNING,
          icon: Icons.local_shipping);
      return;
    }
    _itemAddToCart(
        cartLineItem: CartLineItem(
      name: _product.name,
      productId: _product.id,
      quantity: _quantityIndicator,
      taxStatus: _product.taxStatus,
      shippingClassId: _product.shippingClassId.toString(),
      subtotal: _product.price,
      taxClass: _product.taxClass,
      isManagedStock: _product.manageStock,
      stockQuantity: _product.stockQuantity,
      shippingIsTaxable: _product.shippingTaxable,
      imageSrc: _product.images.length == 0
          ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
          : _product.images.first.src,
      total: _product.price,
    ));
  }

  _addQuantityTapped() {
    if (_product.manageStock != null && _product.manageStock == true) {
      if (_quantityIndicator >= _product.stockQuantity) {
        showToastNotification(context,
            title: trans(context, "Maximum quantity reached"),
            description:
                "${trans(context, "Sorry, only")} ${_product.stockQuantity} ${trans(context, "left")}",
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
}
