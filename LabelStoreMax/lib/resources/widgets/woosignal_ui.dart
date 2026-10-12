//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/helpers.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/tax_rate.dart';

class CheckoutRowLine extends StatelessWidget {
  const CheckoutRowLine(
      {super.key,
      required this.heading,
      required this.leadImage,
      required this.leadTitle,
      required this.action,
      this.showBorderBottom = true});

  final String heading;
  final String? leadTitle;
  final Widget leadImage;
  final Function() action;
  final bool showBorderBottom;

  @override
  Widget build(BuildContext context) => Container(
        height: 125,
        padding: EdgeInsets.all(8),
        decoration: showBorderBottom == true
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              )
            : BoxDecoration(),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  heading,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          leadImage,
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              margin: EdgeInsets.only(right: 10),
                              child: Text(
                                leadTitle!,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}

class TextEditingRow extends StatelessWidget {
  const TextEditingRow({
    super.key,
    this.heading,
    this.controller,
    this.shouldAutoFocus,
    this.keyboardType,
    this.obscureText,
  });

  final String? heading;
  final TextEditingController? controller;
  final bool? shouldAutoFocus;
  final TextInputType? keyboardType;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(2),
        height: heading == null ? 50 : 78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (heading != null)
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: AutoSizeText(
                    heading!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: context.color.general.content),
                  ),
                ),
              ),
            Flexible(
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.titleMedium,
                keyboardType: keyboardType ?? TextInputType.text,
                autocorrect: false,
                autofocus: shouldAutoFocus ?? false,
                obscureText: obscureText ?? false,
                textCapitalization: TextCapitalization.sentences,
              ),
            )
          ],
        ),
      );
}

class CheckoutMetaLine extends StatelessWidget {
  const CheckoutMetaLine({super.key, this.title, this.amount});

  final String? title, amount;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: AutoSizeText(title!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(
              flex: 3,
              child:
                  Text(amount!, style: Theme.of(context).textTheme.bodyLarge),
            )
          ],
        ),
      );
}

List<BoxShadow> wsBoxShadow({double? blurRadius}) => [
      BoxShadow(
        color: Color(0xFFE8E8E8),
        blurRadius: blurRadius ?? 15.0,
        spreadRadius: 0,
        offset: Offset(
          0,
          0,
        ),
      )
    ];

void wsModalBottom(BuildContext context,
    {String? title, Widget? bodyWidget, Widget? extraWidget}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (builder) {
      return SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.color.general.background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: context.color.general.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: bodyWidget,
                  ),
                ),
                ?extraWidget
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CheckoutTotal extends StatelessWidget {
  const CheckoutTotal({super.key, this.title, this.taxRate});

  final String? title;
  final TaxRate? taxRate;

  @override
  Widget build(BuildContext context) => FutureWidget<String>(
        future: CheckoutSession.getInstance
            .total(withFormat: true, taxRate: taxRate),
        child: (BuildContext context, data) => Padding(
          padding: EdgeInsets.only(bottom: 0, top: 15),
          child: CheckoutMetaLine(title: title, amount: data),
        ),
        loadingStyle: LoadingStyle.none(),
      );
}

class CheckoutTaxTotal extends StatelessWidget {
  const CheckoutTaxTotal({super.key, this.taxRate});

  final TaxRate? taxRate;

  @override
  Widget build(BuildContext context) => FutureWidget<String>(
        future: Cart.getInstance.taxAmount(taxRate),
        child: (BuildContext context, data) => (data == "0"
            ? Container()
            : Padding(
                padding: EdgeInsets.only(bottom: 0, top: 0),
                child: CheckoutMetaLine(
                  title: trans("Tax"),
                  amount: formatStringCurrency(total: data),
                ),
              )),
      );
}

class CheckoutSubtotal extends StatelessWidget {
  const CheckoutSubtotal({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) => FutureWidget<String>(
        future: Cart.getInstance.getSubtotal(withFormat: true),
        child: (BuildContext context, data) => Padding(
          padding: EdgeInsets.only(bottom: 0, top: 0),
          child: CheckoutMetaLine(
            title: title,
            amount: data,
          ),
        ),
        loadingStyle: LoadingStyle.none(),
      );
}
