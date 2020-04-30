//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';

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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(trans(context, "Payment Method"),
            style: Theme.of(context).primaryTextTheme.subhead),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/credit_cards.png"),
                        fit: BoxFit.fitHeight,
                        height: 100),
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
                          child: ListView.builder(
                              itemCount: getPaymentTypes().length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  contentPadding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8, right: 8),
                                  leading: Image(
                                      image: AssetImage("assets/images/" +
                                          getPaymentTypes()[index].assetImage),
                                      width: 60,
                                      fit: BoxFit.fitHeight,
                                      alignment: Alignment.center),
                                  title: Text(getPaymentTypes()[index].desc,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subhead),
                                  selected: true,
                                  trailing: (CheckoutSession
                                              .getInstance.paymentType ==
                                          getPaymentTypes()[index]
                                      ? Icon(Icons.check)
                                      : null),
                                  onTap: () {
                                    CheckoutSession.getInstance.paymentType =
                                        getPaymentTypes()[index];
                                    Navigator.pop(context);
                                  },
                                );
                              }),
                        ),
                        wsLinkButton(context, title: trans(context, "CANCEL"),
                            action: () {
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: wsBoxShadow(),
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
