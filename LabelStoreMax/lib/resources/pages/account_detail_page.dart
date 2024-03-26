//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import '/app/events/logout_event.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/account_detail_orders_widget.dart';
import '/resources/widgets/account_detail_settings_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountDetailPage extends StatefulWidget {
  static String path = "/account-detail";
  final bool showLeadingBackButton;
  const AccountDetailPage({this.showLeadingBackButton = true});
  @override
  createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends NyState<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;
  WCCustomerInfoResponse? _wcCustomerInfoResponse;

  @override
  init() async {
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  boot() async {
    await _fetchWpUserData();
  }

  _fetchWpUserData() async {
    WCCustomerInfoResponse? wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse =
          await WPJsonAPI.instance.api((request) => request.wcCustomerInfo());
    } on InvalidUserTokenException catch (_) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
      await event<LogoutEvent>();
    } on Exception catch (_) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
    }

    if (wcCustomerInfoResponse?.status != 200) {
      return;
    }
    _wcCustomerInfoResponse = wcCustomerInfoResponse;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showLeadingBackButton
            ? Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                margin: EdgeInsets.only(left: 0),
              )
            : Container(),
        title: Text(trans("Account")),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
          child: Column(
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
                      child: getAvatar(),
                      height: 90,
                      width: 90,
                    ),
                    Expanded(
                      child: Padding(
                        child: Text(
                          getFullName(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 16),
                      ),
                    ),
                  ],
                ),
                Padding(
                  child: TabBar(
                    tabs: [
                      Tab(text: trans("Orders")),
                      Tab(text: trans("Settings")),
                    ],
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    indicator: BubbleTabIndicator(
                      indicatorHeight: 30.0,
                      indicatorRadius: 5,
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
              boxShadow: (Theme.of(context).brightness == Brightness.light)
                  ? wsBoxShadow()
                  : null,
              color: ThemeColor.get(context).backgroundContainer,
            ),
          ),
          Expanded(
            child: NySwitch(
              widgets: [
                AccountDetailOrdersWidget(),
                AccountDetailSettingsWidget(),
              ],
              indexSelected: _currentTabIndex,
            ),
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  _tabsTapped(int i) {
    setState(() {
      _currentTabIndex = i;
    });
  }

  String getFullName() {
    return [
      _wcCustomerInfoResponse?.data?.firstName,
      _wcCustomerInfoResponse?.data?.lastName
    ].where((t) => (t != null || t != "")).toList().join(" ");
  }

  Widget getAvatar() {
    String? avatarUrl = _wcCustomerInfoResponse?.data?.avatar;
    if (avatarUrl == null) {
      return Icon(
        Icons.account_circle_rounded,
        size: 65,
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
    );
  }
}
