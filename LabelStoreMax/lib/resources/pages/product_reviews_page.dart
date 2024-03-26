//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/no_results_for_products_widget.dart';
import '/resources/widgets/product_review_item_container_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_review.dart';

class ProductReviewsPage extends NyStatefulWidget {
  static String path = "/product-reviews";

  ProductReviewsPage({Key? key})
      : super(path, key: key, child: _ProductReviewsPageState());
}

class _ProductReviewsPageState extends NyState<ProductReviewsPage> {
  Product? _product;

  @override
  boot() async {
    _product = widget.data() as Product?;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trans('Reviews')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: mediaQuery.size.height / 5,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      _product!.name!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "${_product!.ratingCount} Reviews",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Text(
                          "${_product!.averageRating!} Stars",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RatingBarIndicator(
                        rating: double.parse(_product!.averageRating!),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: NyPullToRefresh(
              data: (page) async {
                if (_product == null) {
                  return null;
                }
                return appWooSignal((api) => api.getProductReviews(
                      product: [_product!.id!],
                      perPage: 50,
                      page: page,
                      status: "approved",
                    ));
              },
              child: (context, review) {
                review as ProductReview;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black12))),
                  child:
                      ProductReviewItemContainerWidget(productReview: review),
                );
              },
              empty: NoResultsForProductsWidget(),
            ))
          ],
        ),
      ),
    );
  }
}
