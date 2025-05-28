import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartQuantity extends StatefulWidget {
  const CartQuantity({super.key, this.childOfNavBar = false});

  final bool childOfNavBar;

  static String state = "cart_quantity";

  @override
  createState() => _CartQuantityState();
}

class _CartQuantityState extends NyState<CartQuantity> {
  int total = 0;

  _CartQuantityState() {
    stateName = CartQuantity.state;
  }

  @override
  LoadingStyle loadingStyle = LoadingStyle.none();

  @override
  get init => () async {
        List<CartLineItem> cartItems = await Cart.getInstance.getCart();
        List<int?> cartItemQuantity = cartItems.map((e) => e.quantity).toList();

        if (cartItemQuantity.isEmpty) return;

        total =
            cartItemQuantity.reduce((value, element) => value! + element!) ?? 0;
      };

  @override
  stateUpdated(dynamic data) async {
    List<CartLineItem> cartItems = await Cart.getInstance.getCart();
    List<int?> cartItemQuantity = cartItems.map((e) => e.quantity).toList();

    if (cartItemQuantity.isEmpty) return;

    total = cartItemQuantity.reduce((value, element) => value! + element!) ?? 0;

    setState(() {});
  }

  @override
  Widget view(BuildContext context) {
    if (total == 0) {
      return SizedBox.shrink();
    }

    if (total == 0 && widget.childOfNavBar == true) {
      return SizedBox.shrink();
    }

    return Text(
      total.toString(),
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}
