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
import 'package:label_storemax/helpers/shared_pref/sp_user_id.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_json_api/models/responses/WPUserLoginResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountLandingPage extends StatefulWidget {
  AccountLandingPage();

  @override
  _AccountLandingPageState createState() => _AccountLandingPageState();
}

class _AccountLandingPageState extends State<AccountLandingPage> {
  bool _hasTappedLogin;
  TextEditingController _tfEmailController;
  TextEditingController _tfPasswordController;

  @override
  void initState() {
    super.initState();

    _hasTappedLogin = false;
    _tfEmailController = TextEditingController();
    _tfPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  storeLogo(height: 100),
                  Flexible(
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(bottom: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        trans(context, "Login"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .display1
                            .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: wsBoxShadow(),
                        color: Colors.white),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        wsTextEditingRow(context,
                            heading: trans(context, "Email"),
                            controller: _tfEmailController,
                            keyboardType: TextInputType.emailAddress),
                        wsTextEditingRow(context,
                            heading: trans(context, "Password"),
                            controller: _tfPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true),
                        wsPrimaryButton(
                          context,
                          title: trans(context, "Login"),
                          action: _hasTappedLogin == true ? null : _loginUser,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color: Colors.black38,
                  ),
                  Padding(
                    child: Text(
                      trans(context, "Create an account"),
                      style: Theme.of(context).primaryTextTheme.body2,
                    ),
                    padding: EdgeInsets.only(left: 8),
                  )
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/account-register");
              },
            ),
            wsLinkButton(context, title: trans(context, "Forgot Password"),
                action: () {
              launch(app_forgot_password_url);
            }),
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;

    if (_hasTappedLogin == false) {
      setState(() {
        _hasTappedLogin = true;
      });

      WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
          .api((request) => request.wpLogin(email: email, password: password));
      _hasTappedLogin = false;

      if (wpUserLoginResponse != null) {
        String token = wpUserLoginResponse.data.userToken;
        authUser(token);
        storeUserId(wpUserLoginResponse.data.userId.toString());

        navigatorPush(context, routeName: "/home", forgetAll: true);
      } else {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "Invalid login credentials"),
            style: EdgeAlertStyle.WARNING,
            icon: Icons.account_circle);
        setState(() {
          _hasTappedLogin = false;
        });
      }
    }
  }
}
