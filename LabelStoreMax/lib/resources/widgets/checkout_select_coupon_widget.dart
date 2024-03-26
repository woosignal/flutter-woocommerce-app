//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:woosignal/models/response/coupon.dart';
import '/resources/pages/coupon_page.dart';
import '/app/models/checkout_session.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutSelectCouponWidget extends StatefulWidget {
  const CheckoutSelectCouponWidget({
    super.key,
    required this.context,
    required this.checkoutSession,
  });

  final CheckoutSession checkoutSession;
  final BuildContext context;

  static String state = "checkout_select_coupon_widget";

  @override
  State<CheckoutSelectCouponWidget> createState() =>
      _CheckoutSelectCouponWidgetState();
}

class _CheckoutSelectCouponWidgetState
    extends NyState<CheckoutSelectCouponWidget> {
  _CheckoutSelectCouponWidgetState() {
    stateName = CheckoutSelectCouponWidget.state;
  }

  @override
  Widget build(BuildContext context) {
    bool hasCoupon = widget.checkoutSession.coupon != null;
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: _actionCoupon,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasCoupon
                  ? "Coupon Applied: ${widget.checkoutSession.coupon!.code!}"
                  : trans('Apply Coupon'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (hasCoupon == true)
              IconButton(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  onPressed: _clearCoupon,
                  icon: Icon(
                    Icons.close,
                    size: 19,
                  )),
            if (hasCoupon == false)
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }

  _clearCoupon() {
    CheckoutSession.getInstance.coupon = null;
    StateAction.refreshPage(CheckoutConfirmationPage.path, setState: () {});
  }

  _actionCoupon() {
    if (widget.checkoutSession.billingDetails!.billingAddress == null) {
      showToastNotification(
        widget.context,
        title: trans("Oops"),
        description:
            trans("Please select add your billing/shipping address to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );

      return;
    }
    if (widget.checkoutSession.billingDetails?.billingAddress
            ?.hasMissingFields() ??
        true) {
      showToastNotification(
        widget.context,
        title: trans("Oops"),
        description: trans("Your billing/shipping details are incomplete"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }
    routeTo(CouponPage.path, onPop: (value) {
      if (value is Coupon) {
        StateAction.refreshPage(CheckoutConfirmationPage.path, setState: () {});
      }
    });
  }
}
