//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountProfileUpdatePage extends StatefulWidget {
  static String path = "/account-update";
  AccountProfileUpdatePage();

  @override
  createState() => _AccountProfileUpdatePageState();
}

class _AccountProfileUpdatePageState extends NyState<AccountProfileUpdatePage> {
  _AccountProfileUpdatePageState();

  final TextEditingController _tfFirstName = TextEditingController(),
      _tfLastName = TextEditingController();

  @override
  boot() async {
    await _fetchUserDetails();
  }

  _fetchUserDetails() async {
    WPUserInfoResponse wpUserInfoResponse =
        await WPJsonAPI.instance.api((request) async {
      return request.wpGetUserInfo();
    });

    _tfFirstName.text = wpUserInfoResponse.data!.firstName!;
    _tfLastName.text = wpUserInfoResponse.data!.lastName!;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            trans("Update Details"),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: TextEditingRow(
                                heading: trans("First Name"),
                                controller: _tfFirstName,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            Flexible(
                              child: TextEditingRow(
                                heading: trans("Last Name"),
                                controller: _tfLastName,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      PrimaryButton(
                        title: trans("Update Details"),
                        isLoading: isLocked('update_account'),
                        action: _updateDetails,
                      )
                    ],
                  ),
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ));
  }

  _updateDetails() async {
    String firstName = _tfFirstName.text;
    String lastName = _tfLastName.text;

    validate(
        rules: {
          "first_name": [firstName, "not_empty"],
          "last_name": [lastName, "not_empty"]
        },
        onSuccess: () async {
          WPUserInfoUpdatedResponse? wpUserInfoUpdatedResponse;
          try {
            wpUserInfoUpdatedResponse = await WPJsonAPI.instance.api(
                (request) => request.wpUpdateUserInfo(
                    firstName: firstName, lastName: lastName));
          } on Exception catch (_) {
            showToastNotification(context,
                title: trans("Invalid details"),
                description: trans("Please check your email and password"),
                style: ToastNotificationStyleType.DANGER);
          }

          if (wpUserInfoUpdatedResponse != null &&
              wpUserInfoUpdatedResponse.status == 200) {
            showToastNotification(context,
                title: trans("Success"),
                description: trans("Account updated"),
                style: ToastNotificationStyleType.SUCCESS);
            Navigator.pop(context);
          }
        },
        lockRelease: "update_account");
  }
}
