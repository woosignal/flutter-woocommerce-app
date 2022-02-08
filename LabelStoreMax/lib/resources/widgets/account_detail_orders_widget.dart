//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/customer_orders_loader_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/order.dart';

class AccountDetailOrdersWidget extends StatefulWidget {
  @override
  _AccountDetailOrdersWidgetState createState() =>
      _AccountDetailOrdersWidgetState();
}

class _AccountDetailOrdersWidgetState extends State<AccountDetailOrdersWidget> {
  bool _isLoadingOrders = true, _shouldStopRequests = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final CustomerOrdersLoaderController _customerOrdersLoaderController =
      CustomerOrdersLoaderController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    List<Order> orders = _customerOrdersLoaderController.getResults();

    if (_isLoadingOrders == true) {
      return AppLoaderWidget();
    }

    if (orders.isEmpty) {
      return Center(
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
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(trans("pull up load"));
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(trans("Load Failed! Click retry!"));
          } else if (mode == LoadStatus.canLoading) {
            body = Text(trans("release to load more"));
          } else {
            body = Text(trans("No more orders"));
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (context, i) {
          Order order = orders[i];
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
                      order.status.capitalize(),
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
                              .bodyText2
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          order.lineItems.length.toString() +
                              " " +
                              trans("items"),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      dateFormatted(
                            date: order.dateCreated,
                            formatType: formatForDateTime(FormatType.date),
                          ) +
                          "\n" +
                          dateFormatted(
                            date: order.dateCreated,
                            formatType: formatForDateTime(FormatType.time),
                          ),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
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
              onTap: () => _viewOrderDetail(i, order.id),
            ),
          );
        },
        itemCount: orders.length,
      ),
    );
  }

  void _onRefresh() async {
    _customerOrdersLoaderController.clear();
    await fetchOrders();

    setState(() {
      _shouldStopRequests = false;
      _refreshController.refreshCompleted(resetFooterState: true);
    });
  }

  void _onLoading() async {
    await fetchOrders();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  fetchOrders() async {
    String userId = await readUserId();
    if (userId == null) {
      setState(() {
        _isLoadingOrders = false;
      });
      return;
    }
    await _customerOrdersLoaderController.loadOrders(
        hasResults: (result) {
          if (result == false) {
            setState(() {
              _isLoadingOrders = false;
              _shouldStopRequests = true;
            });
            return false;
          }
          return true;
        },
        didFinish: () => setState(() {
              _isLoadingOrders = false;
            }),
        userId: userId);
  }

  _viewOrderDetail(int i, int orderId) => Navigator.pushNamed(
        context,
        "/account-order-detail",
        arguments: orderId,
      );
}
