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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:woosignal/models/response/product_review.dart';

class ProductReviewItemContainerWidget extends StatelessWidget {
  const ProductReviewItemContainerWidget(
      {Key? key, required this.productReview})
      : super(key: key);

  final ProductReview productReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RatingBarIndicator(
            rating: productReview.rating!.toDouble(),
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(parseHtmlString(productReview.review)),
          ),
          Row(
            children: [
              Text(productReview.reviewer!),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.circle_rounded,
                  size: 3,
                ),
              ),
              Text(
                formatDateTime("MMM d, yyyy").format(
                  parseDateTime(productReview.dateCreated!),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
