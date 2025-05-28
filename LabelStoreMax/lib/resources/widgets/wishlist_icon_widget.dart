import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '../../bootstrap/app_helper.dart';
import '../../bootstrap/enums/wishlist_action_enums.dart';
import '../../bootstrap/helpers.dart';

class WishlistIcon extends StatefulWidget {
  const WishlistIcon(this.product, {super.key});

  final Product? product;

  static String state = "wishlist_icon";

  @override
  createState() => _WishlistIconState();
}

class _WishlistIconState extends NyState<WishlistIcon> {
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  bool? _isInFavourites;

  _WishlistIconState() {
    stateName = WishlistIcon.state;
  }

  @override
  get init => () async {
        _isInFavourites = await hasAddedWishlistProduct(widget.product?.id);
      };

  @override
  stateUpdated(dynamic data) async {
    _isInFavourites = await hasAddedWishlistProduct(widget.product?.id);
    // updateState(WishlistIcon.state, data: "example payload");
  }

  @override
  LoadingStyle get loadingStyle => LoadingStyle.none();

  @override
  Widget view(BuildContext context) {
    if (!(_wooSignalApp?.wishlistEnabled ?? false) || _isInFavourites == null) {
      return SizedBox.shrink();
    }

    if (_isInFavourites!) {
      return IconButton(
          onPressed: () => toggleWishList(
              onSuccess: () => setState(() {}),
              wishlistAction: WishlistAction.remove),
          icon: Icon(Icons.favorite, color: Colors.red));
    }

    return IconButton(
        onPressed: () => toggleWishList(
            onSuccess: () => setState(() {}),
            wishlistAction: WishlistAction.add),
        icon: Icon(
          Icons.favorite_border,
        ));
  }

  toggleWishList(
      {required Function onSuccess,
      required WishlistAction wishlistAction}) async {
    String subtitleMsg;
    if (wishlistAction == WishlistAction.remove) {
      await removeWishlistProduct(product: widget.product);
      subtitleMsg = trans("This product has been removed from your wishlist");
    } else {
      await saveWishlistProduct(product: widget.product);
      subtitleMsg = trans("This product has been added to your wishlist");
    }
    _showToast(subtitleMsg);
    _isInFavourites = await hasAddedWishlistProduct(widget.product?.id);

    onSuccess();
  }

  _showToast(String message) {
    showStatusAlert(
      context,
      title: trans("Success"),
      subtitle: message,
      icon: Icons.favorite,
      duration: 1,
    );
  }
}
