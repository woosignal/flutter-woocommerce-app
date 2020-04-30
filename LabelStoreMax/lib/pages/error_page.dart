//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/buttons.dart';

class ErrorPage extends StatefulWidget {
  ErrorPage();

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  _ErrorPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: safeAreaDefault(),
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
                  trans(context, "Sorry, something went wrong"),
                  style: Theme.of(context).primaryTextTheme.body1,
                  textAlign: TextAlign.center,
                ),
              ),
              wsLinkButton(context, title: trans(context, "Back"), action: () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
