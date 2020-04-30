//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/widgets/menu_item.dart';
import 'package:label_storemax/helpers/tools.dart';

import '../widgets/woosignal_ui.dart';

class HomeMenuPage extends StatefulWidget {
  HomeMenuPage();

  @override
  _HomeMenuPageState createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  _HomeMenuPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(trans(context, "Menu"),
            style: Theme.of(context).primaryTextTheme.title),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            storeLogo(height: 100),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  (use_wp_login
                      ? wsMenuItem(context,
                          title: trans(context, "Profile"),
                          leading: Icon(Icons.account_circle),
                          action: _actionProfile)
                      : Container()),
                  wsMenuItem(context,
                      title: trans(context, "Cart"),
                      leading: Icon(Icons.shopping_cart),
                      action: _actionCart),
                  wsMenuItem(context,
                      title: trans(context, "About Us"),
                      leading: Icon(Icons.account_balance),
                      action: _actionAboutUs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actionCart() {
    Navigator.pushNamed(context, "/cart");
  }

  void _actionAboutUs() {
    Navigator.pushNamed(context, "/about");
  }

  void _actionProfile() {
    Navigator.pushNamed(context, "/account-detail");
  }
}
