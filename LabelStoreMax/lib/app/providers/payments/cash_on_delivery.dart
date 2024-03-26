//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import '/resources/pages/checkout_status_page.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

cashOnDeliveryPay(context, {TaxRate? taxRate}) async {
  try {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: false);

    Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

    if (order == null) {
      showToastNotification(
        context,
        title: trans("Error"),
        description: trans("Something went wrong, please contact our store"),
      );
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      return;
    }
    routeTo(CheckoutStatusPage.path, data: order);
  } catch (_) {
    showToastNotification(
      context,
      title: trans("Error"),
      description: trans("Something went wrong, please contact our store"),
    );
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
  }
}
