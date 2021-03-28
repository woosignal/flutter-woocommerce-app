//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/no_results_for_products_widget.dart';
import 'package:flutter_app/resources/widgets/text_row_widget.dart';
import 'package:flutter_app/resources/widgets/top_nav_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/tax_rate.dart';

class RefreshableScrollContainer extends StatelessWidget {
  const RefreshableScrollContainer(
      {Key key,
      this.controller,
      this.onRefresh,
      this.onLoading,
      this.products,
      this.onTap,
      this.bannerHeight,
      this.bannerImages,
      this.modalBottomSheetMenu})
      : super(key: key);

  final RefreshController controller;
  final Function onRefresh;
  final Function onLoading;
  final List<Product> products;
  final Function onTap;
  final double bannerHeight;
  final List<String> bannerImages;
  final Function modalBottomSheetMenu;

  @override
  Widget build(BuildContext context) => SmartRefresher(
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
              body = Text(trans(context, "Load Failed! Click retry!"));
            } else if (mode == LoadStatus.canLoading) {
              body = Text(trans(context, "release to load more"));
            } else {
              body = Text(trans(context, "No more products"));
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: controller,
        onRefresh: onRefresh,
        onLoading: onLoading,
        child: (products.length != null && products.length > 0
            ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount:
                    (products.length + (bannerImages.length > 0 ? 2 : 0)),
                itemBuilder: (BuildContext context, int index) {
                  if (bannerImages.length > 0 && index == 0) {
                    return Container(
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return CachedImageWidget(
                            image: bannerImages[index],
                            fit: BoxFit.contain,
                          );
                        },
                        itemCount: bannerImages.length,
                        viewportFraction: 0.8,
                        scale: 0.9,
                      ),
                      height: bannerHeight,
                    );
                  }
                  if (bannerImages.length > 0 && index == 1 ||
                      bannerImages.length == 0 && index == 0) {
                    return TopNavWidget(
                      onPressBrowseCategories: modalBottomSheetMenu,
                    );
                  }
                  int productIndex =
                      (index - (bannerImages.length > 0 ? 2 : 0));

                  return Container(
                    height: 200,
                    child: ProductItemContainer(
                      index: productIndex,
                      product: products[productIndex],
                      onTap: onTap,
                    ),
                  );
                },
                staggeredTileBuilder: (int index) {
                  if (index == 0) {
                    return new StaggeredTile.fit(2);
                  }
                  if (bannerImages.length == 0) {
                    return new StaggeredTile.fit(1);
                  }
                  if (bannerImages.length > 0 && index == 0 || index == 1) {
                    return new StaggeredTile.fit(2);
                  }
                  return new StaggeredTile.fit(1);
                },
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              )
            : NoResultsForProductsWidget()),
      );
}

Widget wsCheckoutRow(BuildContext context,
    {heading: String,
    Widget leadImage,
    String leadTitle,
    void Function() action,
    bool showBorderBottom}) {
  return Flexible(
    child: InkWell(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: Text(
                heading,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.only(bottom: 8),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        leadImage,
                        Expanded(
                          child: Container(
                            child: Text(
                              leadTitle,
                              style: Theme.of(context).textTheme.subtitle1,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            padding: EdgeInsets.only(left: 15),
                            margin: EdgeInsets.only(right: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            )
          ],
        ),
        padding: EdgeInsets.all(8),
        decoration: showBorderBottom == true
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              )
            : BoxDecoration(),
      ),
      onTap: action,
      borderRadius: BorderRadius.circular(8),
    ),
    flex: 3,
  );
}

class TextEditingRow extends StatelessWidget {
  const TextEditingRow({
    Key key,
    this.heading,
    this.controller,
    this.shouldAutoFocus,
    this.keyboardType,
    this.obscureText,
  }) : super(key: key);

  final String heading;
  final TextEditingController controller;
  final bool shouldAutoFocus;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Padding(
                child: Text(
                  heading,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                padding: EdgeInsets.only(bottom: 2),
              ),
            ),
            Flexible(
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.subtitle1,
                keyboardType: keyboardType ?? TextInputType.text,
                autocorrect: false,
                autofocus: shouldAutoFocus ?? false,
                obscureText: obscureText ?? false,
                textCapitalization: TextCapitalization.sentences,
              ),
            )
          ],
        ),
        padding: EdgeInsets.all(2),
        height: 78,
      );
}

