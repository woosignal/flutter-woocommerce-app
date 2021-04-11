//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/config/app_theme.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/helpers/helper.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountShippingDetailsPage extends StatefulWidget {
  AccountShippingDetailsPage();

  @override
  _AccountShippingDetailsPageState createState() =>
      _AccountShippingDetailsPageState();
}

class _AccountShippingDetailsPageState
    extends State<AccountShippingDetailsPage> {
  _AccountShippingDetailsPageState();

  AppTheme _appTheme = AppTheme();

  // BILLING TEXT CONTROLLERS
  TextEditingController _txtShippingFirstName = TextEditingController(),
      _txtShippingLastName = TextEditingController(),
      _txtShippingAddressLine = TextEditingController(),
      _txtShippingCity = TextEditingController(),
      _txtShippingPostalCode = TextEditingController(),
      _txtShippingState = TextEditingController(),
      _txtShippingCountry = TextEditingController();

  bool _isLoading = true, _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    String userToken = await readAuthToken();

    WCCustomerInfoResponse wcCustomerInfoResponse;
    try {
      wcCustomerInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wcCustomerInfo(userToken));
    } on Exception catch (_) {
      showToastNotification(
        context,
        title: trans(context, "Oops!"),
        description: trans(context, "Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
      Navigator.pop(context);
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (wcCustomerInfoResponse != null &&
        wcCustomerInfoResponse.status == 200) {
      Shipping shipping = wcCustomerInfoResponse.data.shipping;
      _txtShippingFirstName.text = shipping.firstName;
      _txtShippingLastName.text = shipping.lastName;

      _txtShippingAddressLine.text = shipping.address1;
      _txtShippingCity.text = shipping.city;
      _txtShippingState.text = shipping.state;
      _txtShippingPostalCode.text = shipping.postcode;
      _txtShippingCountry.text = shipping.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    AdaptiveThemeMode adaptiveTheme = AdaptiveTheme.of(context).mode;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(context, "Shipping Details"),
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _isLoading
              ? AppLoaderWidget()
              : LayoutBuilder(
                  builder: (context, constraints) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans(context, "First Name"),
                                      controller: _txtShippingFirstName,
                                      shouldAutoFocus: true,
                                    ),
                                  ),
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans(context, "Last Name"),
                                      controller: _txtShippingLastName,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                              TextEditingRow(
                                heading: trans(context, "Address Line"),
                                controller: _txtShippingAddressLine,
                              ),
                              Row(children: <Widget>[
                                Flexible(
                                  child: TextEditingRow(
                                    heading: trans(context, "City"),
                                    controller: _txtShippingCity,
                                  ),
                                ),
                                Flexible(
                                  child: TextEditingRow(
                                    heading: trans(context, "State"),
                                    controller: _txtShippingState,
                                  ),
                                ),
                              ]),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans(context, "Postal code"),
                                      controller: _txtShippingPostalCode,
                                    ),
                                  ),
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans(context, "Country"),
                                      controller: _txtShippingCountry,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: adaptiveTheme.isLight
                                ? Colors.white
                                : _appTheme.accentColor(
                                    brightness: Brightness.dark),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow:
                                adaptiveTheme.isLight ? wsBoxShadow() : null,
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        height:
                            (constraints.maxHeight - constraints.minHeight) *
                                0.6,
                      ),
                      Column(
                        children: <Widget>[
                          PrimaryButton(
                              title: trans(context, "UPDATE DETAILS"),
                              action:
                                  _isUpdating ? () {} : _updateShippingDetails),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _updateShippingDetails() async {
    String firstName = _txtShippingFirstName.text;
    String lastName = _txtShippingLastName.text;
    String addressLine = _txtShippingAddressLine.text;
    String city = _txtShippingCity.text;
    String state = _txtShippingState.text;
    String postalCode = _txtShippingPostalCode.text;
    String country = _txtShippingCountry.text;

    String userToken = await readAuthToken();

    if (_isUpdating == true) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    WCCustomerUpdatedResponse wcCustomerUpdatedResponse;
    try {
      wcCustomerUpdatedResponse = await WPJsonAPI.instance.api(
        (request) => request.wcUpdateCustomerInfo(
          userToken,
          shippingFirstName: firstName,
          shippingLastName: lastName,
          shippingAddress1: addressLine,
          shippingCity: city,
          shippingState: state,
          shippingPostcode: postalCode,
          shippingCountry: country,
        ),
      );
    } on Exception catch (_) {
      showToastNotification(context,
          title: trans(context, "Oops!"),
          description: trans(context, "Something went wrong"),
          style: ToastNotificationStyleType.DANGER);
    } finally {
      setState(() {
        _isUpdating = true;
      });
    }

    if (wcCustomerUpdatedResponse != null &&
        wcCustomerUpdatedResponse.status == 200) {
      showToastNotification(context,
          title: trans(context, "Success"),
          description: trans(context, "Account updated"),
          style: ToastNotificationStyleType.SUCCESS);
      Navigator.pop(context);
    }
  }
}
