//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/shared_pref/sp_auth.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:wp_json_api/models/responses/WPUserInfoResponse.dart';
import 'package:wp_json_api/models/responses/WPUserInfoUpdatedResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountProfileUpdatePage extends StatefulWidget {
  AccountProfileUpdatePage();

  @override
  _AccountProfileUpdatePageState createState() =>
      _AccountProfileUpdatePageState();
}

class _AccountProfileUpdatePageState extends State<AccountProfileUpdatePage> {
  _AccountProfileUpdatePageState();

  bool isLoading;
  TextEditingController _tfFirstName;
  TextEditingController _tfLastName;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isLoading = true;
    _tfFirstName = TextEditingController();
    _tfLastName = TextEditingController();

    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    WPUserInfoResponse wpUserInfoResponse =
        await WPJsonAPI.instance.api((request) async {
      return request.wpGetUserInfo(await readAuthToken());
    });

    _tfFirstName.text = wpUserInfoResponse.data.firstName;
    _tfLastName.text = wpUserInfoResponse.data.lastName;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          trans(context, "Update Details"),
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: isLoading
          ? showAppLoader()
          : SafeArea(
//        minimum: safeAreaDefault(),
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
                                    child: wsTextEditingRow(context,
                                        heading: trans(context, "First Name"),
                                        controller: _tfFirstName,
                                        keyboardType: TextInputType.text)),
                                Flexible(
                                  child: wsTextEditingRow(context,
                                      heading: trans(context, "Last Name"),
                                      controller: _tfLastName,
                                      keyboardType: TextInputType.text),
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
                          wsPrimaryButton(context,
                              title: trans(context, "Update details"),
                              action: _updateDetails)
                        ],
                      ),
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool _isNetworking = false;
  _updateDetails() async {
    String firstName = _tfFirstName.text;
    String lastName = _tfLastName.text;

    if (_isNetworking == false) {
      setState(() {
        _isNetworking = true;
        isLoading = true;
      });

      WPUserInfoUpdatedResponse wpUserInfoUpdatedResponse =
          await WPJsonAPI.instance.api((request) async {
        return request.wpUpdateUserInfo(await readAuthToken(),
            firstName: firstName, lastName: lastName);
      });

      if (wpUserInfoUpdatedResponse != null &&
          wpUserInfoUpdatedResponse.status == 200) {
        showEdgeAlertWith(context,
            title: trans(context, "Success"),
            desc: trans(context, "Account updated"),
            style: EdgeAlertStyle.SUCCESS);
      } else {
        showEdgeAlertWith(context,
            title: trans(context, "Invalid details"),
            desc: trans(context, "Please check your email and password"),
            style: EdgeAlertStyle.WARNING);
      }
      setState(() {
        _isNetworking = false;
        isLoading = false;
      });
    }
  }
}
