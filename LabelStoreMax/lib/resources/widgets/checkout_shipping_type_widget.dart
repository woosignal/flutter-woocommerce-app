import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CheckoutShippingTypeWidget extends StatelessWidget {
  const CheckoutShippingTypeWidget(
      {Key key,
      @required this.context,
      @required this.wooSignalApp,
      @required this.checkoutSession,
      this.resetState})
      : super(key: key);

  final CheckoutSession checkoutSession;
  final BuildContext context;
  final Function resetState;
  final WooSignalApp wooSignalApp;

  @override
  Widget build(BuildContext context) {
    bool hasDisableShipping = wooSignalApp.disableShipping == 1;
    if (hasDisableShipping == true) {
      return SizedBox.shrink();
    }
    bool hasSelectedShippingType = checkoutSession.shippingType != null;
    return CheckoutRowLine(
      heading: trans(
          hasSelectedShippingType ? "Shipping selected" : "Select shipping"),
      leadImage: Icon(Icons.local_shipping),
      leadTitle: hasSelectedShippingType
          ? checkoutSession.shippingType.getTitle()
          : trans("Select a shipping option"),
      action: _actionSelectShipping,
      showBorderBottom: false,
    );
  }

  _actionSelectShipping() {
    CustomerAddress shippingAddress =
        checkoutSession.billingDetails.shippingAddress;
    if (shippingAddress == null || shippingAddress.customerCountry == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Add your shipping details first"),
        icon: Icons.local_shipping,
      );
      return;
    }
    Navigator.pushNamed(context, "/checkout-shipping-type")
        .then((value) => resetState());
  }
}
