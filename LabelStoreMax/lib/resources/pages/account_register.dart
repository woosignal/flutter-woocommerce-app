//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/shared_key.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/helpers/shared_pref.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/exceptions/empty_username_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_email_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_login_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountRegistrationPage extends StatefulWidget {
  AccountRegistrationPage();

  @override
  _AccountRegistrationPageState createState() =>
      _AccountRegistrationPageState();
}

class _AccountRegistrationPageState extends State<AccountRegistrationPage> {
  _AccountRegistrationPageState();

  bool _hasTappedRegister = false;
  TextEditingController _tfEmailAddressController = TextEditingController(),
      _tfPasswordController = TextEditingController(),
      _tfFirstNameController = TextEditingController(),
      _tfLastNameController = TextEditingController();

  WooSignalApp _wooSignalApp = AppHelper.instance.appConfig;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Register",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextEditingRow(
                        heading: trans(context, "First Name"),
                        controller: _tfFirstNameController,
                        shouldAutoFocus: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Flexible(
                      child: TextEditingRow(
                        heading: trans(context, "Last Name"),
                        controller: _tfLastNameController,
                        shouldAutoFocus: false,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                )),
            TextEditingRow(
              heading: trans(context, "Email address"),
              controller: _tfEmailAddressController,
              shouldAutoFocus: false,
              keyboardType: TextInputType.emailAddress,
            ),
            TextEditingRow(
              heading: trans(context, "Password"),
              controller: _tfPasswordController,
              shouldAutoFocus: true,
              obscureText: true,
            ),
            Padding(
              child: PrimaryButton(
                  title: trans(context, "Sign up"),
                  action: _hasTappedRegister ? () {} : _signUpTapped),
              padding: EdgeInsets.only(top: 10),
            ),
            Padding(
              child: InkWell(
                child: RichText(
                  text: TextSpan(
                    text: trans(
                            context, "By tapping \"Register\" you agree to ") +
                        AppHelper.instance.appConfig.appName +
                        '\'s ',
                    children: <TextSpan>[
                      TextSpan(
                          text: trans(context, "terms and conditions"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '  ' + trans(context, "and") + '  '),
                      TextSpan(
                          text: trans(context, "privacy policy"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(
                        color: adaptiveTheme.isLight
                            ? Colors.black45
                            : Colors.white70),
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: _viewTOSModal,
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  _signUpTapped() async {
    String email = _tfEmailAddressController.text;
    String password = _tfPasswordController.text;
    String firstName = _tfFirstNameController.text;
    String lastName = _tfLastNameController.text;

    if (email.isNotEmpty) {
      email = email.trim();
    }

    if (!isEmail(email)) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "That email address is not valid"),
          style: EdgeAlertStyle.DANGER);
      return;
    }

    if (password.length <= 5) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Password must be a min 6 characters"),
          style: EdgeAlertStyle.DANGER);
      return;
    }

    if (_hasTappedRegister == false) {
      setState(() {
        _hasTappedRegister = true;
      });

      String username =
          (email.replaceAll(new RegExp(r'([@.])'), "")) + randomStr(4);

      WPUserRegisterResponse wpUserRegisterResponse;
      try {
        wpUserRegisterResponse = await WPJsonAPI.instance.api(
          (request) => request.wpRegister(
            email: email.toLowerCase(),
            password: password,
            username: username,
          ),
        );
      } on UsernameTakenException catch (e) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, e.message),
            style: EdgeAlertStyle.DANGER);
      } on InvalidNonceException catch (_) {
        showEdgeAlertWith(context,
            title: trans(context, "Invalid details"),
            desc: trans(
                context, "Something went wrong, please contact our store"),
            style: EdgeAlertStyle.DANGER);
      } on ExistingUserLoginException catch (_) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "A user already exists"),
            style: EdgeAlertStyle.DANGER);
      } on ExistingUserEmailException catch (_) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "That email is taken, try another"),
            style: EdgeAlertStyle.DANGER);
      } on UserAlreadyExistException catch (_) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "A user already exists"),
            style: EdgeAlertStyle.DANGER);
      } on EmptyUsernameException catch (e) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, e.message),
            style: EdgeAlertStyle.DANGER);
      } on Exception catch (_) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "Something went wrong"),
            style: EdgeAlertStyle.DANGER);
      } finally {
        setState(() {
          _hasTappedRegister = false;
        });
      }

      if (wpUserRegisterResponse != null &&
          wpUserRegisterResponse.status == 200) {
        String token = wpUserRegisterResponse.data.userToken;
        String userId = wpUserRegisterResponse.data.userId.toString();
        User user = User.fromUserAuthResponse(token: token, userId: userId);
        user.save(SharedKey.authUser);

        await WPJsonAPI.instance.api((request) => request
            .wpUpdateUserInfo(token, firstName: firstName, lastName: lastName));

        showEdgeAlertWith(context,
            title: "${trans(context, "Hello")} $firstName",
            desc: trans(context, "you're now logged in"),
            style: EdgeAlertStyle.SUCCESS,
            icon: Icons.account_circle);
        navigatorPush(context,
            routeName: UserAuth.instance.redirect, forgetLast: 2);
      }
    }
  }

  _viewTOSModal() {
    showPlatformAlertDialog(
      context,
      title: trans(context, "Actions"),
      subtitle: trans(context, "View Terms and Conditions or Privacy policy"),
      actions: [
        dialogAction(context,
            title: trans(context, "Terms and Conditions"),
            action: _viewTermsConditions),
        dialogAction(context,
            title: trans(context, "Privacy Policy"),
            action: _viewPrivacyPolicy),
      ],
    );
  }

  void _viewTermsConditions() {
    Navigator.pop(context);
    openBrowserTab(url: _wooSignalApp.appTermslink);
  }

  void _viewPrivacyPolicy() {
    Navigator.pop(context);
    openBrowserTab(url: _wooSignalApp.appPrivacylink);
  }
}
