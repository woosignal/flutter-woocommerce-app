import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutCouponAmountWidget extends StatelessWidget {
  const CheckoutCouponAmountWidget({Key key, @required this.checkoutSession})
      : super(key: key);

  final CheckoutSession checkoutSession;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Cart.getInstance.couponDiscountAmount(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return AppLoaderWidget();
          default:
            if (snapshot.hasError) {
              return Text("");
            } else {
              if (checkoutSession.coupon == null) {
                return SizedBox.shrink();
              }
              return Padding(
                child: CheckoutMetaLine(
                  title: "${trans('Coupon')}: ${checkoutSession.coupon.code}",
                  amount: "-" + formatStringCurrency(total: snapshot.data),
                ),
                padding: EdgeInsets.only(bottom: 0, top: 0),
              );
            }
        }
      },
    );
  }
}
