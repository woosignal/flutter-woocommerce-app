//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:woosignal/models/response/tax_rate.dart';

const appFontFamily = "Overpass";

Widget wsRow2Text(BuildContext context, {String text1, String text2}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Flexible(
        child: Container(
          child: Text(text1, style: Theme.of(context).textTheme.headline6),
        ),
        flex: 3,
      ),
      Flexible(
        child: Container(
          child: Text(
            text2,
            style: Theme.of(context)
                .primaryTextTheme
                .bodyText1
                .copyWith(fontSize: 16, color: Colors.black87),
          ),
        ),
        flex: 3,
      )
    ],
  );
}

Widget wsNoResults(BuildContext context) {
  return Column(
    children: <Widget>[
      Text(trans(context, "No results"),
          style: Theme.of(context).primaryTextTheme.bodyText2),
    ],
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
              child: Text(heading,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(fontSize: 16)),
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
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle1,
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

Widget wsTextEditingRow(BuildContext context,
    {heading: String,
    TextEditingController controller,
    bool shouldAutoFocus,
    TextInputType keyboardType,
    bool obscureText}) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Padding(
            child: Text(
              heading,
              style: Theme.of(context).primaryTextTheme.bodyText1,
            ),
            padding: EdgeInsets.only(bottom: 2),
          ),
        ),
        Flexible(
          child: TextField(
            controller: controller,
            style: Theme.of(context).primaryTextTheme.subtitle1,
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
          child:
              Text(title, style: Theme.of(context).primaryTextTheme.bodyText2),
        ),
        flex: 3,
      ),
      Flexible(
        child: Container(
          child:
              Text(amount, style: Theme.of(context).primaryTextTheme.bodyText1),
        ),
        flex: 3,
      )
    ],
  );
}

List<BoxShadow> wsBoxShadow({double blurRadius}) {
  return [
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
}

Widget wsCardProductItem(BuildContext context,
    {int index, Product product, onTap}) {
  return LayoutBuilder(
    builder: (cxt, constraints) => InkWell(
      child: Container(
        margin: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: constraints.maxHeight / 1.75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: CachedNetworkImage(
                  imageUrl: (product.images.length > 0
                      ? product.images.first.src
                      : ""),
                  placeholder: (context, url) => Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    height: constraints.maxHeight / 1.75,
                  ),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                  fit: BoxFit.fitWidth,
                  height: constraints.maxHeight / 1.75,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.bodyText2,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.left,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  formatStringCurrency(total: product.price),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Flexible(
              child: Container(
                child: (product.onSale && product.type != "variable"
                    ? RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: '',
                          style: Theme.of(context).textTheme.bodyText1,
                          children: <TextSpan>[
                            TextSpan(
                              text: '${trans(context, "Was")}: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      color: Colors.black54, fontSize: 11),
                            ),
                            TextSpan(
                              text: formatStringCurrency(
                                  total: product.regularPrice),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 11),
                            ),
                            TextSpan(
                              text:
                                  " | ${workoutSaleDiscount(salePrice: product.salePrice, priceBefore: product.regularPrice)}% ${trans(context, "off")}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      color: Colors.black87, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    : null),
                width: double.infinity,
              ),
            ),
          ].where((e) => e != null).toList(),
        ),
      ),
      onTap: () => onTap(product),
    ),
  );
}

void wsModalBottom(BuildContext context,
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
            child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: new BoxDecoration(
                  color: Colors.white,
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
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: wsBoxShadow(),
                          color: Colors.white,
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
      });
}

FutureBuilder getTotalWidget() {
  return FutureBuilder<String>(
    future: Cart.getInstance.getTotal(withFormat: true),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return showAppLoader();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return new Padding(
              child: wsRow2Text(context,
                  text1: trans(context, "Total"), text2: snapshot.data),
              padding: EdgeInsets.only(bottom: 15, top: 15),
            );
      }
    },
  );
}

FutureBuilder wsCheckoutTotalWidgetFB({String title, TaxRate taxRate}) {
  return FutureBuilder<String>(
    future:
        CheckoutSession.getInstance.total(withFormat: true, taxRate: taxRate),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return showAppLoader();
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
          return showAppLoader();
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
          return showAppLoader();
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
          return showAppLoader();
        default:
          if (snapshot.hasError)
            return Text("");
          else
            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  CartLineItem cartLineItem = snapshot.data[index];
                  return wsCardCartItem(context,
                      cartLineItem: cartLineItem,
                      actionIncrementQuantity: actionIncrementQuantity,
                      actionDecrementQuantity: actionDecrementQuantity,
                      actionRemoveItem: actionRemoveItem);
                });
      }
    },
  );
}

Widget wsCardCartItem(BuildContext context,
    {CartLineItem cartLineItem,
    void Function() actionIncrementQuantity,
    void Function() actionDecrementQuantity,
    void Function() actionRemoveItem}) {
  return Container(
    margin: EdgeInsets.only(bottom: 7),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(
          color: Colors.black12,
          width: 1,
        ))),
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: CachedNetworkImage(
                imageUrl: cartLineItem.imageSrc,
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
                      style: Theme.of(context).primaryTextTheme.subtitle1,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    (cartLineItem.variationOptions != null
                        ? Text(cartLineItem.variationOptions,
                            style: Theme.of(context).primaryTextTheme.bodyText1)
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
                              : Theme.of(context).primaryTextTheme.bodyText2),
                        ),
                        Text(
                          formatDoubleCurrency(
                            total: parseWcPrice(cartLineItem.total),
                          ),
                          style: Theme.of(context).primaryTextTheme.subtitle1,
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
                    style: Theme.of(context).primaryTextTheme.headline6),
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

Widget storeLogo({double height, double width}) {
  return cachedImage(app_logo_url,
      height: height,
      placeholder: Container(height: height ?? 100, width: width ?? 100));
}

Widget cachedImage(image, {double height, Widget placeholder, BoxFit fit}) {
  return CachedNetworkImage(
    imageUrl: image,
    placeholder: (context, url) =>
        placeholder ?? new CircularProgressIndicator(),
    errorWidget: (context, url, error) => new Icon(Icons.error),
    height: height ?? null,
    width: null,
    alignment: Alignment.center,
    fit: fit,
  );
}
