import 'package:flutter/material.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';

Widget wsCartIcon(BuildContext context) {
  return IconButton(
    icon: Stack(
      children: <Widget>[
        Positioned.fill(
            child: Align(
              child: Icon(Icons.shopping_cart, size: 20, color: Colors.black87),
              alignment: Alignment.bottomCenter,
            ),
            bottom: 0),
        Positioned.fill(
            child: Align(
              child: FutureBuilder<List<CartLineItem>>(
                future: Cart.getInstance.getCart(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CartLineItem>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text("");
                    default:
                      if (snapshot.hasError)
                        return Text("");
                      else
                        return new Text(
                          snapshot.data.length.toString(),
                          style: Theme.of(context).primaryTextTheme.body2,
                          textAlign: TextAlign.center,
                        );
                  }
                },
              ),
              alignment: Alignment.topCenter,
            ),
            top: 0)
      ],
    ),
    onPressed: () {
      Navigator.pushNamed(context, "/cart");
    },
  );
}
