//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import '/resources/pages/browse_search_page.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomeSearchPage extends StatefulWidget {
  static String path = "/home-search";
  HomeSearchPage();

  @override
  createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  _HomeSearchPageState();

  final TextEditingController _txtSearchController = TextEditingController();

  _actionSearch() {
    routeTo(BrowseSearchPage.path, data: _txtSearchController.text,
        onPop: (value) {
      if (["notic", "compo"].contains(AppHelper.instance.appConfig!.theme) ==
          false) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NyTextField.compact(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: _txtSearchController,
              style: Theme.of(context).textTheme.displaySmall,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            Container(
              child: PrimaryButton(
                title: trans("Search"),
                action: _actionSearch,
              ),
            )
          ],
        ).withGap(20),
      ),
    );
  }
}
