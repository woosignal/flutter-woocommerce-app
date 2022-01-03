import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';

class CheckoutStoreHeadingWidget extends StatelessWidget {
  const CheckoutStoreHeadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: (Theme.of(context).brightness == Brightness.light)
              ? wsBoxShadow(blurRadius: 10)
              : null,
          color: Colors.transparent,
        ),
        padding: EdgeInsets.all(2),
        margin: EdgeInsets.only(top: 16),
        child: ClipRRect(
          child: StoreLogo(height: 65),
          borderRadius: BorderRadius.circular(8),
        ));
  }
}
