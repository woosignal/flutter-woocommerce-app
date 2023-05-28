//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class WishListPageWidget extends StatefulWidget {
  @override
  _WishListPageWidgetState createState() => _WishListPageWidgetState();
}

class _WishListPageWidgetState extends NyState<WishListPageWidget> {
  List<Product> _products = [];

  @override
  boot() async {
    await loadProducts();
  }

  loadProducts() async {
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
  Widget build(BuildContext context) {
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
                        .setColor(context,
                            (color) => color!.primaryContent))
              ],
            ),
          )
              : ListView.separated(
              padding: EdgeInsets.only(top: 10),
              itemBuilder: (BuildContext context, int index) {
                Product product = _products[index];
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                      context, "/product-detail",
                      arguments: product),
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: CachedImageWidget(
                            image: (product.images.isNotEmpty
                                ? product.images.first.src
                                : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                          width: MediaQuery.of(context).size.width / 4,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  formatStringCurrency(
                                      total: product.price),
                                ),
                              ],
                            ),
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
                            onPressed: () =>
                                _removeFromWishlist(product),
                          ),
                        )
                      ],
                    ),
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

  _removeFromWishlist(Product product) async {
    await removeWishlistProduct(product: product);
    showToastNotification(
      context,
      title: trans('Success'),
      icon: Icons.shopping_cart,
      description: trans('Item removed'),
    );
    _products.remove(product);
    setState(() {});
  }
}
