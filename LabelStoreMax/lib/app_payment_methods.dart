//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/payment_type.dart';
import 'package:label_storemax/providers/cash_on_delivery.dart';
import 'package:label_storemax/providers/razor_pay.dart';
import 'package:label_storemax/providers/stripe_pay.dart';

// Payment methods available for uses in the app

List<PaymentType> arrPaymentMethods = [
  addPayment(
    PaymentType(
      id: 1,
      name: "Stripe",
      desc: "Debit or Credit Card",
      assetImage: "dark_powered_by_stripe.png",
      pay: stripePay,
    ),
  ),

  addPayment(
    PaymentType(
      id: 2,
      name: "CashOnDelivery",
      desc: "Cash on delivery",
      assetImage: "cash_on_delivery.jpeg",
      pay: cashOnDeliveryPay,
    ),
  ),

  addPayment(
    PaymentType(
      id: 3,
      name: "RazorPay",
      desc: "Debit or Credit Card",
      assetImage: "razorpay.png",
      pay: razorPay,
    ),
  ),

  // e.g. add more here

//  addPayment(
//    PaymentType(
//      id: 4,
//      name: "MyNewPaymentMethod",
//      desc: "Debit or Credit Card",
//      assetImage: "add icon image to assets/images/myimage.png",
//      pay: myCustomPaymentFunction
//    ),
//  ),
].where((e) => e != null).toList();
