//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/shared_key.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountLandingPage extends StatefulWidget {
  AccountLandingPage();

  @override
  _AccountLandingPageState createState() => _AccountLandingPageState();
}

class _AccountLandingPageState extends State<AccountLandingPage> {
  bool _hasTappedLogin = false;
  TextEditingController _tfEmailController = TextEditingController(),
      _tfPasswordController = TextEditingController();
  AppTheme _appTheme = AppTheme();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  StoreLogo(height: 100),
                  Flexible(
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(bottom: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        trans(context, "Login"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline4.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: adaptiveTheme.isLight ? wsBoxShadow() : null,
                      color: adaptiveTheme.isLight
                          ? Colors.white
                          : _appTheme.accentColor(brightness: Brightness.dark),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextEditingRow(
                            heading: trans(context, "Email"),
                            controller: _tfEmailController,
                            keyboardType: TextInputType.emailAddress),
                        TextEditingRow(
                            heading: trans(context, "Password"),
                            controller: _tfPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true),
                        PrimaryButton(
                          title: trans(context, "Login"),
                          action: _hasTappedLogin == true ? () {} : _loginUser,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color:
                        adaptiveTheme.isLight ? Colors.black38 : Colors.white70,
                  ),
                  Padding(
                    child: Text(
                      trans(context, "Create an account"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    padding: EdgeInsets.only(left: 8),
                  )
                ],
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, "/account-register"),
            ),
            LinkButton(
                title: trans(context, "Forgot Password"),
                action: () {
                  String forgotPasswordUrl =
                      AppHelper.instance.appConfig.wpLoginForgotPasswordUrl;
                  if (forgotPasswordUrl != null) {
                    openBrowserTab(url: forgotPasswordUrl);
                  } else {
                    NyLogger.info(
                        "No URL found for \"forgot password\".\nAdd your forgot password URL here https://woosignal.com/dashboard/apps");
                  }
                }),
            Divider(),
            LinkButton(
              title: trans(context, "Back"),
              action: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;

    if (email.isNotEmpty) {
      email = email.trim();
    }

    if (email == "" || password == "") {
      showToastNotification(context,
          title: trans(context, "Invalid details"),
          description:
              trans(context, "The email and password field cannot be empty"),
          style: ToastNotificationStyleType.DANGER);
      return;
    }

    if (!isEmail(email)) {
      showToastNotification(context,
          title: trans(context, "Oops"),
          description: trans(context, "That email address is not valid"),
          style: ToastNotificationStyleType.DANGER);
      return;
    }

    if (_hasTappedLogin == false) {
      setState(() {
        _hasTappedLogin = true;
      });

      WPUserLoginResponse wpUserLoginResponse;
      try {
        wpUserLoginResponse = await WPJsonAPI.instance.api(
            (request) => request.wpLogin(email: email, password: password));
      } on InvalidNonceException catch (_) {
        showToastNotification(context,
            title: trans(context, "Invalid details"),
            description: trans(
                context, "Something went wrong, please contact our store"),
            style: ToastNotificationStyleType.DANGER);
      } on InvalidEmailException catch (_) {
        showToastNotification(context,
            title: trans(context, "Invalid details"),
            description:
                trans(context, "That email does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on InvalidUsernameException catch (_) {
        showToastNotification(context,
            title: trans(context, "Invalid details"),
            description:
                trans(context, "That username does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on IncorrectPasswordException catch (_) {
        showToastNotification(context,
            title: trans(context, "Invalid details"),
            description:
                trans(context, "That password does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, "Invalid login credentials"),
            style: ToastNotificationStyleType.DANGER,
            icon: Icons.account_circle);
      } finally {
        setState(() {
          _hasTappedLogin = false;
        });
      }

      if (wpUserLoginResponse != null && wpUserLoginResponse.status == 200) {
        String token = wpUserLoginResponse.data.userToken;
        String userId = wpUserLoginResponse.data.userId.toString();
        User user = User.fromUserAuthResponse(token: token, userId: userId);
        user.save(SharedKey.authUser);

        showToastNotification(context,
            title: trans(context, "Hello"),
            description: trans(context, "Welcome back"),
            style: ToastNotificationStyleType.SUCCESS,
            icon: Icons.account_circle);
        navigatorPush(context,
            routeName: UserAuth.instance.redirect, forgetLast: 1);
      }
    }
  }
}
