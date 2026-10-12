//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/events/logout_event.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountDeletePage extends NyStatefulWidget {
  static RouteView path = ("/account-delete", (_) => AccountDeletePage());

  AccountDeletePage({super.key})
      : super(child: () => _AccountDeletePageState());
}

class _AccountDeletePageState extends NyPage<AccountDeletePage> {
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trans("Delete Account")),
      ),
      body: SafeAreaWidget(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_accounts_rounded, size: 50),
                Text(
                  trans("Delete your account"),
                  style: textTheme.displaySmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(trans("Are you sure?")),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Button.primary(
                text: trans("Yes, delete my account"),
                onPressed: _deleteAccount),
              Button.textOnly(text: trans("Back"), onPressed: pop)
            ],
          )
        ],
      )),
    );
  }

  Future<void> _deleteAccount() async {
    await lockRelease('delete_account', perform: () async {
      WPUserDeleteResponse? wpUserDeleteResponse;
      try {
        wpUserDeleteResponse =
            await WPJsonAPI.instance.api((request) => request.wpUserDelete());
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        showToast(
          title: trans("Oops!"),
          description: trans("Something went wrong"),
          id: 'danger',
        );
      }

      if (wpUserDeleteResponse != null) {
        showToast(
            title: trans("Success"), description: trans("Account deleted"));
        await event<LogoutEvent>();
      }
    });
  }
}
