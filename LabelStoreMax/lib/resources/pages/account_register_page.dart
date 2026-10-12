//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/events/login_event.dart';
import '/app/forms/register_form.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/routes/guards/auth_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/wp_json_api_errors.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountRegistrationPage extends NyStatefulWidget {
  static RouteView path =
      ("/account-register", (_) => AccountRegistrationPage());

  AccountRegistrationPage({super.key})
      : super(child: () => _AccountRegistrationPageState());
}

class _AccountRegistrationPageState extends NyPage<AccountRegistrationPage> {
  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(trans("Register")),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              child: RegisterForm(
                  crossAxisSpacing: 15,
                  footer: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Button.primary(
                      text: trans("Sign up"),
                      submitForm: (
                        "register",
                        (data) async {
                          // First/Last name carry no validator because they
                          // are optional, so a field the customer never
                          // touched comes back null rather than "". Coerce it
                          // the way the TextEditingControllers used to.
                          await _signUpTapped(
                              data['first_name'] ?? "",
                              data['last_name'] ?? "",
                              data['email'],
                              data['password']);
                        }
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: InkWell(
                onTap: _viewTOSModal,
                child: RichText(
                  text: TextSpan(
                    text:
                        '${trans("By tapping \"Register\" you agree to ")} ${AppHelper.instance.appConfig!.appName!}\'s ',
                    children: <TextSpan>[
                      TextSpan(
                          text: trans("terms and conditions"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '  ${trans("and")}  '),
                      TextSpan(
                          text: trans("privacy policy"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.black45
                                : Colors.white70),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUpTapped(
      String firstName, String lastName, String email, String password) async {
    // RegisterForm validates the email address and the password strength
    // before this runs - see lib/app/forms/register_form.dart.
    if (email.isNotEmpty) {
      email = email.trim();
    }

    await lockRelease('register_user', perform: () async {
      WPUserRegisterResponse? wpUserRegisterResponse;
      try {
        // No username is sent: the store generates one from the email.
        wpUserRegisterResponse = await WPJsonAPI.instance.api(
          (request) => request.wcRegister(
            email: email.toLowerCase(),
            password: password,
            firstName: firstName.isEmpty ? null : firstName,
            lastName: lastName.isEmpty ? null : lastName,
          ),
        );
      } on Exception catch (e) {
        await showWpJsonApiError(e);
        return;
      }

      // Registering answers HTTP 201, so check for the session token rather
      // than a 200 status. Errors throw above.
      if (wpUserRegisterResponse?.data?.token == null) {
        showToast(
            title: trans("Oops!"),
            description: trans("Something went wrong"),
            id: 'danger');
        return;
      }

      event<LoginEvent>();

      showToast(
          title: "${trans("Hello")} $firstName",
          description: trans("you're now logged in"),
          id: 'success');
      if (!mounted) return;
      await routeToIntended(widget.data());
    });
  }

  Future<void> _viewTOSModal() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trans("Actions")),
        content: Text(trans("View Terms and Conditions or Privacy policy")),
        actions: <Widget>[
          MaterialButton(
            onPressed: _viewTermsConditions,
            child: Text(trans("Terms and Conditions")),
          ),
          MaterialButton(
            onPressed: _viewPrivacyPolicy,
            child: Text(trans("Privacy Policy")),
          ),
          Divider(),
          TextButton(
            onPressed: pop,
            child: Text(trans("Close")),
          ),
        ],
      ),
    );
  }

  void _viewTermsConditions() {
    Navigator.pop(context);
    openUrl(_wooSignalApp!.appTermsLink!);
  }

  void _viewPrivacyPolicy() {
    Navigator.pop(context);
    openUrl(_wooSignalApp!.appPrivacyLink!);
  }
}
