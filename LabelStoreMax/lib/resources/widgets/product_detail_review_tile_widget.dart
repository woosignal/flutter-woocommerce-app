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
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_review.dart';

class ProductDetailReviewTileWidget extends StatefulWidget {
  ProductDetailReviewTileWidget({Key? key, required this.productReview});
  final ProductReview productReview;

  @override
  _ProductDetailReviewTileWidgetState createState() =>
      _ProductDetailReviewTileWidgetState();
}

class _ProductDetailReviewTileWidgetState
    extends State<ProductDetailReviewTileWidget> {
  int? _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingBarIndicator(
                rating: widget.productReview.rating!.toDouble(),
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
              Text(widget.productReview.reviewer!),
              Text(
                formatDateTime("MMM d, yyyy").format(
                  parseDateTime(widget.productReview.dateCreated!),
                ),
              ),
            ],
          ),
          ListTile(
              title: Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(parseHtmlString(widget.productReview.review),
                    maxLines: _maxLines,
                    overflow: _maxLines != null
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible),
              ),
              contentPadding: EdgeInsets.all(0),
              minVerticalPadding: 0),
          if (_maxLines != null && widget.productReview.review!.length > 115)
            InkWell(
              child: Text(trans("More"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              onTap: () => setState(() {
                _maxLines = null;
              }),
            )
        ],
      ),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.black12, width: 1),
      )),
    );
  }
}
