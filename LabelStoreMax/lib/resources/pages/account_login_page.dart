//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/forms/login_form.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/store_logo_widget.dart';
import '/app/events/login_event.dart';
import '/resources/pages/account_register_page.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountLoginPage extends NyStatefulWidget {
  static RouteView path = ("/account-login", (_) => AccountLoginPage());
  final bool showBackButton;
  AccountLoginPage({super.key, this.showBackButton = true})
      : super(child: () => _AccountLoginPageState());
}

class _AccountLoginPageState extends NyPage<AccountLoginPage> {
  LoginForm form = LoginForm();

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
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
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context).backgroundContainer,
                    ),
                    padding: EdgeInsets.only(
                        top: 20, bottom: 15, left: 16, right: 16),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: NyForm(
                        form: form,
                        crossAxisSpacing: 15,
                        footer: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Button.primary(
                              text: trans("Login"),
                              submitForm: (
                                form,
                                (data) async {
                                  await _loginUser(
                                      data['email'], data['password']);
                                }
                              ),
                            ))),
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
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      trans("Create an account"),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                ],
              ),
              onPressed: () => routeTo(AccountRegistrationPage.path),
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

  _loginUser(String email, String password) async {
    if (email.isNotEmpty) {
      email = email.trim();
    }

    await lockRelease('login_button', perform: () async {
      WPUserLoginResponse? wpUserLoginResponse;
      try {
        wpUserLoginResponse = await WPJsonAPI.instance.api(
            (request) => request.wpLogin(email: email, password: password));
      } on InvalidNonceException catch (_) {
        showToast(
            title: trans("Invalid details"),
            description:
                trans("Something went wrong, please contact our store"),
            style: ToastNotificationStyleType.danger);
      } on InvalidEmailException catch (_) {
        showToast(
            title: trans("Invalid details"),
            description: trans("That email does not match our records"),
            style: ToastNotificationStyleType.danger);
      } on InvalidUsernameException catch (_) {
        showToast(
            title: trans("Invalid details"),
            description: trans("That username does not match our records"),
            style: ToastNotificationStyleType.danger);
      } on IncorrectPasswordException catch (_) {
        showToast(
            title: trans("Invalid details"),
            description: trans("That password does not match our records"),
            style: ToastNotificationStyleType.danger);
      } on Exception catch (_) {
        showToast(
            title: trans("Oops!"),
            description: trans("Invalid login credentials"),
            style: ToastNotificationStyleType.danger,
            icon: Icons.account_circle);
      }

      if (wpUserLoginResponse == null) {
        return;
      }

      if (wpUserLoginResponse.status != 200) {
        return;
      }

      event<LoginEvent>();

      showToast(
          title: trans("Hello"),
          description: trans("Welcome back"),
          style: ToastNotificationStyleType.success,
          icon: Icons.account_circle);
      if (!mounted) return;
      navigatorPush(context,
          routeName: UserAuth.instance.redirect, forgetLast: 1);
    });
  }
}
