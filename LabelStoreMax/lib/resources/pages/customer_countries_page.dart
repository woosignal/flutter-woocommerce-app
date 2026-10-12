//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/default_shipping.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CustomerCountriesPage extends NyStatefulWidget {
  static RouteView path =
      ("/customer-countries", (_) => CustomerCountriesPage());

  CustomerCountriesPage({super.key})
      : super(child: () => _CustomerCountriesPageState());
}

class _CustomerCountriesPageState extends NyPage<CustomerCountriesPage> {
  List<DefaultShipping> _defaultShipping = [], _activeShippingResults = [];
  final TextEditingController _tfSearchCountry = TextEditingController();

  @override
  get init => () async {
        _defaultShipping = await getDefaultShipping();
        _activeShippingResults = _defaultShipping;
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Select a country")),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              margin: EdgeInsets.only(bottom: 10, top: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: context.color.general.background),
              height: 60,
              child: Row(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.search),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tfSearchCountry,
                      autofocus: true,
                      onChanged: _handleOnChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (cxt, i) {
                    DefaultShipping defaultShipping = _activeShippingResults[i];
                    return InkWell(
                      onTap: () => _handleCountryTapped(defaultShipping),
                      child: Container(
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!)),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text(defaultShipping.country!),
                      ),
                    );
                  },
                  itemCount: _activeShippingResults.length),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOnChanged(String value) {
    _activeShippingResults = _defaultShipping
        .where((element) =>
            element.country!.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  void _handleCountryTapped(DefaultShipping defaultShipping) {
    if (defaultShipping.states.isNotEmpty) {
      _handleStates(defaultShipping);
      return;
    }
    _popWithShippingResult(defaultShipping);
  }

  void _handleStates(DefaultShipping defaultShipping) {
    FocusScope.of(context).unfocus();
    wsModalBottom(
      context,
      title: trans("Select a state"),
      bodyWidget: ListView.separated(
        itemCount: defaultShipping.states.length,
        itemBuilder: (BuildContext context, int index) {
          DefaultShippingState state = defaultShipping.states[index];

          return InkWell(
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () {
              Navigator.pop(context);
              _popWithShippingResult(defaultShipping, state: state);
            },
            child: Container(
              padding: EdgeInsets.only(top: 25, bottom: 25),
              child: Text(
                state.name!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  void _popWithShippingResult(DefaultShipping defaultShipping,
      {DefaultShippingState? state}) {
    if (state != null) {
      defaultShipping.states = [];
      defaultShipping.states.add(state);
    }
    Navigator.pop(context, defaultShipping);
  }
}
