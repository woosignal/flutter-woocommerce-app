import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutUserDetailsWidget extends StatelessWidget {
  const CheckoutUserDetailsWidget(
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
    bool hasUserCheckoutInfo = (checkoutSession.billingDetails != null &&
        checkoutSession.billingDetails!.billingAddress != null);
    return CheckoutRowLine(
      heading: trans("Billing/shipping details"),
      leadImage: Icon(Icons.home),
      leadTitle: hasUserCheckoutInfo
          ? (checkoutSession.billingDetails == null ||
          (checkoutSession.billingDetails?.billingAddress?.hasMissingFields() ?? true)
              ? trans("Billing address is incomplete")
              : checkoutSession.billingDetails!.billingAddress?.addressFull())
          : trans("Add billing & shipping details"),
      action: _actionCheckoutDetails,
      showBorderBottom: true,
    );
  }

  _actionCheckoutDetails() {
    Navigator.pushNamed(context, "/checkout-details").then((e) {
      resetState!();
    });
  }
}
