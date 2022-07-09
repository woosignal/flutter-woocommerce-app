//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/shared_key.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountLandingPage extends StatefulWidget {
  final bool showBackButton;
  AccountLandingPage({this.showBackButton = true});

  @override
  _AccountLandingPageState createState() => _AccountLandingPageState();
}

class _AccountLandingPageState extends NyState<AccountLandingPage> {

  final TextEditingController _tfEmailController = TextEditingController(),
      _tfPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        trans("Login"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context)!.backgroundContainer,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextEditingRow(
                            heading: trans("Email"),
                            controller: _tfEmailController,
                            keyboardType: TextInputType.emailAddress),
                        TextEditingRow(
                            heading: trans("Password"),
                            controller: _tfPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true),
                        PrimaryButton(
                          title: trans("Login"),
                          isLoading: isLocked('login_button'),
                          action: _loginUser,
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
                    color: (Theme.of(context).brightness == Brightness.light)
                        ? Colors.black38
                        : Colors.white70,
                  ),
                  Padding(
                    child: Text(
                      trans("Create an account"),
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
                title: trans("Forgot Password"),
                action: () {
                  String? forgotPasswordUrl =
                      AppHelper.instance.appConfig!.wpLoginForgotPasswordUrl;
                  if (forgotPasswordUrl != null) {
                    openBrowserTab(url: forgotPasswordUrl);
                  } else {
                    NyLogger.info(
                        "No URL found for \"forgot password\".\nAdd your forgot password URL here https://woosignal.com/dashboard/apps");
                  }
                }),
            widget.showBackButton
                ? Column(
                    children: [
                      Divider(),
                      LinkButton(
                        title: trans("Back"),
                        action: () => Navigator.pop(context),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  )
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
          title: trans("Invalid details"),
          description: trans("The email and password field cannot be empty"),
          style: ToastNotificationStyleType.DANGER);
      return;
    }

    if (!isEmail(email)) {
      showToastNotification(context,
          title: trans("Oops"),
          description: trans("That email address is not valid"),
          style: ToastNotificationStyleType.DANGER);
      return;
    }

    await lockRelease('login_button', perform: () async {
      WPUserLoginResponse? wpUserLoginResponse;
      try {
        wpUserLoginResponse = await WPJsonAPI.instance.api(
            (request) => request.wpLogin(email: email, password: password));
      } on InvalidNonceException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"),
            description:
                trans("Something went wrong, please contact our store"),
            style: ToastNotificationStyleType.DANGER);
      } on InvalidEmailException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"),
            description: trans("That email does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on InvalidUsernameException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"),
            description: trans("That username does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on IncorrectPasswordException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"),
            description: trans("That password does not match our records"),
            style: ToastNotificationStyleType.DANGER);
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans("Oops!"),
            description: trans("Invalid login credentials"),
            style: ToastNotificationStyleType.DANGER,
            icon: Icons.account_circle);
      }

      if (wpUserLoginResponse != null && wpUserLoginResponse.status == 200) {
        String? token = wpUserLoginResponse.data!.userToken;
        String userId = wpUserLoginResponse.data!.userId.toString();
        User user = User.fromUserAuthResponse(token: token, userId: userId);
        user.save(SharedKey.authUser);

        showToastNotification(context,
            title: trans("Hello"),
            description: trans("Welcome back"),
            style: ToastNotificationStyleType.SUCCESS,
            icon: Icons.account_circle);
        navigatorPush(context,
            routeName: UserAuth.instance.redirect, forgetLast: 1);
      }
    });
  }
}
