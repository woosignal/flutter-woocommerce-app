//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/cart_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal/models/response/product_variation.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WSProduct;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailPage extends StatefulWidget {
  final WSProduct.Product product;
  const ProductDetailPage({Key key, @required this.product}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState(this.product);
}

class _ProductDetailState extends State<ProductDetailPage> {
  _ProductDetailState(this._product);

  bool _isLoading;
  WSProduct.Product _product;
  int _quantityIndicator = 1;
  List<WS.ProductVariation> _productVariations = [];

  @override
  void initState() {
    super.initState();
    if (_product.type == "variable") {
      _isLoading = true;
      _fetchProductVariations();
    } else {
      _isLoading = false;
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

  Map<int, dynamic> _tmpAttributeObj = {};

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

  void _modalBottomSheetOptionsForAttribute(int attributeIndex) {
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
              style: Theme.of(context).primaryTextTheme.subtitle1,
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

  _itemAddToCart({CartLineItem cartLineItem}) {
    Cart.getInstance.addToCart(cartLineItem: cartLineItem);
    showStatusAlert(context,
        title: "Success",
        subtitle: trans(context, "Added to cart"),
        duration: 1,
        icon: Icons.add_shopping_cart);
    setState(() {});
  }

  void _modalBottomSheetAttributes() {
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
                style: Theme.of(context).primaryTextTheme.subtitle1),
            subtitle: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(index))
                ? Text(_tmpAttributeObj[index]["value"],
                    style: Theme.of(context).primaryTextTheme.bodyText1)
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
                  ? trans(context, "Price") +
                      ": " +
                      formatStringCurrency(total: findProductVariation().price)
                  : (((_product.attributes.length ==
                              _tmpAttributeObj.values.length) &&
                          findProductVariation() == null)
                      ? trans(context, "This variation is unavailable")
                      : trans(context, "Choose your options"))),
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
            Text(
              (findProductVariation() != null
                  ? findProductVariation().stockStatus != "instock"
                      ? trans(context, "Out of stock")
                      : ""
                  : ""),
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
            wsPrimaryButton(context, title: trans(context, "Add to cart"),
                action: () {
              if (_product.attributes.length !=
                  _tmpAttributeObj.values.length) {
                showEdgeAlertWith(context,
                    title: trans(context, "Oops"),
                    desc: trans(context, "Please select valid options first"),
                    style: EdgeAlertStyle.WARNING);
                return;
              }

              WS.ProductVariation productVariation = findProductVariation();
              if (productVariation == null) {
                showEdgeAlertWith(context,
                    title: trans(context, "Oops"),
                    desc: trans(context, "Product variation does not exist"),
                    style: EdgeAlertStyle.WARNING);
                return;
              }

              if (productVariation.stockStatus != "instock") {
                showEdgeAlertWith(context,
                    title: trans(context, "Sorry"),
                    desc: trans(context, "This item is not in stock"),
                    style: EdgeAlertStyle.WARNING);
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
                quantity: 1,
                taxStatus: productVariation.taxStatus,
                shippingClassId: productVariation.shippingClassId.toString(),
                subtotal: productVariation.price,
                stockQuantity: productVariation.stockQuantity,
                isManagedStock: productVariation.manageStock,
                taxClass: productVariation.taxClass,
                imageSrc: (productVariation.image != null
                    ? productVariation.image.src
                    : _product.images.length == 0
                        ? app_product_placeholder_image
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

  void _modalBottomSheetMenu() {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          wsCartIcon(context),
        ],
        title: storeLogo(height: 55),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? showAppLoader()
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
                            child: new Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return CachedNetworkImage(
                                  imageUrl: _product.images.length == 0
                                      ? app_product_placeholder_image
                                      : _product.images[index].src,
                                  placeholder: (context, url) => Center(
                                    child: new CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor: Colors.black12,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                  fit: BoxFit.contain,
                                );
                              },
                              itemCount: _product.images.length == 0
                                  ? 1
                                  : _product.images.length,
                              viewportFraction: 0.85,
                              scale: 0.9,
                              onTap: _productImageTapped,
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
                                      .primaryTextTheme
                                      .bodyText1
                                      .copyWith(
                                          color: Colors.black87, fontSize: 20),
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
                                          .primaryTextTheme
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
                            color: Colors.white,
                            boxShadow: wsBoxShadow(),
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
                                        .primaryTextTheme
                                        .caption
                                        .copyWith(fontSize: 18),
                                    textAlign: TextAlign.left,
                                  ),
                                  MaterialButton(
                                    child: Text(
                                      trans(context, "Full description"),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText2
                                          .copyWith(fontSize: 14),
                                      textAlign: TextAlign.right,
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
                      color: Colors.white,
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
                                        .primaryTextTheme
                                        .bodyText1,
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
                                            .primaryTextTheme
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
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline4,
                                textAlign: TextAlign.center,
                              ),
                              alignment: Alignment.centerLeft,
                            )),
                            _product.type == "external"
                                ? Flexible(
                                    child: wsPrimaryButton(
                                      context,
                                      title: trans(context, "Buy Product"),
                                      action: () => _viewExternalProduct(),
                                    ),
                                  )
                                : Flexible(
                                    child: wsPrimaryButton(
                                      context,
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
    CartLineItem cartLineItem = CartLineItem(
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
          ? app_product_placeholder_image
          : _product.images.first.src,
      total: _product.price,
    );

    if (_product.type != "simple") {
      _modalBottomSheetAttributes();
      return;
    }
    if (_product.stockStatus != "instock") {
      showEdgeAlertWith(context,
          title: trans(context, "Sorry"),
          desc: trans(context, "This item is out of stock"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }
    _itemAddToCart(cartLineItem: cartLineItem);
  }

  _productImageTapped(int i) {
    Map<String, dynamic> obj = {
      "index": i,
      "images": _product.images.map((f) => f.src).toList()
    };
    Navigator.pushNamed(context, "/product-images", arguments: obj);
  }

  _addQuantityTapped() {
    if (_product.manageStock != null && _product.manageStock == true) {
      if (_quantityIndicator >= _product.stockQuantity) {
        showEdgeAlertWith(context,
            title: trans(context, "Maximum quantity reached"),
            desc:
                "${trans(context, "Sorry, only")} ${_product.stockQuantity} ${trans(context, "left")}",
            style: EdgeAlertStyle.INFO);
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

  _viewExternalProduct() {
    if (_product.externalUrl != null && _product.externalUrl.isNotEmpty) {
      // launch(_product.externalUrl);
      openBrowserTab(url: _product.externalUrl);
    }
  }
}
