//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountProfileUpdatePage extends StatefulWidget {
  AccountProfileUpdatePage();

  @override
  _AccountProfileUpdatePageState createState() =>
      _AccountProfileUpdatePageState();
}

class _AccountProfileUpdatePageState extends State<AccountProfileUpdatePage> {
  _AccountProfileUpdatePageState();

  bool isLoading = true;
  final TextEditingController _tfFirstName = TextEditingController(),
      _tfLastName = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    WPUserInfoResponse wpUserInfoResponse =
        await WPJsonAPI.instance.api((request) async {
      return request.wpGetUserInfo((await readAuthToken()) ?? "0");
    });

    _tfFirstName.text = wpUserInfoResponse.data!.firstName!;
    _tfLastName.text = wpUserInfoResponse.data!.lastName!;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? AppLoaderWidget()
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: <Widget>[
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
                            title: trans("Update details"),
                            isLoading: isLoading,
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
            ),
    );
  }

  _updateDetails() async {
    String firstName = _tfFirstName.text;
    String lastName = _tfLastName.text;

    if (isLoading == false) {
      setState(() {
        isLoading = true;
      });

      String? userToken = await readAuthToken();
      WPUserInfoUpdatedResponse? wpUserInfoUpdatedResponse;
      try {
        wpUserInfoUpdatedResponse = await WPJsonAPI.instance.api((request) =>
            request.wpUpdateUserInfo(userToken,
                firstName: firstName, lastName: lastName));
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"),
            description: trans("Please check your email and password"),
            style: ToastNotificationStyleType.DANGER);
      } finally {
        setState(() {
          isLoading = false;
        });
      }

      if (wpUserInfoUpdatedResponse != null &&
          wpUserInfoUpdatedResponse.status == 200) {
        showToastNotification(context,
            title: trans("Success"),
            description: trans("Account updated"),
            style: ToastNotificationStyleType.SUCCESS);
        Navigator.pop(context);
      }
    }
  }
}
