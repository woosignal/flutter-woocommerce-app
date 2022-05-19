//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/checkout_status_controller.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart' as ws_order;
import '../widgets/woosignal_ui.dart';

class CheckoutStatusPage extends NyStatefulWidget {
  final CheckoutStatusController controller = CheckoutStatusController();
  CheckoutStatusPage({Key? key}) : super(key: key);

  @override
  _CheckoutStatusState createState() => _CheckoutStatusState();
}

class _CheckoutStatusState extends NyState<CheckoutStatusPage> {
  ws_order.Order? _order;

  @override
  init() async {
    _order = widget.controller.data();
    await Cart.getInstance.clear();
    CheckoutSession.getInstance.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: StoreLogo(height: 60),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          child: Text(
                            trans("Order Status"),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          padding: EdgeInsets.only(bottom: 15),
                        ),
                        Text(
                          trans("Thank You!"),
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          trans("Your transaction details"),
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${trans("Order Ref")}. #${_order!.id.toString()}",
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12, width: 1.0),
                        ),
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.white
                                : null),
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  Container(
                    child: Image.asset(
                      getImageAsset("camion.gif"),
                      height: 170,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    width: double.infinity,
                  ),
                ],
              ),
              Align(
                child: Padding(
                  child: Text(
                    trans("Items"),
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.left,
                  ),
                  padding: EdgeInsets.all(8),
                ),
                alignment: Alignment.center,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _order!.lineItems == null
                        ? 0
                        : _order!.lineItems!.length,
                    itemBuilder: (BuildContext context, int index) {
                      ws_order.LineItems lineItem = _order!.lineItems![index];
                      return Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(
                                      lineItem.name!,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      softWrap: false,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "x${lineItem.quantity.toString()}",
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatStringCurrency(
                                  total: lineItem.total.toString(),
                                ),
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          color:
                              (Theme.of(context).brightness == Brightness.light)
                                  ? Colors.white
                                  : null);
                    }),
              ),
              Align(
                child: LinkButton(
                  title: trans("Back to Home"),
                  action: () =>
                      Navigator.pushReplacementNamed(context, "/home"),
                ),
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
