//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
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

class AccountDetailPage extends NyStatefulWidget {
  static RouteView path = ("/account-detail", (_) => AccountDetailPage());

  AccountDetailPage({super.key, this.showLeadingBackButton = true})
      : super(child: () => _AccountDetailPageState());
  final bool showLeadingBackButton;
}

class _AccountDetailPageState extends NyPage<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;
  WCCustomerInfoResponse? _wcCustomerInfoResponse;

  @override
  get init => () async {
        _tabController = TabController(vsync: this, length: 2);
        await _fetchWpUserData();
      };

  _fetchWpUserData() async {
    WCCustomerInfoResponse? wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse =
          await WPJsonAPI.instance.api((request) => request.wcCustomerInfo());
    } on InvalidUserTokenException catch (_) {
      showToast(
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.danger,
      );
      await event<LogoutEvent>();
    } on Exception catch (_) {
      showToast(
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.danger,
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
                margin: EdgeInsets.only(left: 0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: (Theme.of(context).brightness == Brightness.light)
                  ? wsBoxShadow()
                  : null,
              color: ThemeColor.get(context).backgroundContainer,
            ),
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
                      height: 90,
                      width: 90,
                      child: getAvatar(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          getFullName(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    tabs: [
                      Tab(text: trans("Orders")),
                      Tab(text: trans("Settings")),
                    ],
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    dividerHeight: 0,
                    indicator: BubbleTabIndicator(
                      indicatorHeight: 30.0,
                      indicatorRadius: 5,
                      indicatorColor: Colors.black87,
                      tabBarIndicatorSize: TabBarIndicatorSize.tab,
                    ),
                    onTap: _tabsTapped,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                AccountDetailOrdersWidget(),
                AccountDetailSettingsWidget(),
              ],
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

    return CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl!),
    );
  }
}
