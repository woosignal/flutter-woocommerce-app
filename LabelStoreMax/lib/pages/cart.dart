//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/shared_pref/sp_auth.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';

class CartPage extends StatefulWidget {
  CartPage();

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  _CartPageState();

  bool _isLoading = false;
  bool _isCartEmpty = false;
  List<CartLineItem> _cartLines;

  @override
  void initState() {
    super.initState();
    _cartLines = [];
    _isLoading = true;
    _cartCheck();
  }

  _cartCheck() async {
    List<CartLineItem> cart = await Cart.getInstance.getCart();
    if (cart.length <= 0) {
      setState(() {
        _isLoading = false;
        _isCartEmpty = (cart.length <= 0) ? true : false;
      });
      return [];
    }

    List<Map<String, dynamic>> cartJSON = cart.map((c) => c.toJson()).toList();

    List<dynamic> cartRes =
        await appWooSignal((api) => api.cartCheck(cartJSON));
    if (cartRes.length <= 0) {
      Cart.getInstance.saveCartToPref(cartLineItems: []);
      setState(() {
        _isCartEmpty = true;
        _isLoading = false;
      });
      return;
    }
    _cartLines = cartRes.map((json) => CartLineItem.fromJson(json)).toList();
    if (_cartLines.length > 0) {
      Cart.getInstance.saveCartToPref(cartLineItems: _cartLines);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _actionProceedToCheckout() async {
    List<CartLineItem> cartLineItems = await Cart.getInstance.getCart();
    if (_isLoading == true) {
      return;
    }
    if (cartLineItems.length <= 0) {
      showEdgeAlertWith(context,
          title: trans(context, "Cart"),
          desc: trans(context,
              trans(context, "You need items in your cart to checkout")),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.shopping_cart);
      return;
    }
    if (!cartLineItems.every(
        (c) => c.stockStatus == 'instock' || c.stockStatus == 'onbackorder')) {
      showEdgeAlertWith(context,
          title: trans(context, "Cart"),
          desc: trans(context, trans(context, "There is an item out of stock")),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.shopping_cart);
      return;
    }
    CheckoutSession.getInstance.initSession();
    CustomerAddress sfCustomerAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    if (sfCustomerAddress != null) {
      CheckoutSession.getInstance.billingDetails.billingAddress =
          sfCustomerAddress;
      CheckoutSession.getInstance.billingDetails.shippingAddress =
          sfCustomerAddress;
    }
    if (use_wp_login == true && !(await authCheck())) {
      UserAuth.instance.redirect = "/checkout";
      Navigator.pushNamed(context, "/account-landing");
      return;
    }
    Navigator.pushNamed(context, "/checkout");
  }

  actionIncrementQuantity({CartLineItem cartLineItem}) {
    if (cartLineItem.isManagedStock &&
        cartLineItem.quantity + 1 > cartLineItem.stockQuantity) {
      showEdgeAlertWith(
        context,
        title: trans(context, "Cart"),
        desc: trans(context, trans(context, "Maximum stock reached")),
        style: EdgeAlertStyle.WARNING,
        icon: Icons.shopping_cart,
      );
      return;
    }
    Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: 1);
    cartLineItem.quantity += 1;
    setState(() {});
  }

  actionDecrementQuantity({CartLineItem cartLineItem}) {
    if (cartLineItem.quantity - 1 <= 0) {
      return;
    }
    Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: -1);
    cartLineItem.quantity -= 1;
    setState(() {});
  }

  actionRemoveItem({int index}) {
    Cart.getInstance.removeCartItemForIndex(index: index);
    _cartLines.removeAt(index);
    showEdgeAlertWith(
      context,
      title: trans(context, "Updated"),
      desc: trans(context, "Item removed"),
      style: EdgeAlertStyle.WARNING,
      icon: Icons.remove_shopping_cart,
    );
    if (_cartLines.length == 0) {
      _isCartEmpty = true;
    }
    setState(() {});
  }

  void _clearCart() {
    Cart.getInstance.clear();
    _cartLines = [];
    showEdgeAlertWith(context,
        title: trans(context, "Success"),
        desc: trans(context, "Cart cleared"),
        style: EdgeAlertStyle.SUCCESS,
        icon: Icons.delete_outline);
    _isCartEmpty = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(trans(context, "Shopping Cart"),
            style: Theme.of(context).appBarTheme.textTheme.headline6),
        textTheme: Theme.of(context).textTheme,
        elevation: 1,
        actions: <Widget>[
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Align(
              child: Padding(
                child: Text(trans(context, "Clear Cart"),
                    style: Theme.of(context).primaryTextTheme.bodyText1),
                padding: EdgeInsets.only(right: 8),
              ),
              alignment: Alignment.centerLeft,
            ),
            onTap: _clearCart,
          )
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _isCartEmpty
                ? Expanded(
                    child: FractionallySizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_cart,
                            size: 100,
                            color: Colors.black45,
                          ),
                          Padding(
                            child: Text(trans(context, "Empty Basket"),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText2),
                            padding: EdgeInsets.only(top: 10),
                          )
                        ],
                      ),
                      heightFactor: 0.5,
                      widthFactor: 1,
                    ),
                  )
                : (_isLoading
                    ? Expanded(child: showAppLoader())
                    : Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _cartLines.length,
                            itemBuilder: (BuildContext context, int index) {
                              CartLineItem cartLineItem = _cartLines[index];
                              return wsCardCartItem(
                                context,
                                cartLineItem: cartLineItem,
                                actionIncrementQuantity: () =>
                                    actionIncrementQuantity(
                                        cartLineItem: cartLineItem),
                                actionDecrementQuantity: () =>
                                    actionDecrementQuantity(
                                        cartLineItem: cartLineItem),
                                actionRemoveItem: () =>
                                    actionRemoveItem(index: index),
                              );
                            }),
                        flex: 3,
                      )),
            Divider(
              color: Colors.black45,
            ),
            FutureBuilder<String>(
              future: Cart.getInstance.getTotal(withFormat: true),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text("");
                  default:
                    if (snapshot.hasError)
                      return Text("");
                    else
                      return new Padding(
                        child: wsRow2Text(context,
                            text1: trans(context, "Total"),
                            text2: (_isLoading ? "" : snapshot.data)),
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                      );
                }
              },
            ),
            wsPrimaryButton(
              context,
              title: trans(context, "PROCEED TO CHECKOUT"),
              action: _actionProceedToCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
