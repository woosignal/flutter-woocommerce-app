//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/account_order_detail_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:nylo_framework/widgets/ny_state.dart';
import 'package:nylo_framework/widgets/stateful_page_widget.dart';
import 'package:woosignal/models/response/order.dart';

class AccountOrderDetailPage extends StatefulPageWidget {
  final AccountOrderDetailController controller =
      AccountOrderDetailController();
  AccountOrderDetailPage({Key key}) : super(key: key);

  @override
  _AccountOrderDetailPageState createState() => _AccountOrderDetailPageState();
}

class _AccountOrderDetailPageState extends NyState<AccountOrderDetailPage> {
  int _orderId;
  Order _order;
  bool _isLoading = true;

  @override
  widgetDidLoad() async {
    super.widgetDidLoad();
    _orderId = widget.controller.data();
    await _fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveThemeMode = AdaptiveTheme.of(context).mode;
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
          "${trans(context, "Order").capitalize()} #${_orderId.toString()}",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? AppLoaderWidget()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("${trans(context, "Date Ordered").capitalize()}: " +
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
                              "${trans(context, "Ships to").capitalize()}:"),
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
                      boxShadow:
                          adaptiveThemeMode.isLight ? wsBoxShadow() : null,
                      color: adaptiveThemeMode.isLight
                          ? Colors.white
                          : Color(0xFF2C2C2C),
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
                                    formatStringCurrency(
                                            total: _order.lineItems[i].price)
                                        .capitalize(),
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
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "x${_order.lineItems[i].quantity.toString()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
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
