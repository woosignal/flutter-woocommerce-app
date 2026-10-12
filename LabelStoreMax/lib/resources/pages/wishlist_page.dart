//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/product_detail_page.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class WishlistPage extends NyStatefulWidget {
  static RouteView path = ("/wishlist", (_) => WishlistPage());

  WishlistPage({super.key})
      : super(child: () => _WishlistPageState());
}

class _WishlistPageState extends NyPage<WishlistPage> {
  List<Product> _products = [];

  @override
  bool get stateManaged => true;

  /// Actions this page accepts. `remove` drops a product from the list so the
  /// page stays in sync with whatever removed it from the wishlist.
  @override
  Map<String, Function> get stateActions => {
        "remove": (productId) {
          _products.removeWhere((product) => product.id == productId);
        },
      };

  @override
  get init => () async {
        await loadProducts();
      };

  Future<void> loadProducts() async {
    List<dynamic> favouriteProducts = await getWishlistProducts();
    List<int> productIds =
        favouriteProducts.map((e) => e['id']).cast<int>().toList();
    if (productIds.isEmpty) {
      return;
    }
    _products = await (appWooSignal((api) => api.getProducts(
          include: productIds,
          perPage: 100,
          status: "publish",
          stockStatus: "instock",
        )));
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Wishlist")),
      ),
      body: SafeArea(
        child: afterLoad(
            child: () => _products.isEmpty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        Text(trans("No items found"),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .setColor(context, (color) => color!.general.content))
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(top: 10),
                    itemBuilder: (BuildContext context, int index) {
                      Product product = _products[index];
                      return InkWell(
                        onTap: () =>
                            routeTo(ProductDetailPage.path, data: product),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              width: MediaQuery.of(context).size.width / 4,
                              child: CachedImageWidget(
                                image: (product.images.isNotEmpty
                                    ? product.images.first.src
                                    : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    formatStringCurrency(total: product.price),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 5,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeFromWishlist(product),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: _products.length)),
      ),
    );
  }

  Future<void> _removeFromWishlist(Product product) async {
    await removeWishlistProduct(product: product);
    showToast(
        title: trans('Success'),
        description: trans('Item removed'),
        id: 'success');
    stateAction("remove", state: WishlistPage.path, data: product.id);
  }
}
