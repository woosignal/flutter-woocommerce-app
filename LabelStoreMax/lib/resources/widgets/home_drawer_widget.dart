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
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_version_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class HomeDrawerWidget extends StatefulWidget {
  const HomeDrawerWidget({Key key, @required this.wooSignalApp})
      : super(key: key);

  final WooSignalApp wooSignalApp;

  @override
  _HomeDrawerWidgetState createState() => _HomeDrawerWidgetState();
}

class _HomeDrawerWidgetState extends State<HomeDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Drawer(
      child: Container(
        color: adaptiveTheme == AdaptiveThemeMode.light
            ? Colors.white
            : Color(0xFF2C2C2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(child: StoreLogo()),
              decoration: BoxDecoration(
                color: adaptiveTheme.isLight ? Colors.white : Colors.black87,
              ),
            ),
            Padding(
              child: Text(
                trans(context, "Menu"),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            ),
            if (widget.wooSignalApp.wpLoginEnabled == 1)
              ListTile(
                title: Text(trans(context, "Profile")),
                leading: Icon(Icons.account_circle),
                onTap: _actionProfile,
              ),
            ListTile(
              title: Text(trans(context, "Cart")),
              leading: Icon(Icons.shopping_cart),
              onTap: _actionCart,
            ),
            Padding(
              child: Text(
                trans(context, "About Us"),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            ),
            if (widget.wooSignalApp.appTermslink != null &&
                widget.wooSignalApp.appTermslink.isNotEmpty)
              ListTile(
                title: Text(trans(context, "Terms and conditions")),
                leading: Icon(Icons.menu_book_rounded),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                onTap: _actionTerms,
              ),
            if (widget.wooSignalApp.appPrivacylink != null &&
                widget.wooSignalApp.appPrivacylink.isNotEmpty)
              ListTile(
                title: Text(trans(context, "Privacy policy")),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                leading: Icon(Icons.account_balance),
                onTap: _actionPrivacy,
              ),
            ListTile(
              title: Text(adaptiveTheme.isDark
                  ? trans(context, "Light Mode")
                  : trans(context, "Dark Mode")),
              leading: Icon(Icons.brightness_4_rounded),
              onTap: () {
                setState(() {
                  AdaptiveTheme.of(context).toggleThemeMode();
                });
              },
            ),
            ListTile(
              title: AppVersionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  _actionTerms() => openBrowserTab(url: widget.wooSignalApp.appTermslink);

  _actionPrivacy() => openBrowserTab(url: widget.wooSignalApp.appPrivacylink);

  _actionProfile() async {
    Navigator.pop(context);
    if (widget.wooSignalApp.wpLoginEnabled == 1 && !(await authCheck())) {
      UserAuth.instance.redirect = "/account-detail";
      Navigator.pushNamed(context, "/account-landing");
      return;
    }
    Navigator.pushNamed(context, "/account-detail");
  }

  _actionCart() {
    Navigator.pop(context);
    Navigator.pushNamed(context, "/cart");
  }
}
