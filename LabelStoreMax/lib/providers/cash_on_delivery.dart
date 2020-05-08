//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:flutter/widgets.dart';
import 'package:label_storemax/helpers/data/order_wc.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/pages/checkout_confirmation.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';

cashOnDeliveryPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  try {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: false);

    Order order = await appWooSignal((api) => api.createOrder(orderWC));

    if (order != null) {
      Cart.getInstance.clear();
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showEdgeAlertWith(
        context,
        title: trans(context, "Error"),
        desc: trans(context,
            trans(context, "Something went wrong, please contact our store")),
      );
      state.reloadState(showLoader: false);
    }
  } catch (ex) {
    showEdgeAlertWith(
      context,
      title: trans(context, "Error"),
      desc: trans(context,
          trans(context, "Something went wrong, please contact our store")),
    );
    state.reloadState(showLoader: false);
  }
}