Widget widgetCheckoutMeta(BuildContext context, {String title, String amount}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Flexible(
        child: Container(
          child: Text(title, style: Theme.of(context).textTheme.bodyText2),
        ),
        flex: 3,
      ),
      Flexible(
        child: Container(
          child: Text(amount, style: Theme.of(context).textTheme.bodyText1),
        ),
        flex: 3,
      )
    ],
  );
}

List<BoxShadow> wsBoxShadow({double blurRadius}) => [
      BoxShadow(
        color: HexColor("#e8e8e8"),
        blurRadius: blurRadius ?? 15.0,
        spreadRadius: 0,
        offset: Offset(
          0,
          0,
        ),
      )
    ];

class ProductItemContainer extends StatelessWidget {
  const ProductItemContainer({
    Key key,
    this.index,
    this.product,
    this.onTap,
  }) : super(key: key);

  final int index;
  final Product product;
  final Function onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (cxt, constraints) => InkWell(
          child: Container(
            margin: EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: constraints.maxHeight / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Stack(
                        children: [
                      Container(
                        color: Colors.grey[100],
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      CachedImageWidget(
                        image: (product.images.length > 0
                            ? product.images.first.src
                            : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                        fit: BoxFit.contain,
                        height: constraints.maxHeight / 2,
                        width: double.infinity,
                      ),
                      (product.onSale && product.type != "variable"
                          ? Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: '',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            "${workoutSaleDiscount(salePrice: product.salePrice, priceBefore: product.regularPrice)}% ${trans(context, "off")}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: Colors.black87,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : null),
                    ].where((e) => e != null).toList()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyText2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          "${formatStringCurrency(total: product.price)} ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                        (product.onSale && product.type != "variable"
                            ? RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '${trans(context, "Was")}: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          fontSize: 11,
                                        ),
                                  ),
                                  TextSpan(
                                    text: formatStringCurrency(
                                      total: product.regularPrice,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                  ),
                                ]),
                              )
                            : null),
                      ].where((e) => e != null).toList(),
                    ),
                  ),
                ),
              ].where((e) => e != null).toList(),
            ),
          ),
          onTap: () => onTap(product),
        ),
      );
}

wsModalBottom(BuildContext context,
    {String title, Widget bodyWidget, Widget extraWidget}) {
  AdaptiveThemeMode adaptiveThemeMode = AdaptiveTheme.of(context).mode;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (builder) {
      return SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.transparent,
          child: new Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: new BoxDecoration(
                color: adaptiveThemeMode.isLight
                    ? Colors.white
                    : Color(0xFF2C2C2C),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow:
                            adaptiveThemeMode.isLight ? wsBoxShadow() : null,
                        color: adaptiveThemeMode.isLight
                            ? Colors.white
                            : Color(0xFF4a4a4a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: bodyWidget,
                    ),
                  ),
                  extraWidget ?? null
                ].where((t) => t != null).toList(),
              )),
        ),
      );
    },
  );
}

FutureBuilder getTotalWidget() => FutureBuilder<String>(
      future: Cart.getInstance.getTotal(withFormat: true),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return AppLoaderWidget();
          default:
            if (snapshot.hasError)
              return Text("");
            else
              return new Padding(
                child: TextRowWidget(
                  title: trans(context, "Total"),
                  text: snapshot.data,
                ),
                padding: EdgeInsets.only(bottom: 15, top: 15),
              );
        }
      },
    );

FutureBuilder wsCheckoutTotalWidgetFB({String title, TaxRate taxRate}) {
  return FutureBuilder<String>(
    future:
        CheckoutSession.getInstance.total(withFormat: true, taxRate: taxRate),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return AppLoaderWidget();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return new Padding(
              child: widgetCheckoutMeta(context,
                  title: title, amount: snapshot.data),
              padding: EdgeInsets.only(bottom: 0, top: 15),
            );
      }
    },
  );
}

