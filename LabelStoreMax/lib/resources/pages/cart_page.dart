//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/events/cart_remove_all_event.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/cart_product_item_widget.dart';
import '/resources/widgets/shopping_cart_total_widget.dart';
import '/resources/pages/account_login_page.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/app/models/customer_address.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartPage extends NyStatefulWidget {
  static RouteView path = ("/cart", (_) => CartPage());

  CartPage({super.key}) : super(child: () => _CartPageState());
}

class _CartPageState extends NyPage<CartPage> {
  List<CartLineItem> _cartLines = [];

  @override
  LoadingStyle loadingStyle = LoadingStyle.skeletonizer();

  @override
  bool get stateManaged => true;

  @override
  get init => () async {
        await _cartCheck();
        CheckoutSession.getInstance.coupon = null;
      };

  _cartCheck() async {
    List<CartLineItem> cart = await Cart.getInstance.getCart();
    if (cart.isEmpty) {
      return;
    }

    List<Map<String, dynamic>> cartJSON = cart.map((c) => c.toJson()).toList();

    List<dynamic> cartRes =
        await (appWooSignal((api) => api.cartCheck(cartJSON)));
    if (cartRes.isEmpty) {
      await Cart.getInstance.saveCartToPref(cartLineItems: []);
      return;
    }
    _cartLines = cartRes.map((json) => CartLineItem.fromJson(json)).toList();
    if (_cartLines.isNotEmpty) {
      await Cart.getInstance.saveCartToPref(cartLineItems: _cartLines);
    }
  }

  void _actionProceedToCheckout() async {
    List<CartLineItem> cartLineItems = await Cart.getInstance.getCart();

    if (isLoading()) {
      return;
    }

    if (cartLineItems.isEmpty) {
      showToast(
        title: trans("Cart"),
        description: trans("You need items in your cart to checkout"),
        style: ToastNotificationStyleType.warning,
        icon: Icons.shopping_cart,
      );
      return;
    }

    if (!cartLineItems.every(
        (c) => c.stockStatus == 'instock' || c.stockStatus == 'onbackorder')) {
      showToast(
        title: trans("Cart"),
        description: trans("There is an item out of stock"),
        style: ToastNotificationStyleType.warning,
        icon: Icons.shopping_cart,
      );
      return;
    }

    CheckoutSession.getInstance.initSession();
    CustomerAddress? sfCustomerAddress =
        await CheckoutSession.getInstance.getBillingAddress();

    if (sfCustomerAddress != null) {
      CheckoutSession.getInstance.billingDetails!.billingAddress =
          sfCustomerAddress;
      CheckoutSession.getInstance.billingDetails!.shippingAddress =
          sfCustomerAddress;
    }

    if (!(await WPJsonAPI.wpUserLoggedIn())) {
      // show modal to ask customer if they would like to checkout as guest or login
      if (!mounted) return;
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              content: Text("Checkout as guest or login to continue".tr())
                  .headingMedium(),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    routeTo(CheckoutConfirmationPage.path);
                  },
                  child: Text("Checkout as guest".tr()),
                ),
                if (AppHelper.instance.appConfig!.wpLoginEnabled == 1)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      UserAuth.instance.redirect =
                          CheckoutConfirmationPage.path.name;
                      routeTo(AccountLoginPage.path);
                    },
                    child: Text("Login / Create an account".tr()),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel".tr()),
                )
              ],
            );
          });
      return;
    }
    routeTo(CheckoutConfirmationPage.path);
  }

  _showToastCartCleared() {
    showToast(
        title: trans("Success"),
        description: trans("Cart cleared"),
        style: ToastNotificationStyleType.success,
        icon: Icons.delete_outline);
  }

  _showToastMaximumStockReached() {
    showToast(
      title: trans("Cart"),
      description: trans("Maximum stock reached"),
      style: ToastNotificationStyleType.warning,
      icon: Icons.shopping_cart,
    );
  }

  _showToastCartItemRemoved() {
    showToast(
      title: trans("Updated"),
      description: trans("Item removed"),
      style: ToastNotificationStyleType.warning,
      icon: Icons.remove_shopping_cart,
    );
  }

  @override
  stateUpdated(data) async {
    if (data["action"] == "showToastMaximumStockReached") {
      _showToastMaximumStockReached();
      return;
    }
    if (data["action"] == "showToastCartItemRemoved") {
      _showToastCartItemRemoved();
      return;
    }
    if (data["action"] == "showToastCartCleared") {
      _showToastCartCleared();
      return;
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Shopping Cart"),
        ),
        elevation: 1,
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                trans("Clear Cart"),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ).onTap(() {
            event<CartRemoveAllEvent>();
          })
        ],
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NyListView(
                child: (context, cartLineItem) {
                  return CartProductItem(cartLineItem);
                },
                data: () async {
                  if (hasInitComplete) {
                    return await Cart.getInstance.getCart();
                  }
                  return _cartLines;
                },
                stateName: "shopping_cart_items_list_view",
                loadingStyle: LoadingStyle.none(),
                empty: FractionallySizedBox(
                  heightFactor: 0.5,
                  widthFactor: 1,
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
                        padding: EdgeInsets.only(top: 0),
                        child: Text(
                          trans("Empty Basket"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade200,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Text(trans("Total"),
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Flexible(flex: 3, child: ShoppingCartTotal())
              ],
            ).paddingSymmetric(vertical: 15),
            Button.primary(
                text: trans("PROCEED TO CHECKOUT"),
                onPressed: _actionProceedToCheckout),
          ],
        ),
      ),
    );
  }
}
