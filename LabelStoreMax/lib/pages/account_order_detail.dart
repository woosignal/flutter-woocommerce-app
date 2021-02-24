//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:woosignal/models/response/order.dart';

class AccountOrderDetailPage extends StatefulWidget {
  final int orderId;

  AccountOrderDetailPage({Key key, this.orderId}) : super(key: key);

  @override
  _AccountOrderDetailPageState createState() =>
      _AccountOrderDetailPageState(this.orderId);
}

class _AccountOrderDetailPageState extends State<AccountOrderDetailPage> {
  _AccountOrderDetailPageState(this._orderId);

  int _orderId;
  Order _order;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          margin: EdgeInsets.only(left: 0),
        ),
        title: Text(
          "${capitalize(trans(context, "Order"))} #${_orderId.toString()}",
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? showAppLoader()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("${capitalize(trans(context, "Date Ordered"))}: " +
                      dateFormatted(
                          date: _order.dateCreated,
                          formatType: formatForDateTime(FormatType.Date))),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                              "${capitalize(trans(context, "Ships to"))}:"),
                        ),
                        Flexible(
                          child: Text(
                            [
                              [
                                _order.shipping.firstName,
                                _order.shipping.lastName
                              ].where((t) => t != null).toList().join(" "),
                              _order.shipping.address1,
                              _order.shipping.address2,
                              _order.shipping.city,
                              _order.shipping.state,
                              _order.shipping.postcode,
                              _order.shipping.country,
                            ]
                                .where((t) => (t != "" && t != null))
                                .toList()
                                .join("\n"),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: wsBoxShadow(),
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (cxt, i) {
                        return Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 8, right: 6),
                            title: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: HexColor("#fcfcfc"), width: 1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      _order.lineItems[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    capitalize(
                                      formatStringCurrency(
                                          total: _order.lineItems[i].price),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        formatStringCurrency(
                                          total: _order.lineItems[i].total,
                                        ),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "x" +
                                            _order.lineItems[i].quantity
                                                .toString(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText1
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _order.lineItems.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _fetchOrder() async {
    _order = await appWooSignal((api) {
      return api.retrieveOrder(_orderId);
    });
    if (_order != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
