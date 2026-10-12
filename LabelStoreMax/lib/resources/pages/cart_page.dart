//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
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
import '/routes/guards/auth_route_guard.dart';
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

  /// State name for the cart's CollectionView.
  static const String cartListState = "shopping_cart_items_list_view";

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

  Future<void> _cartCheck() async {
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
    await lockRelease('proceed_to_checkout', perform: _proceedToCheckout);
  }

  Future<void> _proceedToCheckout() async {
    List<CartLineItem> cartLineItems = await Cart.getInstance.getCart();

    if (cartLineItems.isEmpty) {
      showToast(
        title: trans("Cart"),
        description: trans("You need items in your cart to checkout"),
        id: 'warning',
      );
      return;
    }

    if (!cartLineItems.every(
        (c) => c.stockStatus == 'instock' || c.stockStatus == 'onbackorder')) {
      showToast(
        title: trans("Cart"),
        description: trans("There is an item out of stock"),
        id: 'warning',
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
                      routeTo(AccountLoginPage.path, data: {
                        intendedRouteKey: CheckoutConfirmationPage.path.name
                      });
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

  void _showToastCartCleared() {
    showToast(
        title: trans("Success"),
        description: trans("Cart cleared"),
        id: 'success');
  }

  void _showToastMaximumStockReached() {
    showToast(
      title: trans("Cart"),
      description: trans("Maximum stock reached"),
      id: 'warning',
    );
  }

  void _showToastCartItemRemoved() {
    showToast(
      title: trans("Updated"),
      description: trans("Item removed"),
      id: 'warning',
    );
  }

  @override
  Map<String, Function> get stateActions => {
        "cart_cleared": _showToastCartCleared,
        "item_removed": _showToastCartItemRemoved,
        "max_stock": _showToastMaximumStockReached,
      };

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
              child: CollectionView<CartLineItem>(
                builder: (context, cartLineItem) {
                  return CartProductItem(cartLineItem.data);
                },
                data: () async {
                  if (hasInitComplete) {
                    return await Cart.getInstance.getCart();
                  }
                  return _cartLines;
                },
                stateName: CartPage.cartListState,
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
