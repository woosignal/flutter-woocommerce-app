//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/shared_pref/sp_auth.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountBillingDetailsPage extends StatefulWidget {
  AccountBillingDetailsPage();

  @override
  _AccountBillingDetailsPageState createState() =>
      _AccountBillingDetailsPageState();
}

class _AccountBillingDetailsPageState extends State<AccountBillingDetailsPage> {
  _AccountBillingDetailsPageState();

  // BILLING TEXT CONTROLLERS
  TextEditingController _txtShippingFirstName;
  TextEditingController _txtShippingLastName;
  TextEditingController _txtShippingAddressLine;
  TextEditingController _txtShippingCity;
  TextEditingController _txtShippingState;
  TextEditingController _txtShippingPostalCode;
  TextEditingController _txtShippingCountry;

  bool _isLoading;
  bool _isUpdating;

  @override
  void initState() {
    super.initState();

    _txtShippingFirstName = TextEditingController();
    _txtShippingLastName = TextEditingController();
    _txtShippingAddressLine = TextEditingController();
    _txtShippingCity = TextEditingController();
    _txtShippingState = TextEditingController();
    _txtShippingPostalCode = TextEditingController();
    _txtShippingCountry = TextEditingController();

    _isLoading = true;
    _isUpdating = false;

    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    WCCustomerInfoResponse wcCustomerInfoResponse =
        await WPJsonAPI.instance.api((request) async {
      return request.wcCustomerInfo(await readAuthToken());
    });

    Billing billing = wcCustomerInfoResponse.data.billing;
    _txtShippingFirstName.text = billing.firstName;
    _txtShippingLastName.text = billing.lastName;

    _txtShippingAddressLine.text = billing.address1;
    _txtShippingCity.text = billing.city;
    _txtShippingState.text = billing.state;
    _txtShippingPostalCode.text = billing.postcode;
    _txtShippingCountry.text = billing.country;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(context, "Billing Details"),
          style: Theme.of(context).primaryTextTheme.subtitle1,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: _isLoading
              ? showAppLoader()
              : LayoutBuilder(
                  builder: (context, constraints) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: wsTextEditingRow(
                                      context,
                                      heading: trans(context, "First Name"),
                                      controller: _txtShippingFirstName,
                                      shouldAutoFocus: true,
                                    ),
                                  ),
                                  Flexible(
                                    child: wsTextEditingRow(
                                      context,
                                      heading: trans(context, "Last Name"),
                                      controller: _txtShippingLastName,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                              wsTextEditingRow(
                                context,
                                heading: trans(context, "Address Line"),
                                controller: _txtShippingAddressLine,
                              ),
                              Row(children: <Widget>[
                                Flexible(
                                  child: wsTextEditingRow(
                                    context,
                                    heading: trans(context, "City"),
                                    controller: _txtShippingCity,
                                  ),
                                ),
                                Flexible(
                                  child: wsTextEditingRow(context,
                                      heading: trans(context, "State"),
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _txtShippingState),
                                ),
                              ]),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: wsTextEditingRow(
                                      context,
                                      heading: trans(context, "Postal code"),
                                      controller: _txtShippingPostalCode,
                                    ),
                                  ),
                                  Flexible(
                                    child: wsTextEditingRow(context,
                                        heading: trans(context, "Country"),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: _txtShippingCountry),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: HexColor("#e8e8e8"),
                                blurRadius: 15.0,
                                spreadRadius: 0,
                                offset: Offset(
                                  0,
                                  0,
                                ),
                              )
                            ],
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        height:
                            (constraints.maxHeight - constraints.minHeight) *
                                0.6,
                      ),
                      Column(
                        children: <Widget>[
                          wsPrimaryButton(context,
                              title: trans(context, "UPDATE DETAILS"),
                              action:
                                  _isUpdating ? null : _updateBillingDetails),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _updateBillingDetails() async {
    String firstName = _txtShippingFirstName.text;
    String lastName = _txtShippingLastName.text;
    String addressLine = _txtShippingAddressLine.text;
    String city = _txtShippingCity.text;
    String state = _txtShippingState.text;
    String postalCode = _txtShippingPostalCode.text;
    String country = _txtShippingCountry.text;

    String userToken = await readAuthToken();

    setState(() {
      _isUpdating = true;
    });

    WCCustomerUpdatedResponse wcCustomerUpdatedResponse;
    try {
      wcCustomerUpdatedResponse = await WPJsonAPI.instance.api((request) =>
          request.wcUpdateCustomerInfo(userToken,
              billingFirstName: firstName,
              billingLastName: lastName,
              billingAddress1: addressLine,
              billingCity: city,
              billingState: state,
              billingPostcode: postalCode,
              billingCountry: country));
    } on Exception catch (_) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops!"),
          desc: trans(context, "Something went wrong"),
          style: EdgeAlertStyle.DANGER);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }

    if (wcCustomerUpdatedResponse != null &&
        wcCustomerUpdatedResponse.status == 200) {
      showEdgeAlertWith(context,
          title: trans(context, "Success"),
          desc: trans(context, "Account updated"),
          style: EdgeAlertStyle.SUCCESS);
      Navigator.pop(context);
    }
  }
}
