import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:nylo_framework/widgets/ny_state.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class PayPalCheckout extends StatefulWidget {
  final String description;
  final String amount;
  final List<CartLineItem> cartLineItems;

  PayPalCheckout({this.description, this.amount, this.cartLineItems});

  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends NyState<PayPalCheckout> {
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  String payerId = '';
  int intCount = 0;
  StreamSubscription<String> _onUrlChanged;
  WooSignalApp _wooSignalApp = AppHelper.instance.appConfig;
  String formCheckoutShippingAddress;

  setCheckoutShippingAddress(CustomerAddress customerAddress) {
    String tmp = "";
    if (customerAddress.firstName != null) {
      tmp +=
          '<input type="hidden" name="first_name" value="${customerAddress.firstName}">\n';
    }
    if (customerAddress.lastName != null) {
      tmp +=
          '<input type="hidden" name="last_name" value="${customerAddress.lastName}">\n';
    }
    if (customerAddress.addressLine != null) {
      tmp +=
          '<input type="hidden" name="address1" value="${customerAddress.addressLine}">\n';
    }
    if (customerAddress.city != null) {
      tmp +=
          '<input type="hidden" name="city" value="${customerAddress.city}">\n';
    }
    if (customerAddress.customerCountry.hasState() &&
        customerAddress.customerCountry.state.name != null) {
      tmp +=
          '<input type="hidden" name="state" value="${customerAddress.customerCountry.state.name}">\n';
    }
    if (customerAddress.postalCode != null) {
      tmp +=
          '<input type="hidden" name="zip" value="${customerAddress.postalCode}">\n';
    }
    if (customerAddress.customerCountry.countryCode != null) {
      tmp +=
          '<input type="hidden" name="country" value="${customerAddress.customerCountry.countryCode}">\n';
    }
    formCheckoutShippingAddress = tmp;
  }

  String getPayPalItemName() {
    return truncateString(widget.description, 124);
  }

  String getPayPalPaymentType() {
    return Platform.isAndroid ? "PayPal - Android App" : "PayPal - IOS App";
  }

  String getPayPalUrl() {
    bool liveMode = getEnv('PAYPAL_LIVE_MODE', defaultValue: false);
    return liveMode == true
        ? "https://www.paypal.com/cgi-bin/webscr"
        : "https://www.sandbox.paypal.com/cgi-bin/webscr";
  }

  @override
  void initState() {
    super.initState();
    setCheckoutShippingAddress(
        CheckoutSession.getInstance.billingDetails.shippingAddress);

    setState(() {});

    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (intCount > 0) {
        url = url.replaceAll("~", "_");
      }

      intCount = intCount + 1;
      if (url.contains("payment_success")) {
        var uri = Uri.dataFromString(url);
        setState(() {
          payerId = uri.queryParameters['PayerID'];
        });
        Navigator.pop(context, {"status": "success", "payerId": payerId});
      } else if (url.contains("payment_failure")) {
        Navigator.pop(context, {"status": "cancelled"});
      }
    });
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  String _loadHTML() {
    return '''
      <html><head><title>${trans(context, "Processing Payment")}...</title></head>
<body onload="document.forms['paypal_form'].submit();">
<div style="text-align:center;">
<img src="https://woosignal.com/images/paypal_logo.png" height="50" />
</div>
<center><h4>${trans(context, "Please wait, your order is being processed and you will be redirected to the PayPal website.")}</h4></center>
<form method="post" name="paypal_form" action="${getPayPalUrl()}">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="amount" value="${widget.amount}">
<input type="hidden" name="currency_code" value="${_wooSignalApp.currencyMeta.code}">
<input type="hidden" name="business" value="${getEnv('PAYPAL_ACCOUNT_EMAIL')}">
<input type="hidden" name="return" value="https://woosignal.com/paypal/payment~success">
<input type="hidden" name="cancel_return" value="https://woosignal.com/paypal/payment~failure">
<input type="hidden" name="item_name" value="${getPayPalItemName()}">
<input type="hidden" name="custom" value="${getPayPalPaymentType()}">
<input type="hidden" name="address_override" value="1">
$formCheckoutShippingAddress
<center><br><br>${trans(context, "If you are not automatically redirected to PayPal within 5 seconds")}...<br><br>
<input type="submit" value="Click Here"></center>
</form></body></html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString(),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          trans(context, "PayPal Checkout"),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
