import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'dart:async';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  String payerId = '';
  int intCount = 0;
  StreamSubscription<String> _onUrlChanged;
  WooSignalApp _wooSignalApp = AppHelper.instance.appConfig;
  String formCheckoutShippingAddress;

  setCheckoutShippingAddress(CustomerAddress customerAddress) {
    String tmp = "";
    if (customerAddress.firstName != null) {
      tmp +=
          '<input type="hidden" name="first_name" value="${customerAddress.firstName.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.lastName != null) {
      tmp +=
          '<input type="hidden" name="last_name" value="${customerAddress.lastName.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.addressLine != null) {
      tmp +=
          '<input type="hidden" name="address1" value="${customerAddress.addressLine.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.city != null) {
      tmp +=
          '<input type="hidden" name="city" value="${customerAddress.city.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.customerCountry.hasState() &&
        customerAddress.customerCountry.state.name != null) {
      tmp +=
          '<input type="hidden" name="state" value="${customerAddress.customerCountry.state.name.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.postalCode != null) {
      tmp +=
          '<input type="hidden" name="zip" value="${customerAddress.postalCode.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    if (customerAddress.customerCountry.countryCode != null) {
      tmp +=
          '<input type="hidden" name="country" value="${customerAddress.customerCountry.countryCode.replaceAll(new RegExp(r'[^\d\w\s,\-+]+'),'')}">\n';
    }
    formCheckoutShippingAddress = tmp;
  }

  String getPayPalItemName() {
    return truncateString(widget.description.replaceAll(new RegExp(r'[^\w\s]+'),''), 124);
  }

  String getPayPalPaymentType() {
    return Platform.isAndroid ? "PayPal - Android App" : "PayPal - IOS App";
  }

  String getPayPalUrl() {
    bool liveMode = envVal('PAYPAL_LIVE_MODE', defaultValue: _wooSignalApp.paypalLiveMode);
    return liveMode == true
        ? "https://www.paypal.com/cgi-bin/webscr"
        : "https://www.sandbox.paypal.com/cgi-bin/webscr";
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    setCheckoutShippingAddress(
        CheckoutSession.getInstance.billingDetails.shippingAddress);
    setState(() {});
  }

  @override
  void dispose() {
    if (_onUrlChanged != null) {
      _onUrlChanged.cancel();
    }
    super.dispose();
  }

  String _loadHTML() {
    final String strProcessingPayment = trans(context, "Processing Payment");
    final String strPleaseWait = trans(context, "Please wait, your order is being processed and you will be redirected to the PayPal website.");
    final String strRedirectMessage = trans(context, "If you are not automatically redirected to PayPal within 5 seconds");

    return '''
      <html><head><title>$strProcessingPayment...</title></head>
<body onload="document.forms['paypal_form'].submit();">
<div style="text-align:center;">
<img src="https://woosignal.com/images/paypal_logo.png" height="50" />
</div>
<center><h4>$strPleaseWait</h4></center>
<form method="post" name="paypal_form" action="${getPayPalUrl()}">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="amount" value="${widget.amount}">
<input type="hidden" name="lc" value="${envVal('PAYPAL_LOCALE', defaultValue: _wooSignalApp.paypalLocale)}">
<input type="hidden" name="currency_code" value="${_wooSignalApp.currencyMeta.code}">
<input type="hidden" name="business" value="${envVal('PAYPAL_ACCOUNT_EMAIL', defaultValue: _wooSignalApp.paypalEmail)}">
<input type="hidden" name="return" value="https://woosignal.com/paypal/payment~success">
<input type="hidden" name="cancel_return" value="https://woosignal.com/paypal/payment~failure">
<input type="hidden" name="item_name" value="${getPayPalItemName()}">
<input type="hidden" name="custom" value="${getPayPalPaymentType()}">
<input type="hidden" name="address_override" value="1">
$formCheckoutShippingAddress
<center><br><br>$strRedirectMessage...<br><br>
<input type="submit" value="Click Here"></center>
</form></body></html>
'''.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: WebView(
          initialUrl: Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
          },
          navigationDelegate: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {
            if (intCount > 0) {
              url = url.replaceAll("~", "_");
            }

            intCount = intCount + 1;
            if (url.contains("payment_success")) {
              var uri = Uri.dataFromString(url);
              setState(() {
                payerId = uri.queryParameters['PayerID'];
              });
              Navigator.pop(context, {"status": payerId == null ? "cancelled" : "success", "payerId": payerId});
            } else if (url.contains("payment_failure")) {
              Navigator.pop(context, {"status": "cancelled"});
            }
          },
          gestureNavigationEnabled: false,
        ),
      ),
    );
  }
}
