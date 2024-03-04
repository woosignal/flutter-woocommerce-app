//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutCouponAmountWidget extends StatelessWidget {
  const CheckoutCouponAmountWidget({super.key, required this.checkoutSession});

  final CheckoutSession checkoutSession;

  @override
  Widget build(BuildContext context) {
    if (checkoutSession.coupon == null) {
      return SizedBox.shrink();
    }
    return NyFutureBuilder<String>(
      future: Cart.getInstance.couponDiscountAmount(),
      child: (BuildContext context, data) => Padding(
        child: CheckoutMetaLine(
          title: "${trans('Coupon')}: ${checkoutSession.coupon?.code}",
          amount: "-${formatStringCurrency(total: data)}",
        ),
        padding: EdgeInsets.only(bottom: 0, top: 0),
      ),
    );
  }
}
