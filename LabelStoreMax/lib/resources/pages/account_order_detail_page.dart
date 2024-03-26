//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart';

class AccountOrderDetailPage extends NyStatefulWidget {
  static String path = "/account-order-detail";

  AccountOrderDetailPage({Key? key})
      : super(path, key: key, child: _AccountOrderDetailPageState());
}

class _AccountOrderDetailPageState extends NyState<AccountOrderDetailPage> {
  int? _orderId;
  Order? _order;

  @override
  boot() async {
    _orderId = widget.controller.data();
    await _fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          margin: EdgeInsets.only(left: 0),
        ),
        title: afterNotNull(_orderId,
            child: () =>
                Text("${trans("Order").capitalize()} #${_orderId.toString()}"),
            loading: CupertinoActivityIndicator()),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: afterLoad(
          child: () => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${trans("Date Ordered").capitalize()}: ${dateFormatted(
                        date: _order?.dateCreated ?? "",
                        formatType: formatForDateTime(FormatType.date),
                      )}",
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match(
                            _order?.status,
                            () => {
                                  "completed": Colors.green,
                                  "processing": Colors.orange,
                                  "cancelled": Colors.red,
                                  "refunded": Colors.red,
                                  "failed": Colors.red,
                                  "on-hold": Colors.orange,
                                  "pending": Colors.orange,
                                },
                            defaultValue: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (_order?.status ?? "").capitalize(),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ).paddingSymmetric(horizontal: 16),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text("${trans("Ships to").capitalize()}:"),
                    ),
                    Flexible(
                      child: Text(
                        [
                          [
                            _order?.shipping?.firstName,
                            _order?.shipping?.lastName
                          ].where((t) => t != null).toList().join(" "),
                          _order?.shipping?.address1,
                          _order?.shipping?.address2,
                          _order?.shipping?.city,
                          _order?.shipping?.state,
                          _order?.shipping?.postcode,
                          _order?.shipping?.country,
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
                  boxShadow: (Theme.of(context).brightness == Brightness.light)
                      ? wsBoxShadow()
                      : null,
                  color: (Theme.of(context).brightness == Brightness.light)
                      ? Colors.white
                      : Color(0xFF2C2C2C),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (cxt, i) {
                    LineItems lineItem = _order!.lineItems![i];
                    return Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.only(
                            top: 5, bottom: 5, left: 8, right: 6),
                        title: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFFCFCFC), width: 1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  lineItem.name!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: 70,
                                alignment: Alignment.topRight,
                                child: Text(
                                  formatStringCurrency(total: lineItem.total)
                                      .capitalize(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.grey[100]!))),
                          padding: const EdgeInsets.only(top: 10),
                          margin: EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    formatStringCurrency(
                                      total: lineItem.price,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    "x ${lineItem.quantity.toString()}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                  itemCount: _order?.lineItems?.length ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fetchOrder() async {
    _order = await (appWooSignal((api) => api.retrieveOrder(_orderId!)));
  }
}
