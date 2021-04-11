import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/providers/cash_on_delivery.dart';
import 'package:flutter_app/app/providers/paypal_pay.dart';
import 'package:flutter_app/app/providers/razor_pay.dart';
import 'package:flutter_app/app/providers/stripe_pay.dart';
import 'package:flutter_app/bootstrap/helpers.dart';

/*
|--------------------------------------------------------------------------
| PAYMENT GATEWAYS
|
| Configure which payment gateways you want to use.
| Docs here: https://woosignal.com/docs/app/ios/label-storemax
|--------------------------------------------------------------------------
*/

const app_payment_gateways = ["Stripe", "CashOnDelivery", "PayPal"];
// Available: "Stripe", "CashOnDelivery", "RazorPay"
// e.g. app_payment_gateways = ["Stripe", "CashOnDelivery"]; will only use Stripe and Cash on Delivery.

List<PaymentType> paymentTypeList = [
  addPayment(
    id: 1,
    name: "Stripe",
    desc: "Debit or Credit Card",
    assetImage: "dark_powered_by_stripe.png",
    pay: stripePay,
  ),

  addPayment(
    id: 2,
    name: "CashOnDelivery",
    desc: "Cash on delivery",
    assetImage: "cash_on_delivery.jpeg",
    pay: cashOnDeliveryPay,
  ),

  addPayment(
    id: 3,
    name: "RazorPay",
    desc: "Debit or Credit Card",
    assetImage: "razorpay.png",
    pay: razorPay,
  ),

  addPayment(
    id: 4,
    name: "PayPal",
    desc: "Debit or Credit Card",
    assetImage: "paypal_logo.png",
    pay: payPalPay,
  ),

  // e.g. add more here

  // addPayment(
  //   id: 5,
  //   name: "MyNewPaymentMethod",
  //   desc: "Debit or Credit Card",
  //   assetImage: "add icon image to public/assets/images/myimage.png",
  //   pay: "myCustomPaymentFunction",
  // ),
];
