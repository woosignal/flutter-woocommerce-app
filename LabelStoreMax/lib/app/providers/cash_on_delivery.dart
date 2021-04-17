//
//  LabelCore
//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/widgets.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

cashOnDeliveryPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  try {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: false);

    Order order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showToastNotification(
        context,
        title: trans(context, "Error"),
        description: trans(context, "Something went wrong, please contact our store"),
      );
      state.reloadState(showLoader: false);
    }
  } catch (_) {
    showToastNotification(
      context,
      title: trans(context, "Error"),
      description: trans(context, "Something went wrong, please contact our store"),
    );
    state.reloadState(showLoader: false);
  }
}
