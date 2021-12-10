//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.


import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:nylo_support/helpers/helper.dart';

class CheckoutPaymentTypePage extends StatefulWidget {
  CheckoutPaymentTypePage();

  @override
  _CheckoutPaymentTypePageState createState() =>
      _CheckoutPaymentTypePageState();
}

class _CheckoutPaymentTypePageState extends State<CheckoutPaymentTypePage> {
  _CheckoutPaymentTypePageState();

  @override
  void initState() {
    super.initState();

    if (CheckoutSession.getInstance.paymentType == null) {
      if (getPaymentTypes() != null && getPaymentTypes().length > 0) {
        CheckoutSession.getInstance.paymentType = getPaymentTypes().first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<PaymentType> paymentTypes = getPaymentTypes();
    if (paymentTypes.length == 0 && getEnv('APP_DEBUG', defaultValue: false) == true) {
      NyLogger.info('You have no payment methods set. Visit the WooSignal dashboard (https://woosignal.com/dashboard) to set a payment method.');
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Payment Method")
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image.asset(getImageAsset("credit_cards.png"),
                        fit: BoxFit.fitHeight, height: 100),
                  ),
                  padding: EdgeInsets.only(top: 20),
                ),
                SizedBox(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: paymentTypes.length == 0 ? Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(trans("No payment methods are available"), style: Theme.of(context).textTheme.bodyText1,),
                          ) : ListView.separated(
                            itemCount: paymentTypes.length,
                            itemBuilder: (BuildContext context, int index) {
                              PaymentType paymentType =
                                  paymentTypes[index];
                              return ListTile(
                                contentPadding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: 8,
                                  right: 8,
                                ),
                                leading: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Image.asset(
                                      getImageAsset(paymentType.assetImage),
                                      width: 60,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                  ),
                                ),
                                title: Text(paymentType.desc,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                selected: true,
                                trailing:
                                    (CheckoutSession.getInstance.paymentType ==
                                            paymentType
                                        ? Icon(Icons.check)
                                        : null),
                                onTap: () {
                                  CheckoutSession.getInstance.paymentType =
                                      paymentType;
                                  Navigator.pop(context);
                                },
                              );
                            },
                            separatorBuilder: (cxt, i) => Divider(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                        LinkButton(
                          title: trans("CANCEL"),
                          action: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context).backgroundContainer,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                      (Theme.of(context).brightness == Brightness.light) ? wsBoxShadow() : null,
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
