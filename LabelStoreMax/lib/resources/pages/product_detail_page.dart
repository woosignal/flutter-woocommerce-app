//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_detail_controller.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/enums/wishlist_action_enums.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/cart_icon_widget.dart';
import 'package:flutter_app/resources/widgets/future_build_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_body_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_footer_actions_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_variation.dart'
    as ws_product_variation;
import 'package:woosignal/models/response/products.dart' as ws_product;
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailPage extends NyStatefulWidget {
  @override
  final ProductDetailController controller = ProductDetailController();
  ProductDetailPage({Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends NyState<ProductDetailPage> {
  bool _isLoading = true;
  ws_product.Product? _product;

  List<ws_product_variation.ProductVariation> _productVariations = [];
  final Map<int, dynamic> _tmpAttributeObj = {};
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  init() async {
    _product = widget.controller.data();
    if (_product!.type == "variable") {
      await _fetchProductVariations();
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  _fetchProductVariations() async {
    List<ws_product_variation.ProductVariation> tmpVariations = [];
    int currentPage = 1;

    bool isFetching = true;
    while (isFetching) {
      List<ws_product_variation.ProductVariation> tmp = await (appWooSignal(
        (api) => api.getProductVariations(_product!.id!,
            perPage: 100, page: currentPage),
      ));
      if (tmp.isNotEmpty) {
        tmpVariations.addAll(tmp);
      }

      if (tmp.length >= 100) {
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

  _modalBottomSheetOptionsForAttribute(int attributeIndex) {
    wsModalBottom(
      context,
      title:
          "${trans("Select a")} ${_product!.attributes[attributeIndex].name}",
      bodyWidget: ListView.separated(
        itemCount: _product!.attributes[attributeIndex].options!.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _product!.attributes[attributeIndex].options![index],
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(attributeIndex) &&
                    _tmpAttributeObj[attributeIndex]["value"] ==
                        _product!.attributes[attributeIndex].options![index])
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () {
              _tmpAttributeObj[attributeIndex] = {
                "name": _product!.attributes[attributeIndex].name,
                "value": _product!.attributes[attributeIndex].options![index]
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

  _modalBottomSheetAttributes() {
    ws_product_variation.ProductVariation? productVariation = widget.controller
        .findProductVariation(
            tmpAttributeObj: _tmpAttributeObj,
            productVariations: _productVariations);
    wsModalBottom(
      context,
      title: trans("Options"),
      bodyWidget: ListView.separated(
        itemCount: _product!.attributes.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
          color: Colors.black12,
          thickness: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_product!.attributes[index].name!,
                style: Theme.of(context).textTheme.subtitle1),
            subtitle: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(index))
                ? Text(_tmpAttributeObj[index]["value"],
                    style: Theme.of(context).textTheme.bodyText1)
                : Text(
                    "${trans("Select a")} ${_product!.attributes[index].name}"),
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
                  : (((_product!.attributes.length ==
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
                action: () async {
                  if (_product!.attributes.length !=
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
                    quantityAmount: widget.controller.quantity,
                    options: options,
                    product: _product!,
                    productVariation: productVariation,
                  );

                  await widget.controller.itemAddToCart(
                      cartLineItem: cartLineItem,
                      onSuccess: () => setState(() => {}));
                  setState(() {});
                  Navigator.of(context).pop();
                }),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (_wooSignalApp!.wishlistEnabled!)
            FutureBuildWidget(
                asyncFuture: hasAddedWishlistProduct(_product!.id),
                onValue: (dynamic isInFavourites) {
                  return isInFavourites
                      ? IconButton(
                          onPressed: () => widget.controller.toggleWishList(
                              onSuccess: () => setState(() {}),
                              wishlistAction: WishlistAction.remove),
                          icon: Icon(Icons.favorite, color: Colors.red))
                      : IconButton(
                          onPressed: () => widget.controller.toggleWishList(
                              onSuccess: () => setState(() {}),
                              wishlistAction: WishlistAction.add),
                          icon: Icon(
                            Icons.favorite_border,
                          ));
                }),
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
                    child: ProductDetailBodyWidget(
                      wooSignalApp: _wooSignalApp,
                      product: _product,
                    ),
                  ),
                  // </Product body>
                  ProductDetailFooterActionsWidget(
                    onAddToCart: _addItemToCart,
                    onViewExternalProduct:
                        widget.controller.viewExternalProduct,
                    onAddQuantity: () => widget.controller
                        .addQuantityTapped(onSuccess: () => setState(() {})),
                    onRemoveQuantity: () => widget.controller
                        .removeQuantityTapped(onSuccess: () => setState(() {})),
                    product: _product,
                    quantity: widget.controller.quantity,
                  )
                ],
              ),
      ),
    );
  }

  _addItemToCart() async {
    if (_product!.type != "simple") {
      _modalBottomSheetAttributes();
      return;
    }
    if (_product!.stockStatus != "instock") {
      showToastNotification(context,
          title: trans("Sorry"),
          description: trans("This item is out of stock"),
          style: ToastNotificationStyleType.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    await widget.controller.itemAddToCart(
        cartLineItem: CartLineItem.fromProduct(
            quantityAmount: widget.controller.quantity, product: _product!),
        onSuccess: () => setState(() {}));
  }
}
