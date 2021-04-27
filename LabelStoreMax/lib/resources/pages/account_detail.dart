//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountDetailPage extends StatefulWidget {
  final bool showLeadingBackButton;
  const AccountDetailPage({this.showLeadingBackButton = true});
  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _shouldStopRequests = false,
      waitForNextRequest = false,
      _isLoading = true,
      _isLoadingOrders = true;

  int _page = 1, _currentTabIndex = 0;
  List<Order> _orders = [];
  WCCustomerInfoResponse _wcCustomerInfoResponse;
  Widget _activeBody;

  TabController _tabController;
  List<Tab> _tabs = [];

  @override
  void initState() {
    super.initState();
    _page = 1;
    _orders = [];
    _tabs = [
      new Tab(text: ""),
      new Tab(text: ""),
    ];
    _tabController = TabController(vsync: this, length: _tabs.length);
    _activeBody = AppLoaderWidget();
    this.init();
  }

  init() async {
    await _fetchWpUserData();
    await _fetchOrders();
  }

  _fetchWpUserData() async {
    String userToken = await readAuthToken();

    WCCustomerInfoResponse wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wcCustomerInfo(userToken));
    } on Exception catch (_) {
      showToastNotification(
        context,
        title: trans(context, "Oops!"),
        description: trans(context, "Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (wcCustomerInfoResponse != null &&
        wcCustomerInfoResponse.status == 200) {
      setState(() {
        _wcCustomerInfoResponse = wcCustomerInfoResponse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _tabs = [
      new Tab(text: trans(context, "Orders")),
      new Tab(text: trans(context, "Settings")),
    ];
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: widget.showLeadingBackButton ? Container(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          margin: EdgeInsets.only(left: 0),
        ) : Container(),
        title: Text(
          trans(context, "Account"),
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
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  _wcCustomerInfoResponse != null
                                      ? _wcCustomerInfoResponse.data.avatar
                                      : "",
                                ),
                              ),
                              height: 90,
                              width: 90,
                            ),
                            Expanded(
                              child: Padding(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Text(
                                          (_wcCustomerInfoResponse == null
                                              ? ""
                                              : [
                                                  _wcCustomerInfoResponse
                                                      .data.firstName,
                                                  _wcCustomerInfoResponse
                                                      .data.lastName
                                                ]
                                                  .where((t) =>
                                                      (t != null || t != ""))
                                                  .toList()
                                                  .join(" ")),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.only(left: 16),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          child: TabBar(
                            tabs: _tabs,
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black87,
                            indicator: new BubbleTabIndicator(
                              indicatorHeight: 25.0,
                              indicatorColor: Colors.black87,
                              tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            ),
                            onTap: _tabsTapped,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: adaptiveTheme.isLight ? wsBoxShadow() : null,
                      color:
                          adaptiveTheme.isLight ? Colors.white : Colors.white70,
                    ),
                  ),
                  Expanded(child: _activeBody),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _tabsTapped(int i) {
    _currentTabIndex = i;
    setState(() {
      if (_currentTabIndex == 0) {
        _activeBody = _widgetOrders();
      } else {
        _activeBody = _widgetSettings();
      }
    });
  }

  ListView _widgetSettings() {
    return ListView(
      children: <Widget>[
        Card(
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(trans(context, "Update details")),
            onTap: () =>
                Navigator.pushNamed(context, "/account-update").then((onValue) {
              setState(() {
                _isLoading = true;
              });
              _fetchWpUserData();
            }),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text(trans(context, "Shipping Details")),
            onTap: () =>
                Navigator.pushNamed(context, "/account-shipping-details"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.credit_card),
            title: Text(trans(context, "Billing Details")),
            onTap: () =>
                Navigator.pushNamed(context, "/account-billing-details"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(trans(context, "Logout")),
            onTap: () => authLogout(context),
          ),
        ),
      ],
    );
  }

  _fetchOrders() async {
    String userId = await readUserId();

    if (userId == null || _shouldStopRequests == true) {
      setState(() {
        _isLoadingOrders = false;
        _activeBody = _widgetOrders();
      });
      return;
    }

    List<Order> orders = await appWooSignal((api) =>
        api.getOrders(customer: int.parse(userId), page: _page, perPage: 50));

    if (orders.length <= 0) {
      setState(() {
        _isLoadingOrders = false;
        _shouldStopRequests = true;
        _activeBody = _widgetOrders();
      });
      return;
    }

    setState(() {
      _page += 1;
      _orders.addAll(orders);
      _isLoadingOrders = false;
      _activeBody = _widgetOrders();
    });
  }

  Widget _widgetOrders() {
    return _isLoadingOrders
        ? AppLoaderWidget()
        : SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text(trans(context, "pull up load"));
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text(trans(context, "Load Failed! Click retry!"));
                } else if (mode == LoadStatus.canLoading) {
                  body = Text(trans(context, "release to load more"));
                } else {
                  body = Text(trans(context, "No more orders"));
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
            child: (_orders.length > 0
                ? ListView.builder(
                    itemBuilder: (cxt, i) {
                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.only(
                              top: 5, bottom: 5, left: 8, right: 6),
                          title: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: HexColor("#fcfcfc"),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "#${_orders[i].id.toString()}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _orders[i].status.capitalize(),
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
                                      formatStringCurrency(
                                          total: _orders[i].total),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      _orders[i].lineItems.length.toString() +
                                          " " +
                                          trans(context, "items"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                Text(
                                  dateFormatted(
                                        date: _orders[i].dateCreated,
                                        formatType:
                                            formatForDateTime(FormatType.Date),
                                      ) +
                                      "\n" +
                                      dateFormatted(
                                        date: _orders[i].dateCreated,
                                        formatType:
                                            formatForDateTime(FormatType.Time),
                                      ),
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
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
                          onTap: () => _viewProfileDetail(i),
                        ),
                      );
                    },
                    itemCount: _orders.length,
                  )
                : Center(
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
                          trans(context, "No orders found"),
                        ),
                      ],
                    ),
                  )),
          );
  }

  void _onRefresh() async {
    _orders = [];
    _page = 1;
    _shouldStopRequests = false;
    waitForNextRequest = false;
    await _fetchOrders();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await _fetchOrders();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _viewProfileDetail(int i) => Navigator.pushNamed(
        context,
        "/account-order-detail",
        arguments: _orders[i].id,
      );
}
