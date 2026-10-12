//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/wishlist_icon_widget.dart';
import '/resources/widgets/store_logo_widget.dart';
import '/app/controllers/product_detail_controller.dart';
import '/app/models/cart_line_item.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/cart_icon_widget.dart';
import '/resources/widgets/product_detail_body_widget.dart';
import '/resources/widgets/product_detail_footer_actions_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_variation.dart'
    as ws_product_variation;
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailPage extends NyStatefulWidget<ProductDetailController> {
  static RouteView path = ("/product-detail", (_) => ProductDetailPage());

  ProductDetailPage({super.key}) : super(child: () => _ProductDetailState());
}

class _ProductDetailState extends NyPage<ProductDetailPage> {
  ws_product.Product? _product;

  List<ws_product_variation.ProductVariation> _productVariations = [];
  final Map<int, dynamic> _tmpAttributeObj = {};
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  get init => () async {
        final dynamic data = widget.controller.data();
        if (data is Map && data.containsKey("productId")) {
          _product = await appWooSignal(
              (api) => api.retrieveProduct(id: data["productId"]));
        } else {
          _product = data;
        }
        widget.controller.product = _product;
        if (_product?.type == "variable") {
          await _fetchProductVariations();
        }
      };

  @override
  LoadingStyle loadingStyle = LoadingStyle.skeletonizer();

  Future<void> _fetchProductVariations() async {
    List<ws_product_variation.ProductVariation> tmpVariations = [];
    int currentPage = 1;

    bool isFetching = true;
    if (_product?.id == null) {
      return;
    }
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
  }

  void _modalBottomSheetOptionsForAttribute(int attributeIndex) {
    wsModalBottom(
      context,
      title:
          "${trans("Select a")} ${_product?.attributes[attributeIndex].name}",
      bodyWidget: ListView.separated(
        itemCount: _product?.attributes[attributeIndex].options?.length ?? 0,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.black12),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _product?.attributes[attributeIndex].options?[index] ?? "",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(attributeIndex) &&
                    _tmpAttributeObj[attributeIndex]["value"] ==
                        _product?.attributes[attributeIndex].options?[index])
                ? Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () {
              _tmpAttributeObj[attributeIndex] = {
                "name": _product?.attributes[attributeIndex].name,
                "value": _product?.attributes[attributeIndex].options?[index]
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

  void _modalBottomSheetAttributes() {
    ws_product_variation.ProductVariation? productVariation = widget.controller
        .findProductVariation(
            tmpAttributeObj: _tmpAttributeObj,
            productVariations: _productVariations);
    wsModalBottom(
      context,
      title: trans("Options"),
      bodyWidget: ListView.separated(
        itemCount: _product?.attributes.length ?? 0,
        separatorBuilder: (BuildContext context, int index) => Divider(
          color: Colors.black12,
          thickness: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_product?.attributes[index].name ?? "",
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: (_tmpAttributeObj.isNotEmpty &&
                    _tmpAttributeObj.containsKey(index))
                ? Text(_tmpAttributeObj[index]["value"],
                    style: Theme.of(context).textTheme.bodyLarge)
                : Text(
                    "${trans("Select a")} ${_product?.attributes[index].name}"),
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
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: <Widget>[
            Text(
              (productVariation != null
                  ? "${trans("Price")}: ${formatStringCurrency(total: productVariation.price)}"
                  : (((_product?.attributes.length ==
                              _tmpAttributeObj.values.length) &&
                          productVariation == null)
                      ? trans("This variation is unavailable")
                      : trans("Choose your options"))),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              (productVariation != null
                  ? productVariation.stockStatus != "instock"
                      ? trans("Out of stock")
                      : ""
                  : ""),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Button.primary(
                text: trans("Add to cart"),
                onPressed: () async {
                  if (_product?.attributes.length !=
                      _tmpAttributeObj.values.length) {
                    showToast(
                        title: trans("Oops"),
                        description: trans("Please select valid options first"),
                        id: 'warning');
                    return;
                  }

                  if (productVariation == null) {
                    showToast(
                        title: trans("Oops"),
                        description: trans("Product variation does not exist"),
                        id: 'warning');
                    return;
                  }

                  if (productVariation.stockStatus != "instock") {
                    showToast(
                        title: trans("Sorry"),
                        description: trans("This item is not in stock"),
                        id: 'warning');
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
                  );
                  pop();
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          WishlistIcon(_product),
          CartIconWidget(),
        ],
        title: StoreLogo(
            height: 55,
            showBgWhite: (Theme.of(context).brightness == Brightness.dark)),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
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
            onViewExternalProduct: widget.controller.viewExternalProduct,
            onAddQuantity: () => widget.controller.addQuantityTapped(),
            onRemoveQuantity: () => widget.controller.removeQuantityTapped(),
            product: _product,
            quantity: widget.controller.quantity,
          )
        ],
      )),
    );
  }

  Future<void> _addItemToCart() async {
    if (_product?.type != "simple") {
      _modalBottomSheetAttributes();
      return;
    }
    if (_product?.stockStatus != "instock") {
      showToast(
          title: trans("Sorry"),
          description: trans("This item is out of stock"),
          id: 'warning');
      return;
    }

    await widget.controller.itemAddToCart(
      cartLineItem: CartLineItem.fromProduct(
          quantityAmount: widget.controller.quantity, product: _product!),
    );
  }
}
