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
import '/resources/pages/checkout_payment_type_page.dart';
import '/app/models/checkout_session.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutPaymentTypeWidget extends StatelessWidget {
  const CheckoutPaymentTypeWidget(
      {super.key,
      required this.context,
      required this.checkoutSession,
      this.resetState});
  final CheckoutSession checkoutSession;
  final BuildContext context;
  final Function? resetState;

  @override
  Widget build(BuildContext context) {
    bool hasPaymentType = checkoutSession.paymentType != null;
    return CheckoutRowLine(
      heading: trans(hasPaymentType ? "Payment method" : "Pay with"),
      leadImage: hasPaymentType
          ? Container(
              color: Colors.white,
              child: Image.asset(
                getImageAsset(checkoutSession.paymentType!.assetImage),
                width: 70,
              ),
            )
          : Icon(Icons.payment),
      leadTitle: hasPaymentType
          ? checkoutSession.paymentType!.desc
          : trans("Select a payment method"),
      action: _actionPayWith,
      showBorderBottom: true,
    );
  }

  _actionPayWith() {
    routeTo(CheckoutPaymentTypePage.path, onPop: (value) {
      StateAction.refreshPage(CheckoutConfirmationPage.path, setState: () {});
    });
  }
}
