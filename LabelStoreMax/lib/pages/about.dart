//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/app_helper.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/menu_item.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:package_info/package_info.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class AboutPage extends StatefulWidget {
  AboutPage();

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  _AboutPageState();

  WooSignalApp _wooSignalApp;

  @override
  void initState() {
    super.initState();
    _wooSignalApp = AppHelper.instance.appConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          trans(context, "About"),
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(child: StoreLogo()),
              flex: 2,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  MenuItem(
                    title: trans(context, "Privacy policy"),
                    leading: Icon(Icons.people),
                    action: _actionPrivacy,
                  ),
                  MenuItem(
                    title: trans(context, "Terms and conditions"),
                    leading: Icon(Icons.description),
                    action: _actionTerms,
                  ),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PackageInfo> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text("");
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return Text("");
                        case ConnectionState.done:
                          if (snapshot.hasError) return Text("");
                          return Padding(
                            child: Text(
                                "${trans(context, "Version")}: ${snapshot.data.version}",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText1),
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                          );
                      }
                      return null; // unreachable
                    },
                  ),
                ],
              ),
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _actionTerms() => openBrowserTab(url: _wooSignalApp.appTermslink);

  void _actionPrivacy() => openBrowserTab(url: _wooSignalApp.appPrivacylink);
}
