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
import '/bootstrap/extensions.dart';
import '/bootstrap/wp_json_api_errors.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountDeletePage extends NyStatefulWidget {
  static RouteView path = ("/account-delete", (_) => AccountDeletePage());

  AccountDeletePage({super.key})
      : super(child: () => _AccountDeletePageState());
}

class _AccountDeletePageState extends NyPage<AccountDeletePage> {
  final TextEditingController _tfPassword = TextEditingController();

  @override
  void dispose() {
    _tfPassword.dispose();
    super.dispose();
  }

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
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 18),
                      child: Text(
                        trans("Enter your password to confirm"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // The store asks for the current password before it
                    // deletes an account (WP JSON API 5.0+).
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow:
                            (Theme.of(context).brightness == Brightness.light)
                                ? wsBoxShadow()
                                : null,
                        color: context.color.container.background,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: TextEditingRow(
                        heading: trans("Password"),
                        controller: _tfPassword,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ),
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
    String password = _tfPassword.text;
    if (password.isEmpty) {
      showToast(
        title: trans("Oops!"),
        description: trans("Enter your password to confirm"),
        id: 'warning',
      );
      return;
    }

    await lockRelease('delete_account', perform: () async {
      WPUserDeleteResponse? wpUserDeleteResponse;
      try {
        wpUserDeleteResponse = await WPJsonAPI.instance
            .api((request) => request.wpUserDelete(password: password));
      } on Exception catch (e) {
        await showWpJsonApiError(e);
        return;
      }

      if (wpUserDeleteResponse != null) {
        _tfPassword.clear();
        showToast(
            title: trans("Success"), description: trans("Account deleted"));
        // wpUserDelete has already cleared the session on this device.
        await event<LogoutEvent>();
      }
    });
  }
}
