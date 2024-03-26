//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/account_order_detail_page.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart';

class AccountDetailOrdersWidget extends StatefulWidget {
  @override
  createState() => _AccountDetailOrdersWidgetState();
}

class _AccountDetailOrdersWidgetState
    extends NyState<AccountDetailOrdersWidget> {
  @override
  bool get showInitialLoader => false;

  @override
  void boot() {}

  @override
  Widget view(BuildContext context) {
    return NyPullToRefresh(
        child: (context, order) {
          order as Order;
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 8,
                right: 6,
              ),
              title: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFFCFCFC),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "#${order.id.toString()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order.status!.capitalize(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formatStringCurrency(total: order.total),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${order.lineItems!.length} ${trans("items")}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      "${dateFormatted(
                        date: order.dateCreated!,
                        formatType: formatForDateTime(FormatType.date),
                      )}\n${dateFormatted(
                        date: order.dateCreated!,
                        formatType: formatForDateTime(FormatType.time),
                      )}",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _viewOrderDetail(order.id),
            ),
          );
        },
        data: (page) async {
          WpUser? wpUser = await WPJsonAPI.wpUser();
          return await appWooSignal((api) =>
              api.getOrders(customer: wpUser?.id, page: page, perPage: 50));
        },
        empty: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.shopping_cart,
                color: Colors.black54,
                size: 40,
              ),
              Text(
                trans("No orders found"),
              ),
            ],
          ),
        ),
        loading: Container(
          height: 200,
          width: double.infinity,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 8,
                    right: 6,
                  ),
                  title: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFFCFCFC),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Some Text",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Some Text",
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              formatStringCurrency(total: "Some Text"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "Some Text",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        Text(
                          "Some Text",
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        useSkeletonizer: true);
  }

  _viewOrderDetail(int? orderId) {
    routeTo(AccountOrderDetailPage.path, data: orderId);
  }
}
