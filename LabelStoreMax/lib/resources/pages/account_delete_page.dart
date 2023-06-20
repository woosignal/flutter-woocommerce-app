//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountDeletePage extends StatefulWidget {
  AccountDeletePage({Key? key}) : super(key: key);

  @override
  _AccountDeletePageState createState() => _AccountDeletePageState();
}

class _AccountDeletePageState extends NyState<AccountDeletePage> {
  @override
  init() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              PrimaryButton(
                  title: trans("Yes, delete my account"),
                  isLoading: isLocked('delete_account'),
                  action: _deleteAccount,
              ),
              LinkButton(title: trans("Back"), action: pop)
            ],
          )
        ],
      )),
    );
  }

  _deleteAccount() async {
    await lockRelease('delete_account', perform: () async {
      String? userToken = await readAuthToken();

      WPUserDeleteResponse? wpUserDeleteResponse;
      try {
        wpUserDeleteResponse = await WPJsonAPI.instance
            .api((request) => request.wpUserDelete(userToken));
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        showToastNotification(
          context,
          title: trans("Oops!"),
          description: trans("Something went wrong"),
          style: ToastNotificationStyleType.DANGER,
        );
      }

      if (wpUserDeleteResponse != null) {
        showToast(
            title: trans("Success"), description: trans("Account deleted"));
        await authLogout(context);
      }
    });
  }
}
