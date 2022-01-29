//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

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
import 'package:flutter_app/resources/widgets/top_nav_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:nylo_support/helpers/helper.dart';
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
              body = Text(trans("pull up load"));
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text(trans("Load Failed! Click retry!"));
            } else if (mode == LoadStatus.canLoading) {
              body = Text(trans("release to load more"));
            } else {
              body = Text(trans("No more products"));
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
        child: (products.length != null && products.isNotEmpty
            ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount:
                    ((products.length + 1) + (bannerImages.isNotEmpty ? 1 : 0)),
                itemBuilder: (BuildContext context, int index) {
                  if (bannerImages.isNotEmpty && index == 0) {
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
                  if (bannerImages.isNotEmpty && index == 1 ||
                      bannerImages.isEmpty && index == 0) {
                    return TopNavWidget(
                      onPressBrowseCategories: modalBottomSheetMenu,
                    );
                  }
                  int productIndex =
                      ((index - 1) - (bannerImages.isNotEmpty ? 1 : 0));

                  return Container(
                    height: 200,
                    child: ProductItemContainer(
                      // index: productIndex,
                      product: products[productIndex],
                      onTap: onTap,
                    ),
                  );
                },
                staggeredTileBuilder: (int index) {
                  // When there's banners and we need to display the [TopNavWidget] widget
                  if (bannerImages.isNotEmpty && index == 1) {
                    return StaggeredTile.fit(2);
                  }
                  // When there's banners and we need to display the banner
                  if (bannerImages.isNotEmpty && index == 0) {
                    return StaggeredTile.fit(2);
                  }
                  // When there's no banners but we need to display the [TopNavWidget] widget
                  if (bannerImages.isEmpty && index == 0) {
                    return StaggeredTile.fit(2);
                  }
                  // display products
                  return StaggeredTile.fit(1);
                },
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              )
            : NoResultsForProductsWidget()),
      );
}

class CheckoutRowLine extends StatelessWidget {
  const CheckoutRowLine(
      {Key key,
      @required this.heading,
      @required this.leadImage,
      @required this.leadTitle,
      @required this.action,
      this.showBorderBottom = true})
      : super(key: key);

  final String heading;
  final String leadTitle;
  final Widget leadImage;
  final Function() action;
  final bool showBorderBottom;

  @override
  Widget build(BuildContext context) => Flexible(
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: ThemeColor.get(context).primaryContent),
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

class CheckoutMetaLine extends StatelessWidget {
  const CheckoutMetaLine({Key key, this.title, this.amount}) : super(key: key);

  final String title, amount;

  @override
  Widget build(BuildContext context) => Row(
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
        color: Color(0xFFE8E8E8),
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
    this.product,
    this.onTap,
  }) : super(key: key);

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
                        image: (product.images.isNotEmpty
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
                                            "${workoutSaleDiscount(salePrice: product.salePrice, priceBefore: product.regularPrice)}% ${trans("off")}",
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 15),
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
                                    text: '${trans("Was")}: ',
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
          onTap: () => onTap != null
              ? onTap(product)
              : Navigator.pushNamed(context, "/product-detail",
                  arguments: product),
        ),
      );
}

wsModalBottom(BuildContext context,
    {String title, Widget bodyWidget, Widget extraWidget}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (builder) {
      return SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColor.get(context).background,
              borderRadius: BorderRadius.only(
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context).background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: bodyWidget,
                  ),
                ),
                extraWidget
              ].where((t) => t != null).toList(),
            ),
          ),
        ),
      );
    },
  );
}

class CheckoutTotal extends StatelessWidget {
  const CheckoutTotal({Key key, this.title, this.taxRate}) : super(key: key);

  final String title;
  final TaxRate taxRate;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: CheckoutSession.getInstance
            .total(withFormat: true, taxRate: taxRate),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return AppLoaderWidget();
            default:
              if (snapshot.hasError) {
                return Text("");
              } else {
                return Padding(
                  child: CheckoutMetaLine(title: title, amount: snapshot.data),
                  padding: EdgeInsets.only(bottom: 0, top: 15),
                );
              }
          }
        },
      );
}

class CheckoutTaxTotal extends StatelessWidget {
  const CheckoutTaxTotal({Key key, this.taxRate}) : super(key: key);

  final TaxRate taxRate;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: Cart.getInstance.taxAmount(taxRate),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return AppLoaderWidget();
            default:
              if (snapshot.hasError) {
                return Text("");
              } else {
                return (snapshot.data == "0"
                    ? Container()
                    : Padding(
                        child: CheckoutMetaLine(
                          title: trans("Tax"),
                          amount: formatStringCurrency(total: snapshot.data),
                        ),
                        padding: EdgeInsets.only(bottom: 0, top: 0),
                      ));
              }
          }
        },
      );
}

class CheckoutSubtotal extends StatelessWidget {
  const CheckoutSubtotal({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: Cart.getInstance.getSubtotal(withFormat: true),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return AppLoaderWidget();
            default:
              if (snapshot.hasError) {
                return Text("");
              } else {
                return Padding(
                  child: CheckoutMetaLine(
                    title: title,
                    amount: snapshot.data,
                  ),
                  padding: EdgeInsets.only(bottom: 0, top: 0),
                );
              }
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
                                  ? trans("Out of stock")
                                  : trans("In Stock")),
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
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: actionDecrementQuantity,
                      highlightColor: Colors.transparent,
                    ),
                    Text(cartLineItem.quantity.toString(),
                        style: Theme.of(context).textTheme.headline6),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: actionIncrementQuantity,
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
            borderRadius: BorderRadius.circular(5)),
        child: CachedImageWidget(
          image: AppHelper.instance.appConfig.appLogo,
          height: height,
          placeholder: Container(height: height, width: width),
        ),
      );
}
