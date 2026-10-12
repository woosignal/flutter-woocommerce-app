import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ShoppingCartTotal extends StatefulWidget {
  const ShoppingCartTotal({super.key});

  static String state = "shopping_cart_total";

  @override
  createState() => _ShoppingCartTotalState();
}

class _ShoppingCartTotalState extends NyState<ShoppingCartTotal> {
  String total = "";

  _ShoppingCartTotalState() {
    stateName = ShoppingCartTotal.state;
  }

  @override
  LoadingStyle loadingStyle = LoadingStyle.none();

  @override
  get init => () async {
        if (stateData != null && stateData is String) {
          total = stateData;
          return;
        }
        total = await Cart.getInstance.getTotal(withFormat: true);
      };

  @override
  Map<String, Function> get stateActions => {
        "refresh": () async {
          total = await Cart.getInstance.getTotal(withFormat: true);
        },
      };

  @override
  Widget view(BuildContext context) {
    return Text(
      total,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
    );
  }
}
