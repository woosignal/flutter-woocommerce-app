//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/bootstrap/wp_json_api_errors.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/product_review.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart'
    as wc_customer_info;
import 'package:wp_json_api/wp_json_api.dart';

class LeaveReviewPage extends NyStatefulWidget {
  static RouteView path = ("/product-leave-review", (_) => LeaveReviewPage());

  LeaveReviewPage({super.key}) : super(child: () => _LeaveReviewPageState());
}

class _LeaveReviewPageState extends NyPage<LeaveReviewPage> {
  LineItems? _lineItem;
  Order? _order;

  TextEditingController? _textEditingController;
  int? _rating;

  @override
  get init => () {
        _lineItem = widget.controller.data()['line_item'] as LineItems?;
        _order = widget.controller.data()['order'] as Order?;
        _textEditingController = TextEditingController();
        _rating = 5;
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trans("Leave a review")),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
          child: afterNotLocked('leave_review',
              loading: AppLoaderWidget(),
              child: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                    ),
                    Text(
                      trans("How would you rate"),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(_lineItem!.name!),
                    Flexible(
                      child: TextField(
                        controller: _textEditingController,
                        style: Theme.of(context).textTheme.titleMedium,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        autofocus: true,
                        obscureText: false,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    RatingBar.builder(
                      initialRating: _rating!.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        _rating = rating.toInt();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    Button.primary(
                        text: trans("Submit"), onPressed: _leaveReview),
                  ],
                ))),
    );
  }

  Future<void> _leaveReview() async {
    await lockRelease('leave_review', perform: () async {
      String review = _textEditingController!.text;
      wc_customer_info.Data? wcCustomerInfo = await _fetchWpUserData();
      if (wcCustomerInfo == null) {
        return;
      }

      bool isValid = check((validators) {
        validators.add(FormValidator.minLength(5).that(review, "Review"));
      }, onValidationError: (_) {
        showToastWarning(description: trans("Please check your details"));
      }).isValid;

      if (isValid == false) {
        return;
      }

      ProductReview? productReview =
          await (appWooSignal((api) => api.createProductReview(
                productId: _lineItem!.productId,
                verified: true,
                review: review,
                status: "approved",
                reviewer: [
                  _order!.billing!.firstName,
                  _order!.billing!.lastName
                ].join(" "),
                rating: _rating,
                reviewerEmail: _order!.billing!.email,
              )));

      if (productReview == null) {
        showToastOops(
            title: trans("Oops"), description: trans("Something went wrong"));
        return;
      }
      showToast(
          title: trans("Success"),
          description: trans("Your review has been submitted"),
          id: 'success');
      pop(result: _lineItem);
    });
  }

  /// Returns null (after telling the customer why) if it could not be loaded.
  Future<wc_customer_info.Data?> _fetchWpUserData() async {
    wc_customer_info.WCCustomerInfoResponse? wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse =
          await WPJsonAPI.instance.api((request) => request.wcCustomerInfo());
    } on Exception catch (e) {
      await showWpJsonApiError(e);
      return null;
    }

    if (wcCustomerInfoResponse?.data == null) {
      showToast(
          title: trans("Oops!"),
          description: trans("Something went wrong"),
          id: 'danger');
      return null;
    }
    return wcCustomerInfoResponse!.data;
  }
}
