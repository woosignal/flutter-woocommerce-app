import 'package:flutter/material.dart';
import '/app/events/cart_remove_item_event.dart';
import '/resources/pages/cart_page.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/cart_quantity_widget.dart';
import '/resources/widgets/shopping_cart_total_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/models/cart.dart';
import '../../app/models/cart_line_item.dart';
import '../../bootstrap/helpers.dart';
import 'cached_image_widget.dart';

class CartProductItem extends StatefulWidget {
  const CartProductItem(this.cartLineItem, {super.key});

  static String state = "cart_product_item";

  final CartLineItem cartLineItem;

  static String stateName(CartLineItem cartLineItem) =>
      "${CartProductItem.state}_${cartLineItem.productId}_${cartLineItem.variationId}";

  @override
  // ignore: no_logic_in_create_state
  createState() => _CartProductItemState(cartLineItem);
}

class _CartProductItemState extends NyState<CartProductItem> {
  _CartProductItemState(CartLineItem cartLineItem) {
    stateName = CartProductItem.stateName(cartLineItem);
  }

  @override
  get init => () {};

  @override
  stateUpdated(dynamic data) async {}

  @override
  Widget view(BuildContext context) {
    return Container(
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
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedImageWidget(
                    image: (widget.cartLineItem.imageSrc == ""
                        ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                        : widget.cartLineItem.imageSrc),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.cartLineItem.name ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      if (widget.cartLineItem.variationOptions != null)
                        Text(widget.cartLineItem.variationOptions ?? "",
                            style: Theme.of(context).textTheme.bodyLarge),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            (widget.cartLineItem.stockStatus == "outofstock"
                                ? trans("Out of stock")
                                : trans("In Stock")),
                            style:
                                (widget.cartLineItem.stockStatus == "outofstock"
                                    ? Theme.of(context).textTheme.bodySmall
                                    : Theme.of(context).textTheme.bodyMedium),
                          ),
                          Text(
                            formatDoubleCurrency(
                              total: parseWcPrice(widget.cartLineItem.total),
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
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: actionDecrementQuantity,
                    highlightColor: Colors.transparent,
                  ),
                  Text(widget.cartLineItem.quantity.toString(),
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
    ).onTap(() {
      routeTo(ProductDetailPage.path,
          data: {"productId": widget.cartLineItem.productId});
    });
  }

  actionIncrementQuantity() async {
    if (widget.cartLineItem.isManagedStock! &&
        widget.cartLineItem.quantity + 1 > widget.cartLineItem.stockQuantity!) {
      updateState(CartPage.path, data: {
        "action": "showToastMaximumStockReached",
      });
      return;
    }
    await Cart.getInstance.updateQuantity(
        cartLineItem: widget.cartLineItem, incrementQuantity: 1);
    widget.cartLineItem.quantity += 1;
    updateState(ShoppingCartTotal.state);
    updateState(CartQuantity.state);
    setState(() {});
  }

  actionDecrementQuantity() async {
    if (widget.cartLineItem.quantity - 1 <= 0) {
      return;
    }
    await Cart.getInstance.updateQuantity(
        cartLineItem: widget.cartLineItem, incrementQuantity: -1);
    widget.cartLineItem.quantity -= 1;

    updateState(ShoppingCartTotal.state);
    updateState(CartQuantity.state);
    setState(() {});
  }

  actionRemoveItem() async {
    event<CartRemoveItemEvent>(data: {"cartLineItem": widget.cartLineItem});
  }
}
