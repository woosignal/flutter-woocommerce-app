//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/pages/account_detail_page.dart';
import '/resources/pages/account_delete_page.dart';
import '/resources/pages/account_profile_update_page.dart';
import '/resources/pages/account_shipping_details_page.dart';
import '/app/events/logout_event.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AccountDetailSettingsWidget extends StatefulWidget {
  const AccountDetailSettingsWidget({super.key});

  @override
  State<AccountDetailSettingsWidget> createState() =>
      _AccountDetailSettingsWidgetState();
}

class _AccountDetailSettingsWidgetState
    extends NyState<AccountDetailSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(trans("Update details")),
              onTap: () =>
                  routeTo(AccountProfileUpdatePage.path, onPop: (value) {
                    StateAction.refreshPage(AccountDetailPage.path);
                  })),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text(trans("Billing/shipping details")),
            onTap: () => routeTo(AccountShippingDetailsPage.path),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.no_accounts_rounded),
            title: Text(trans("Delete Account")),
            onTap: () => routeTo(AccountDeletePage.path),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(trans("Logout")),
            onTap: () {
              confirmAction(() {
                event<LogoutEvent>();
              }, title: "Are you sure?".tr());
            },
          ),
        ),
      ],
    );
  }
}
