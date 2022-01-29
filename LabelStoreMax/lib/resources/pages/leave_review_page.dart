//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/product_review.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart'
    as wc_customer_info;
import 'package:wp_json_api/wp_json_api.dart';
import '../../app/controllers/leave_review_controller.dart';

class LeaveReviewPage extends NyStatefulWidget {
  final LeaveReviewController controller = LeaveReviewController();

  LeaveReviewPage({Key key}) : super(key: key);

  @override
  _LeaveReviewPageState createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends NyState<LeaveReviewPage> {
  LineItems _lineItem;
  Order _order;

  TextEditingController _textEditingController;
  int _rating;
  bool _isLoading = false;

  @override
  widgetDidLoad() async {
    _lineItem = widget.controller.data()['line_item'] as LineItems;
    _order = widget.controller.data()['order'] as Order;
    _textEditingController = TextEditingController();
    _rating = 5;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trans("Leave a review")),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
          child: _isLoading
              ? AppLoaderWidget()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                    ),
                    Text(
                      trans("How would you rate"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(_lineItem.name),
                    Flexible(
                      child: Container(
                        child: TextField(
                          controller: _textEditingController,
                          style: Theme.of(context).textTheme.subtitle1,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          autofocus: true,
                          obscureText: false,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    RatingBar.builder(
                      initialRating: _rating.toDouble(),
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
                    PrimaryButton(title: trans("Submit"), action: _leaveReview),
                  ],
                )),
    );
  }

  _leaveReview() async {
    if (_isLoading == true) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String review = _textEditingController.text;
    wc_customer_info.Data wcCustomerInfo = await _fetchWpUserData();
    if (wcCustomerInfo == null) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      validator(rules: {"review": "min:5"}, data: {"review": review});

      ProductReview productReview =
          await appWooSignal((api) => api.createProductReview(
                productId: _lineItem.productId,
                verified: true,
                review: review,
                status: "approved",
                reviewer: [_order.billing.firstName, _order.billing.lastName]
                    .join(" "),
                rating: _rating,
                reviewerEmail: _order.billing.email,
              ));

      if (productReview == null) {
        showToastNotification(context,
            title: trans("Oops"),
            description: trans("Something went wrong"),
            style: ToastNotificationStyleType.INFO);
        return;
      }
      showToastNotification(context,
          title: trans("Success"),
          description: trans("Your review has been submitted"),
          style: ToastNotificationStyleType.SUCCESS);
      pop(result: _lineItem);
    } on ValidationException catch (e) {
      NyLogger.error(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<wc_customer_info.Data> _fetchWpUserData() async {
    String userToken = await readAuthToken();

    wc_customer_info.WCCustomerInfoResponse wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wcCustomerInfo(userToken));

      if (wcCustomerInfoResponse == null) {
        return null;
      }
      if (wcCustomerInfoResponse.status != 200) {
        return null;
      }
      return wcCustomerInfoResponse.data;
    } on Exception catch (_) {
      return null;
    }
  }
}
