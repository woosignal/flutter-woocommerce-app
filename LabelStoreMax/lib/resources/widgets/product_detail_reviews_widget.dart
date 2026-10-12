//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/resources/pages/product_reviews_page.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/product_detail_review_tile_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_review.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailReviewsWidget extends StatefulWidget {
  const ProductDetailReviewsWidget(
      {super.key, required this.product, required this.wooSignalApp});
  final Product? product;
  final WooSignalApp? wooSignalApp;

  @override
  createState() => _ProductDetailReviewsWidgetState();
}

class _ProductDetailReviewsWidgetState
    extends NyState<ProductDetailReviewsWidget> {
  bool _ratingExpanded = false;

  /// Fetched once, the first time the customer expands the reviews tile.
  Future<List<ProductReview>>? _reviews;

  @override
  Widget view(BuildContext context) {
    if (widget.product?.reviewsAllowed == false ||
        widget.wooSignalApp?.showProductReviews == false) {
      return SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        Expanded(
            child: ExpansionTile(
          textColor: context.color.general.primaryAccent,
          iconColor: context.color.general.primaryAccent,
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.all(0),
          title: AutoSizeText(
            "${trans("Reviews")} (${widget.product?.ratingCount})",
            maxLines: 1,
          ),
          onExpansionChanged: (value) {
            if (value == true) {
              _reviews ??= fetchReviews();
            }
            setState(() {
              _ratingExpanded = value;
            });
          },
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RatingBarIndicator(
                  rating: double.parse(widget.product?.averageRating ?? "0"),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 25.0,
                  direction: Axis.horizontal,
                ),
                Icon(
                    _ratingExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 30)
              ],
            ),
          ),
          initiallyExpanded: false,
          children: [
            if (_ratingExpanded == true)
              FutureWidget<List<ProductReview>>(
                future: _reviews!,
                child: (context, reviews) {
                  if (reviews == null) {
                    return ListTile(
                      title: Text(
                        trans('There are no reviews yet.'),
                      ),
                    );
                  }
                  int reviewsCount = reviews.length;
                  List<Widget> childrenWidgets = [];
                  List<ProductDetailReviewTileWidget> children = reviews
                      .map((review) =>
                          ProductDetailReviewTileWidget(productReview: review))
                      .toList();
                  childrenWidgets.addAll(children);

                  if (reviewsCount >= 5) {
                    childrenWidgets.add(
                      ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          title: Text(
                            trans('See More Reviews'),
                          ),
                          onTap: () => routeTo(ProductReviewsPage.path,
                              data: widget.product)),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    children: reviews.isEmpty
                        ? [
                            ListTile(
                              title: Text(
                                trans('There are no reviews yet.'),
                              ),
                            )
                          ]
                        : childrenWidgets,
                  );
                },
                loadingStyle: LoadingStyle.normal(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CupertinoActivityIndicator(),
                )),
              ),
          ],
        )),
      ],
    );
  }

  Future<List<ProductReview>> fetchReviews() async {
    if (widget.product?.id == null) return [];
    return await appWooSignal(
      (api) => api.getProductReviews(
          perPage: 5, product: [widget.product!.id!], status: "approved"),
    );
  }
}