FutureBuilder wsCheckoutTaxAmountWidgetFB({TaxRate taxRate}) {
  return FutureBuilder<String>(
    future: Cart.getInstance.taxAmount(taxRate),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return AppLoaderWidget();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return (snapshot.data == "0"
                ? Container()
                : Padding(
                    child: widgetCheckoutMeta(
                      context,
                      title: trans(context, "Tax"),
                      amount: formatStringCurrency(total: snapshot.data),
                    ),
                    padding: EdgeInsets.only(bottom: 0, top: 0),
                  ));
      }
    },
  );
}

FutureBuilder wsCheckoutSubtotalWidgetFB({String title}) {
  return FutureBuilder<String>(
    future: Cart.getInstance.getSubtotal(withFormat: true),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return AppLoaderWidget();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return new Padding(
              child: widgetCheckoutMeta(
                context,
                title: title,
                amount: snapshot.data,
              ),
              padding: EdgeInsets.only(bottom: 0, top: 0),
            );
      }
    },
  );
}

FutureBuilder wsWidgetCartItemsFB(
    {void Function() actionIncrementQuantity,
    void Function() actionDecrementQuantity,
    void Function() actionRemoveItem}) {
  return FutureBuilder<List<CartLineItem>>(
    future: Cart.getInstance.getCart(),
    builder:
        (BuildContext context, AsyncSnapshot<List<CartLineItem>> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return AppLoaderWidget();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  CartLineItem cartLineItem = snapshot.data[index];
                  return CartItemContainer(
                      cartLineItem: cartLineItem,
                      actionIncrementQuantity: actionIncrementQuantity,
                      actionDecrementQuantity: actionDecrementQuantity,
                      actionRemoveItem: actionRemoveItem);
                });
      }
    },
  );
}

class CartItemContainer extends StatelessWidget {
  const CartItemContainer({
    Key key,
    @required this.cartLineItem,
    @required this.actionIncrementQuantity,
    @required this.actionDecrementQuantity,
    @required this.actionRemoveItem,
  }) : super(key: key);

  final CartLineItem cartLineItem;
  final void Function() actionIncrementQuantity;
  final void Function() actionDecrementQuantity;
  final void Function() actionRemoveItem;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: CachedImageWidget(
                    image: (cartLineItem.imageSrc == ""
                        ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                        : cartLineItem.imageSrc),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: Padding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          cartLineItem.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        (cartLineItem.variationOptions != null
                            ? Text(cartLineItem.variationOptions,
                                style: Theme.of(context).textTheme.bodyText1)
                            : Container()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              (cartLineItem.stockStatus == "outofstock"
                                  ? trans(context, "Out of stock")
                                  : trans(context, "In Stock")),
                              style: (cartLineItem.stockStatus == "outofstock"
                                  ? Theme.of(context).textTheme.caption
                                  : Theme.of(context).textTheme.bodyText2),
                            ),
                            Text(
                              formatDoubleCurrency(
                                total: parseWcPrice(cartLineItem.total),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(left: 8),
                  ),
                  flex: 5,
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: actionIncrementQuantity,
                      highlightColor: Colors.transparent,
                    ),
                    Text(cartLineItem.quantity.toString(),
                        style: Theme.of(context).textTheme.headline6),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: actionDecrementQuantity,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: Icon(Icons.delete_outline,
                      color: Colors.deepOrangeAccent, size: 20),
                  onPressed: actionRemoveItem,
                  highlightColor: Colors.transparent,
                ),
              ],
            )
          ],
        ),
      );
}

class StoreLogo extends StatelessWidget {
  const StoreLogo(
      {Key key,
      this.height = 100,
      this.width = 100,
      this.placeholder = const CircularProgressIndicator(),
      this.fit = BoxFit.contain,
      this.showBgWhite = true})
      : super(key: key);

  final bool showBgWhite;
  final double height;
  final double width;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: showBgWhite ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(3)),
        child: CachedImageWidget(
          image: AppHelper.instance.appConfig.appLogo,
          height: height,
          placeholder: Container(height: height, width: width),
        ),
      );
}
