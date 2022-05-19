import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutPaymentTypeWidget extends StatelessWidget {
  const CheckoutPaymentTypeWidget(
      {Key? key,
      required this.context,
      required this.checkoutSession,
      this.resetState})
      : super(key: key);
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
    Navigator.pushNamed(context, "/checkout-payment-type")
        .then((value) => resetState!());
  }
}
