//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  Copyright © 2019 WooSignal. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:woosignal/models/response/product_variation.dart' as WS;
import 'package:woosignal/models/response/products.dart' as WS;
import 'package:woosignal/woosignal.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

class _ProductDetailState extends State<ProductDetailPage> {
  _ProductDetailState();

  bool _isLoading;
  WS.Product _product;
  List<WS.ProductVariation> _productVariations = [];

  @override
  void initState() {
    super.initState();

    _isLoading = true;
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
    wsModalBottom(context,
        title: trans(context, "Select a") +
            " " +
            _product.attributes[attributeIndex].name,
        bodyWidget: Expanded(
          child: ListView.separated(
            itemCount: _product.attributes[attributeIndex].options.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_product.attributes[attributeIndex].options[index],
                    style: Theme.of(context).primaryTextTheme.subhead),
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
          flex: 1,
        ));
  }

  _itemAddToCart({CartLineItem cartLineItem}) {
    Cart.getInstance.addToCart(cartLineItem: cartLineItem);
    showToastWith(message: trans(context, "Added to cart"), statusType: "");
    setState(() {});
  }

  void _modalBottomSheetAttributes() {
    wsModalBottom(context,
        title: trans(context, "Options"),
        bodyWidget: Expanded(
            child: ListView.separated(
          itemCount: _product.attributes.length,
          separatorBuilder: (BuildContext context, int index) => Divider(
            color: Colors.black12,
            thickness: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_product.attributes[index].name,
                  style: Theme.of(context).primaryTextTheme.subhead),
              subtitle: (_tmpAttributeObj.isNotEmpty &&
                      _tmpAttributeObj.containsKey(index))
                  ? Text(_tmpAttributeObj[index]["value"],
                      style: Theme.of(context).primaryTextTheme.body2)
                  : Text(trans(context, "Select a") +
                      " " +
                      _product.attributes[index].name),
              trailing: (_tmpAttributeObj.isNotEmpty &&
                      _tmpAttributeObj.containsKey(index))
                  ? Icon(Icons.check, color: Colors.blueAccent)
                  : null,
              onTap: () {
                _modalBottomSheetOptionsForAttribute(index);
              },
            );
          },
        )),
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
                          formatStringCurrency(
                              total: findProductVariation().price)
                      : (((_product.attributes.length ==
                                  _tmpAttributeObj.values.length) &&
                              findProductVariation() == null)
                          ? trans(context, "This variation is unavailable")
                          : trans(context, "Choose your options"))),
                  style: Theme.of(context).primaryTextTheme.subhead),
              Text(
                (findProductVariation() != null
                    ? findProductVariation().stockStatus != "instock"
                        ? trans(context, "Out of stock")
                        : ""
                    : ""),
                style: Theme.of(context).primaryTextTheme.subhead,
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

                if (findProductVariation() == null) {
                  showEdgeAlertWith(context,
                      title: trans(context, "Oops"),
                      desc: trans(context, "Product variation does not exist"),
                      style: EdgeAlertStyle.WARNING);
                  return;
                }

                if (findProductVariation() != null) {
                  if (findProductVariation().stockStatus != "instock") {
                    showEdgeAlertWith(context,
                        title: trans(context, "Sorry"),
                        desc: trans(context, "This item is not in stock"),
                        style: EdgeAlertStyle.WARNING);
                    return;
                  }
                }

                List<String> options = [];
                _tmpAttributeObj.forEach((k, v) {
                  options.add(v["name"] + ": " + v["value"]);
                });

                CartLineItem cartLineItem = CartLineItem(
                    name: _product.name,
                    productId: _product.id,
                    variationId: findProductVariation().id,
                    quantity: 1,
                    taxStatus: findProductVariation().taxStatus,
                    shippingClassId:
                        findProductVariation().shippingClassId.toString(),
                    subtotal: findProductVariation().price,
                    stockQuantity: findProductVariation().stockQuantity,
                    isManagedStock: findProductVariation().manageStock,
                    taxClass: findProductVariation().taxClass,
                    imageSrc: (findProductVariation().image != null
                        ? findProductVariation().image.src
                        : _product.images.first.src),
                    shippingIsTaxable: _product.shippingTaxable,
                    variationOptions: options.join(", "),
                    total: findProductVariation().price);

                _itemAddToCart(cartLineItem: cartLineItem);
                Navigator.of(context).pop();
              }),
            ],
          ),
          margin: EdgeInsets.only(bottom: 10),
        ));
  }

  void _modalBottomSheetMenu() {
    wsModalBottom(context,
        title: trans(context, "Description"),
        bodyWidget: Expanded(
          child: SingleChildScrollView(
            child: Text(parseHtmlString(_product.description)),
          ),
          flex: 1,
        ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _product = ModalRoute.of(context).settings.arguments;

      if (_product.type == "variable") {
        WooSignal.getInstance(config: wsConfig).then((wcStore) {
          wcStore.getProductVariations(_product.id).then((productVariations) {
            _productVariations = productVariations;
            _isLoading = false;
            setState(() {});
          });
        });
      } else {
        _isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[wsCartIcon(context)],
        title: storeLogo(height: 50),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? showAppLoader()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: SizedBox(
                      child: new Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return CachedNetworkImage(
                              imageUrl: _product.images[index].src,
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor: Colors.black12),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                              fit: BoxFit.contain);
                        },
                        itemCount: _product.images.length,
                        viewportFraction: 0.8,
                        scale: 0.9,
                        onTap: (i) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _product.name,
                            style: Theme.of(context).primaryTextTheme.body2,
                            textAlign: TextAlign.left,
                          ),
                          flex: 4,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                formatStringCurrency(total: _product.price),
                                style:
                                    Theme.of(context).primaryTextTheme.subhead,
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                ((_product.stockStatus != "instock"
                                    ? trans(context, "Out of stock")
                                    : trans(context, "In Stock"))),
                                style: Theme.of(context).primaryTextTheme.body1,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black12,
                    thickness: 1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              trans(context, "Description"),
                              style: Theme.of(context).primaryTextTheme.body1,
                              textAlign: TextAlign.left,
                            ),
                            MaterialButton(
                              child: Text(
                                trans(context, "Full description"),
                                style:
                                    Theme.of(context).primaryTextTheme.caption,
                                textAlign: TextAlign.right,
                              ),
                              height: 50,
                              minWidth: 60,
                              onPressed: () {
                                _modalBottomSheetMenu();
                              },
                            ),
                          ],
                        ),
                        Flexible(
                          child: Text(
                            (_product.shortDescription != null &&
                                    _product.shortDescription != ""
                                ? parseHtmlString(_product.shortDescription)
                                : parseHtmlString(_product.description)),
                          ),
                          flex: 3,
                        ),
                      ],
                    ),
                    flex: 1,
                  ),
                  wsPrimaryButton(
                    context,
                    title: trans(context, "ADD TO CART"),
                    action: () {
                      CartLineItem cartLineItem = CartLineItem(
                          name: _product.name,
                          productId: _product.id,
                          quantity: 1,
                          taxStatus: _product.taxStatus,
                          shippingClassId: _product.shippingClassId.toString(),
                          subtotal: _product.price,
                          taxClass: _product.taxClass,
                          isManagedStock: _product.manageStock,
                          stockQuantity: _product.stockQuantity,
                          shippingIsTaxable: _product.shippingTaxable,
                          imageSrc: _product.images.first.src,
                          total: _product.price);

                      if (_product.type != "simple") {
                        _modalBottomSheetAttributes();
                        return;
                      }
                      if (_product.stockStatus == "instock") {
                        _itemAddToCart(cartLineItem: cartLineItem);
                      } else {
                        showEdgeAlertWith(context,
                            title: trans(context, "Sorry"),
                            desc: trans(context, "This item is out of stock"),
                            style: EdgeAlertStyle.WARNING,
                            icon: Icons.local_shipping);
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage();

  @override
  _ProductDetailState createState() => _ProductDetailState();
}
