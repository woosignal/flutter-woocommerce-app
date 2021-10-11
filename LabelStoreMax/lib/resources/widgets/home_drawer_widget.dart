//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.


import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:flutter_app/resources/widgets/app_version_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/theme/helper/ny_theme.dart';
import 'package:nylo_support/helpers/helper.dart';
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
    bool isDark = (Theme.of(context).brightness == Brightness.dark);
    return Drawer(
      child: Container(
        color: NyColors.of(context).background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(child: StoreLogo()),
              decoration: BoxDecoration(
                color: NyColors.of(context).background,
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
                title: Text(trans(context, "Profile"), style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 16
                ),),
                leading: Icon(Icons.account_circle),
                onTap: _actionProfile,
              ),
            ListTile(
              title: Text(trans(context, "Cart"), style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 16
              ),),
              leading: Icon(Icons.shopping_cart),
              onTap: _actionCart,
            ),
          if (widget.wooSignalApp.appTermslink != null && widget.wooSignalApp.appPrivacylink != null)
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
                title: Text(trans(context, "Terms and conditions"),
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: 16
                    ),),
                leading: Icon(Icons.menu_book_rounded),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                onTap: _actionTerms,
              ),
            if (widget.wooSignalApp.appPrivacylink != null &&
                widget.wooSignalApp.appPrivacylink.isNotEmpty)
              ListTile(
                title: Text(trans(context, "Privacy policy"), style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 16
                ),),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                leading: Icon(Icons.account_balance),
                onTap: _actionPrivacy,
              ),
            ListTile(
              title: Text(
                  trans(context, (isDark ? "Light Mode" : "Dark Mode")),
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 16
                  )
              ),
              leading: Icon(Icons.brightness_4_rounded),
              onTap: () {
                setState(() {
                  NyTheme.set(context, id: isDark ? "default_light_theme" : "default_dark_theme");
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
