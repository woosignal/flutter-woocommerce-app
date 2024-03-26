import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartQuantity extends StatefulWidget {
  CartQuantity({super.key, this.childOfNavBar = false});

  final bool childOfNavBar;

  static String state = "cart_quantity";

  @override
  createState() => _CartQuantityState(childOfNavBar);
}

class _CartQuantityState extends NyState<CartQuantity> {
  bool _childOfNavBar = false;

  _CartQuantityState(childOfNavBar) {
    stateName = CartQuantity.state;
    _childOfNavBar = childOfNavBar;
  }

  @override
  stateUpdated(dynamic data) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder<List<CartLineItem>>(
      future: Cart.getInstance.getCart(),
      child: (BuildContext context, data) {
        if (data == null) {
          return SizedBox.shrink();
        }
        List<int?> cartItems = data.map((e) => e.quantity).toList();
        String cartValue = "0";
        if (cartItems.isNotEmpty) {
          cartValue = cartItems
              .reduce((value, element) => value! + element!)
              .toString();
        }
        if (cartValue == "0" && _childOfNavBar == true) {
          return SizedBox.shrink();
        }
        return Text(
          cartValue,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      },
      loading: SizedBox.shrink(),
    );
  }
}
