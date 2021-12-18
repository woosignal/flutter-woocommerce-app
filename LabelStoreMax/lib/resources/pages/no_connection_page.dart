//  StoreMob
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class NoConnectionPage extends StatefulWidget {
  NoConnectionPage();

  @override
  _NoConnectionPageState createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  _NoConnectionPageState();

  @override
  void initState() {
    super.initState();
    print('WooCommerce site is not connected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeAreaWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.black54,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  trans("Oops, something went wrong"),
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.center,
                ),
              ),
              LinkButton(title: trans("Retry"), action: _retry),
            ],
          ),
        ),
      ),
    );
  }

  _retry() async {
    WooSignalApp wooSignalApp = await appWooSignal((api) => api.getApp());

    if (wooSignalApp == null) {
      showToastNotification(context,
          title: trans("Oops"),
          description: trans("Retry later"));
      return;
    }

    AppHelper.instance.appConfig = wooSignalApp;
    Navigator.pushNamed(context, "/home");
  }
}
