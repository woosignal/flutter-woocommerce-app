import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutSelectCouponWidget extends StatelessWidget {
  const CheckoutSelectCouponWidget(
      {Key key,
      @required this.context,
      @required this.checkoutSession,
      @required this.resetState})
      : super(key: key);

  final CheckoutSession checkoutSession;
  final BuildContext context;
  final Function resetState;

  @override
  Widget build(BuildContext context) {
    bool hasCoupon = checkoutSession.coupon != null;
    return InkWell(
      onTap: _actionCoupon,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasCoupon == true
                ? IconButton(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    onPressed: _clearCoupon,
                    icon: Icon(
                      Icons.close,
                      size: 19,
                    ))
                : null,
            Text(
              hasCoupon
                  ? "Coupon Applied: " + checkoutSession.coupon.code
                  : trans('Apply Coupon'),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ].where((element) => element != null).toList(),
        ),
      ),
    );
  }

  _clearCoupon() {
    CheckoutSession.getInstance.coupon = null;
    resetState();
  }

  _actionCoupon() {
    if (checkoutSession.billingDetails.billingAddress == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description:
            trans("Please select add your billing/shipping address to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );

      return;
    }
    if (checkoutSession.billingDetails.billingAddress.hasMissingFields()) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Your billing/shipping details are incomplete"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }
    Navigator.pushNamed(context, "/checkout-coupons")
        .then((value) => resetState());
  }
}
