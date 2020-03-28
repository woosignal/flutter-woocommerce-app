import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/payment_type.dart';
import 'package:label_storemax/providers/stripe_pay.dart';

// Payment methods available for uses in the app
// To use use a payment method, include the PaymentType "name" in the app_payment_methods variable in #labelconfig.dart

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

  // e.g. add more here

//  addPayment(
//    PaymentType(
//      id: 2,
//      name: "MyNewPaymentMethod",
//      desc: "Debit or Credit Card",
//      assetImage: "add icon image to assets/images/myimage.png",
//      pay: stripePay
//    ),
//  ),
];
