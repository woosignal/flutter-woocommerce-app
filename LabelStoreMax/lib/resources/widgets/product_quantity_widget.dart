import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProductQuantity extends StatefulWidget {
  
  ProductQuantity({Key? key, required this.productId}) : super(key: key);

  final int productId;

  static String state = "product_quantity";

  @override
  _ProductQuantityState createState() => _ProductQuantityState(productId);
}

class _ProductQuantityState extends NyState<ProductQuantity> {

  int quantity = 1;
  late int productId;

  _ProductQuantityState(this.productId) {
    stateName = ProductQuantity.state;
  }

  @override
  init() async {
    super.init();
  }
  
  @override
  stateUpdated(dynamic data) async {
    if (productId != data['product_id']) return;
    setState(() {
      quantity = data['quantity'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      quantity.toString(),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
