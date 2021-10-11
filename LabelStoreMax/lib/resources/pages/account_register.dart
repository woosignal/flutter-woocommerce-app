//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
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
import 'package:nylo_support/helpers/helper.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          trans(context, "Register")
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
                        color: (Theme.of(context).brightness == Brightness.light)
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
    String email = _tfEmailAddressController.text,
        password = _tfPasswordController.text,
        firstName = _tfFirstNameController.text,
        lastName = _tfLastNameController.text;

    if (email.isNotEmpty) {
      email = email.trim();
    }

    if (!isEmail(email)) {
      showToastNotification(context,
          title: trans(context, "Oops"),
          description: trans(context, "That email address is not valid"),
          style: ToastNotificationStyleType.DANGER);
      return;
    }

    if (password.length <= 5) {
      showToastNotification(context,
          title: trans(context, "Oops"),
          description: trans(context, "Password must be a min 6 characters"),
          style: ToastNotificationStyleType.DANGER);
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
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, e.message),
            style: ToastNotificationStyleType.DANGER);
      } on InvalidNonceException catch (_) {
        showToastNotification(context,
            title: trans(context, "Invalid details"),
            description: trans(
                context, "Something went wrong, please contact our store"),
            style: ToastNotificationStyleType.DANGER);
      } on ExistingUserLoginException catch (_) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, "A user already exists"),
            style: ToastNotificationStyleType.DANGER);
      } on ExistingUserEmailException catch (_) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, "That email is taken, try another"),
            style: ToastNotificationStyleType.DANGER);
      } on UserAlreadyExistException catch (_) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, "A user already exists"),
            style: ToastNotificationStyleType.DANGER);
      } on EmptyUsernameException catch (e) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, e.message),
            style: ToastNotificationStyleType.DANGER);
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans(context, "Oops!"),
            description: trans(context, "Something went wrong"),
            style: ToastNotificationStyleType.DANGER);
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

        showToastNotification(context,
            title: "${trans(context, "Hello")} $firstName",
            description: trans(context, "you're now logged in"),
            style: ToastNotificationStyleType.SUCCESS,
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
