import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartItemContainer extends StatelessWidget {
  const CartItemContainer({
    super.key,
    required this.cartLineItem,
    required this.actionIncrementQuantity,
    required this.actionDecrementQuantity,
    required this.actionRemoveItem,
  });

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
          children: [
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
                  children: [
                    Text(
                      cartLineItem.name!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    if (cartLineItem.variationOptions != null)
                      Text(cartLineItem.variationOptions!,
                          style: Theme.of(context).textTheme.bodyLarge),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          (cartLineItem.stockStatus == "outofstock"
                              ? trans("Out of stock")
                              : trans("In Stock")),
                          style: (cartLineItem.stockStatus == "outofstock"
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium),
                        ),
                        Text(
                          formatDoubleCurrency(
                            total: parseWcPrice(cartLineItem.total),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
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
                    style: Theme.of(context).textTheme.titleLarge),
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
