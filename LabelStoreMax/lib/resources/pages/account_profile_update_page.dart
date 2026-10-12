//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import '/bootstrap/wp_json_api_errors.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountProfileUpdatePage extends NyStatefulWidget {
  static RouteView path =
      ("/account-update", (_) => AccountProfileUpdatePage());

  AccountProfileUpdatePage({super.key})
      : super(child: () => _AccountProfileUpdatePageState());
}

class _AccountProfileUpdatePageState extends NyPage<AccountProfileUpdatePage> {
  final TextEditingController _tfFirstName = TextEditingController(),
      _tfLastName = TextEditingController();

  @override
  get init => () async {
        await _fetchUserDetails();
      };

  Future<void> _fetchUserDetails() async {
    WPUserInfoResponse? wpUserInfoResponse;
    try {
      wpUserInfoResponse =
          await WPJsonAPI.instance.api((request) => request.wpGetUserInfo());
    } on Exception catch (e) {
      await showWpJsonApiError(e);
      return;
    }

    _tfFirstName.text = wpUserInfoResponse?.data?.firstName ?? "";
    _tfLastName.text = wpUserInfoResponse?.data?.lastName ?? "";
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
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
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
                      Button.primary(
                        text: trans("Update Details"),
                        onPressed: _updateDetails)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _updateDetails() async {
    String firstName = _tfFirstName.text;
    String lastName = _tfLastName.text;

    check((validators) {
      validators.add(FormValidator.notEmpty().that(firstName, "First name"));
      validators.add(FormValidator.notEmpty().that(lastName, "Last name"));
    }, onValidationError: (_) {
      showToastWarning(description: trans("Please check your details"));
    }, onSuccess: () async {
      await lockRelease("update_account", perform: () async {
        WPUserInfoUpdatedResponse? wpUserInfoUpdatedResponse;
        try {
          wpUserInfoUpdatedResponse = await WPJsonAPI.instance.api((request) =>
              request.wpUpdateUserInfo(
                  firstName: firstName, lastName: lastName));
        } on Exception catch (e) {
          await showWpJsonApiError(e);
          return;
        }

        if (wpUserInfoUpdatedResponse != null) {
          showToast(
              title: trans("Success"),
              description: trans("Account updated"),
              id: 'success');
          pop();
        }
      });
    });
  }
}
