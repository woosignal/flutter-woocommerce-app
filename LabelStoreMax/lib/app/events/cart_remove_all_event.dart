import '/resources/pages/cart_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/resources/widgets/shopping_cart_total_widget.dart';
import '/app/models/cart.dart';

class CartRemoveAllEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    await Cart.getInstance.clear();

    // update states
    stateAction("refresh", state: ShoppingCartTotal.state);
    CollectionView.stateActions(CartPage.cartListState).reset();
    stateAction("cart_cleared", state: CartPage.path);
  }
}
