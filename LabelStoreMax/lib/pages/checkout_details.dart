//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/app_state_options.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/billing_details.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:label_storemax/app_country_options.dart';

class CheckoutDetailsPage extends StatefulWidget {
  CheckoutDetailsPage();

  @override
  _CheckoutDetailsPageState createState() => _CheckoutDetailsPageState();
}

class _CheckoutDetailsPageState extends State<CheckoutDetailsPage> {
  _CheckoutDetailsPageState();

  // BILLING TEXT CONTROLLERS
  TextEditingController _txtShippingFirstName;
  TextEditingController _txtShippingLastName;
  TextEditingController _txtShippingAddressLine;
  TextEditingController _txtShippingCity;
  TextEditingController _txtShippingPostalCode;
  TextEditingController _txtShippingEmailAddress;
  String _strBillingCountry;
  String _strBillingState;

  var valRememberDetails = true;

  @override
  void initState() {
    super.initState();

    _txtShippingFirstName = TextEditingController();
    _txtShippingLastName = TextEditingController();
    _txtShippingAddressLine = TextEditingController();
    _txtShippingCity = TextEditingController();
    _txtShippingPostalCode = TextEditingController();
    _txtShippingEmailAddress = TextEditingController();

    if (CheckoutSession.getInstance.billingDetails.billingAddress == null) {
      CheckoutSession.getInstance.billingDetails.initSession();
      CheckoutSession.getInstance.billingDetails.shippingAddress.initAddress();
      CheckoutSession.getInstance.billingDetails.billingAddress.initAddress();
    }
    BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;
    _txtShippingFirstName.text = billingDetails.billingAddress.firstName;
    _txtShippingLastName.text = billingDetails.billingAddress.lastName;
    _txtShippingAddressLine.text = billingDetails.billingAddress.addressLine;
    _txtShippingCity.text = billingDetails.billingAddress.city;
    _txtShippingPostalCode.text = billingDetails.billingAddress.postalCode;
    _txtShippingEmailAddress.text = billingDetails.billingAddress.emailAddress;
    _strBillingCountry = billingDetails.billingAddress.country;
    _strBillingState = billingDetails.billingAddress.state;

    valRememberDetails = billingDetails.rememberDetails ?? true;
    _sfCustomerAddress();
  }

  _sfCustomerAddress() async {
    CustomerAddress sfCustomerAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    if (sfCustomerAddress != null) {
      CustomerAddress customerAddress = sfCustomerAddress;
      _txtShippingFirstName.text = customerAddress.firstName;
      _txtShippingLastName.text = customerAddress.lastName;
      _txtShippingAddressLine.text = customerAddress.addressLine;
      _txtShippingCity.text = customerAddress.city;
      _txtShippingPostalCode.text = customerAddress.postalCode;
      _txtShippingEmailAddress.text = customerAddress.emailAddress;
      _strBillingState = customerAddress.state;
      _strBillingCountry = customerAddress.country;
    }
  }

  _showSelectCountryModal() {
    wsModalBottom(
      context,
      title: trans(context, "Select a country"),
      bodyWidget: ListView.separated(
        itemCount: appCountryOptions.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> strName = appCountryOptions[index];

          return InkWell(
            child: Container(
              child: Text(strName["name"],
                  style: Theme.of(context).primaryTextTheme.bodyText1),
              padding: EdgeInsets.only(top: 25, bottom: 25),
            ),
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () => setState(() {
              _strBillingCountry = strName["name"];
              Navigator.of(context).pop();
              if (strName["code"] == "US") {
                _showSelectStateModal();
              } else {
                _strBillingState = "";
              }
            }),
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  _showSelectStateModal() {
    wsModalBottom(
      context,
      title: trans(context, "Select a state"),
      bodyWidget: ListView.separated(
        itemCount: appStateOptions.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> strName = appStateOptions[index];

          return InkWell(
            child: Container(
              child: Text(
                strName["name"],
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
              padding: EdgeInsets.only(top: 25, bottom: 25),
            ),
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () => setState(() {
              _strBillingState = strName["name"];
              Navigator.of(context).pop();
            }),
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(context, "Billing & Shipping Details"),
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: LayoutBuilder(
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: wsTextEditingRow(
                                context,
                                heading: trans(context, "Address Line"),
                                controller: _txtShippingAddressLine,
                              ),
                            ),
                            Flexible(
                              child: wsTextEditingRow(
                                context,
                                heading: trans(context, "City"),
                                controller: _txtShippingCity,
                              ),
                            ),
                          ],
                        ),
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
                                  heading: trans(context, "Email address"),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _txtShippingEmailAddress),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            (_strBillingCountry == "United States"
                                ? Flexible(
                                    child: Padding(
                                      child: wsSecondaryButton(
                                        context,
                                        title: (_strBillingState != null &&
                                                _strBillingState.isNotEmpty
                                            ? trans(context, "Selected") +
                                                "\n" +
                                                _strBillingState
                                            : trans(context, "Select state")),
                                        action: _showSelectStateModal,
                                      ),
                                      padding: EdgeInsets.all(8),
                                    ),
                                  )
                                : null),
                            Flexible(
                              child: Padding(
                                child: wsSecondaryButton(
                                  context,
                                  title: (_strBillingCountry != null &&
                                          _strBillingCountry.isNotEmpty
                                      ? trans(context, "Selected") +
                                          "\n" +
                                          _strBillingCountry
                                      : trans(context, "Select country")),
                                  action: _showSelectCountryModal,
                                ),
                                padding: EdgeInsets.all(8),
                              ),
                            )
                          ].where((element) => element != null).toList(),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: wsBoxShadow(),
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                ),
                Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          trans(context, "Remember my details"),
                          style: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        Checkbox(
                          value: valRememberDetails,
                          onChanged: (bool value) {
                            setState(() {
                              valRememberDetails = value;
                            });
                          },
                        )
                      ],
                    ),
                    wsPrimaryButton(context,
                        title: trans(context, "USE SHIPPING ADDRESS"),
                        action: () {
                      CustomerAddress customerAddress = new CustomerAddress();
                      customerAddress.firstName = _txtShippingFirstName.text;
                      customerAddress.lastName = _txtShippingLastName.text;
                      customerAddress.addressLine =
                          _txtShippingAddressLine.text;
                      customerAddress.city = _txtShippingCity.text;
                      customerAddress.postalCode = _txtShippingPostalCode.text;
                      customerAddress.state = _strBillingState;
                      customerAddress.country = _strBillingCountry;
                      customerAddress.emailAddress =
                          _txtShippingEmailAddress.text;

                      CheckoutSession.getInstance.billingDetails
                          .shippingAddress = customerAddress;
                      CheckoutSession.getInstance.billingDetails
                          .billingAddress = customerAddress;

                      CheckoutSession.getInstance.billingDetails
                          .rememberDetails = valRememberDetails;

                      if (valRememberDetails == true) {
                        CheckoutSession.getInstance.saveBillingAddress();
                      } else {
                        CheckoutSession.getInstance.clearBillingAddress();
                      }

                      CheckoutSession.getInstance.shippingType = null;
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
