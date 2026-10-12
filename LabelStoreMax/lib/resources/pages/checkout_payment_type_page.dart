//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/checkout_session.dart';
import '/app/models/payment_type.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutPaymentTypePage extends NyStatefulWidget {
  static RouteView path =
      ("/checkout-payment-type", (_) => CheckoutPaymentTypePage());

  CheckoutPaymentTypePage({super.key})
      : super(child: () => _CheckoutPaymentTypePageState());
}

class _CheckoutPaymentTypePageState extends NyPage<CheckoutPaymentTypePage> {
  List<PaymentType?> _paymentTypes = [];

  @override
  get init => () async {
        _paymentTypes = await getPaymentTypes();

        if (_paymentTypes.isEmpty &&
            getEnv('APP_DEBUG', defaultValue: false) == true) {
          NyLogger.info(
              'You have no payment methods set. Visit the WooSignal dashboard (https://woosignal.com/dashboard) to set a payment method.');
        }

        if (CheckoutSession.getInstance.paymentType == null) {
          if (_paymentTypes.isNotEmpty) {
            CheckoutSession.getInstance.paymentType = _paymentTypes.firstWhere(
                (paymentType) => paymentType?.id == 20,
                orElse: () => _paymentTypes.first);
          }
        }
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Payment Method")),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Image.asset(getImageAsset("credit_cards.png"),
                        fit: BoxFit.fitHeight, height: 100),
                  ),
                ),
                SizedBox(
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.color.container.background,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: _paymentTypes.isEmpty
                              ? Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    trans("No payment methods are available"),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _paymentTypes.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    PaymentType paymentType =
                                        _paymentTypes[index]!;

                                    return ListTile(
                                      contentPadding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 8,
                                        right: 8,
                                      ),
                                      leading: Container(
                                        decoration:
                                            BoxDecoration(color: Colors.white),
                                        padding: EdgeInsets.all(4),
                                        child: Image.asset(
                                          getImageAsset(paymentType.assetImage),
                                          width: 60,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      title: Text(paymentType.desc,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      selected: true,
                                      trailing: (CheckoutSession.getInstance
                                                  .paymentType?.id ==
                                              paymentType.id
                                          ? Icon(Icons.check)
                                          : null),
                                      onTap: () {
                                        CheckoutSession.getInstance
                                            .paymentType = paymentType;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  separatorBuilder: (cxt, i) => Divider(
                                    color: Colors.black12,
                                  ),
                                ),
                        ),
                        Button.textOnly(
                          text: trans("CANCEL"),
                          onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
