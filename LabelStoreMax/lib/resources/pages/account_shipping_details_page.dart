//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/billing_details.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/default_shipping.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/customer_address_input.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/switch_address_tab.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:validated/validated.dart' as validate;

class AccountShippingDetailsPage extends StatefulWidget {
  AccountShippingDetailsPage();

  @override
  _AccountShippingDetailsPageState createState() =>
      _AccountShippingDetailsPageState();
}

class _AccountShippingDetailsPageState
    extends NyState<AccountShippingDetailsPage> {
  _AccountShippingDetailsPageState();

  int activeTabIndex = 0;

  // TEXT CONTROLLERS
  final TextEditingController
      // billing
      _txtBillingFirstName = TextEditingController(),
      _txtBillingLastName = TextEditingController(),
      _txtBillingAddressLine = TextEditingController(),
      _txtBillingCity = TextEditingController(),
      _txtBillingPostalCode = TextEditingController(),
      _txtBillingEmailAddress = TextEditingController(),
      _txtBillingPhoneNumber = TextEditingController(),
      // shipping
      _txtShippingFirstName = TextEditingController(),
      _txtShippingLastName = TextEditingController(),
      _txtShippingAddressLine = TextEditingController(),
      _txtShippingCity = TextEditingController(),
      _txtShippingPostalCode = TextEditingController();

  CustomerCountry? _billingCountry, _shippingCountry;

  Widget? activeTab;

  Widget tabShippingDetails() => CustomerAddressInput(
      txtControllerFirstName: _txtShippingFirstName,
      txtControllerLastName: _txtShippingLastName,
      txtControllerAddressLine: _txtShippingAddressLine,
      txtControllerCity: _txtShippingCity,
      txtControllerPostalCode: _txtShippingPostalCode,
      customerCountry: _shippingCountry,
      onTapCountry: () => _navigateToSelectCountry(type: "shipping"));

  Widget tabBillingDetails() => CustomerAddressInput(
        txtControllerFirstName: _txtBillingFirstName,
        txtControllerLastName: _txtBillingLastName,
        txtControllerAddressLine: _txtBillingAddressLine,
        txtControllerCity: _txtBillingCity,
        txtControllerPostalCode: _txtBillingPostalCode,
        txtControllerEmailAddress: _txtBillingEmailAddress,
        txtControllerPhoneNumber: _txtBillingPhoneNumber,
        customerCountry: _billingCountry,
        onTapCountry: () => _navigateToSelectCountry(type: "billing"),
      );

  @override
  init() async {
    super.init();

    await awaitData(perform: () async {
      await _fetchUserDetails();
    });
  }

  _setFieldsFromCustomerAddress(CustomerAddress? customerAddress,
      {required String type}) {
    assert(type != "");
    if (customerAddress == null) {
      return;
    }
    _setFields(
      firstName: customerAddress.firstName,
      lastName: customerAddress.lastName,
      addressLine: customerAddress.addressLine,
      city: customerAddress.city,
      postalCode: customerAddress.postalCode,
      emailAddress: customerAddress.emailAddress,
      phoneNumber: customerAddress.phoneNumber,
      customerCountry: customerAddress.customerCountry,
      type: type,
    );
  }

  _setFields(
      {required String? firstName,
      required String? lastName,
      required String? addressLine,
      required String? city,
      required String? postalCode,
      required String? emailAddress,
      required String? phoneNumber,
      required CustomerCountry? customerCountry,
      String? type}) {
    if (type == "billing") {
      _txtBillingFirstName.text = firstName ?? "";
      _txtBillingLastName.text = lastName ?? "";
      _txtBillingAddressLine.text = addressLine ?? "";
      _txtBillingCity.text = city ?? "";
      _txtBillingPostalCode.text = postalCode ?? "";
      _txtBillingPhoneNumber.text = phoneNumber ?? "";
      _txtBillingEmailAddress.text = emailAddress ?? "";
      _billingCountry = customerCountry;
    } else if (type == "shipping") {
      _txtShippingFirstName.text = firstName ?? "";
      _txtShippingLastName.text = lastName ?? "";
      _txtShippingAddressLine.text = addressLine ?? "";
      _txtShippingCity.text = city ?? "";
      _txtShippingPostalCode.text = postalCode ?? "";
      _shippingCountry = customerCountry;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Billing & Shipping Details"),
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: isLoading()
            ? AppLoaderWidget()
            : GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Padding(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      SwitchAddressTab(
                                          title: trans("Billing Details"),
                                          currentTabIndex: activeTabIndex,
                                          type: "billing",
                                          onTapAction: () => setState(() {
                                                activeTabIndex = 0;
                                                activeTab = tabBillingDetails();
                                              })),
                                      SwitchAddressTab(
                                          title: trans("Shipping Address"),
                                          currentTabIndex: activeTabIndex,
                                          type: "shipping",
                                          onTapAction: () => setState(() {
                                                activeTabIndex = 1;
                                                activeTab =
                                                    tabShippingDetails();
                                              })),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                ),
                              ],
                            ),
                            height: 60,
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: ThemeColor.get(context)
                                      .backgroundContainer,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: (Theme.of(context).brightness ==
                                          Brightness.light)
                                      ? wsBoxShadow()
                                      : null,
                                ),
                                padding:
                                    EdgeInsets.only(left: 8, right: 8, top: 8),
                                margin: EdgeInsets.only(top: 8),
                                child: (activeTab ?? tabBillingDetails())),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      height: 160,
                      child: Column(
                        children: <Widget>[
                          PrimaryButton(
                            title: trans("USE DETAILS"),
                            action: _useDetailsTapped,
                            isLoading: isLocked('update_details'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _useDetailsTapped() async {
    lockRelease('update_details', perform: () async {
      // Billing email is required for Stripe
      String billingEmail = _txtBillingEmailAddress.text;
      if (billingEmail.isNotEmpty && !validate.isEmail(billingEmail)) {
        showToastNotification(
          context,
          title: trans("Oops"),
          description: trans("Please enter a valid shipping email"),
          style: ToastNotificationStyleType.WARNING,
        );
        return;
      }

      CustomerAddress userBillingAddress = _setCustomerAddress(
            firstName: _txtBillingFirstName.text,
            lastName: _txtBillingLastName.text,
            addressLine: _txtBillingAddressLine.text,
            city: _txtBillingCity.text,
            postalCode: _txtBillingPostalCode.text,
            phoneNumber: _txtBillingPhoneNumber.text,
            emailAddress: _txtBillingEmailAddress.text.trim(),
            customerCountry: _billingCountry,
          ),
          userShippingAddress = _setCustomerAddress(
            firstName: _txtShippingFirstName.text,
            lastName: _txtShippingLastName.text,
            addressLine: _txtShippingAddressLine.text,
            city: _txtShippingCity.text,
            postalCode: _txtShippingPostalCode.text,
            customerCountry: _shippingCountry,
          );

      String? userToken = await readAuthToken();

      WPUserInfoUpdatedResponse? wpUserInfoUpdatedResponse;
      try {
        wpUserInfoUpdatedResponse = await WPJsonAPI.instance.api(
          (request) => request.wpUpdateUserInfo(userToken, wpUserMetaData: [
            ...userBillingAddress.toUserMetaDataItem('billing'),
            ...userShippingAddress.toUserMetaDataItem('shipping'),
          ]),
        );
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans("Oops!"),
            description: trans("Something went wrong"),
            style: ToastNotificationStyleType.DANGER);
      }

      if (wpUserInfoUpdatedResponse != null &&
          wpUserInfoUpdatedResponse.status == 200) {
        showToastNotification(context,
            title: trans("Success"),
            description: trans("Account updated"),
            style: ToastNotificationStyleType.SUCCESS);
        Navigator.pop(context);
      }
    });
  }

  CustomerAddress _setCustomerAddress(
      {required String firstName,
      required String lastName,
      required String addressLine,
      required String city,
      required String postalCode,
      String? emailAddress,
      String? phoneNumber,
      required CustomerCountry? customerCountry}) {
    CustomerAddress customerShippingAddress = CustomerAddress();
    customerShippingAddress.firstName = firstName;
    customerShippingAddress.lastName = lastName;
    customerShippingAddress.addressLine = addressLine;
    customerShippingAddress.city = city;
    customerShippingAddress.postalCode = postalCode;
    if (phoneNumber != null && phoneNumber != "") {
      customerShippingAddress.phoneNumber = phoneNumber;
    }
    customerShippingAddress.customerCountry = customerCountry;
    customerShippingAddress.emailAddress = emailAddress;
    return customerShippingAddress;
  }

  _navigateToSelectCountry({required String type}) {
    Navigator.pushNamed(context, "/customer-countries").then((value) {
      if (value == null) {
        return;
      }

      if (type == "billing") {
        _billingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: value as DefaultShipping);
        activeTab = tabBillingDetails();
      } else if (type == "shipping") {
        _shippingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: value as DefaultShipping);
        activeTab = tabShippingDetails();
      }
      setState(() {});
    });
  }

  _fetchUserDetails() async {
    String? userToken = await readAuthToken();

    WPUserInfoResponse? wpUserInfoResponse;
    try {
      wpUserInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wpGetUserInfo(userToken!));
    } on Exception catch (e) {
      print(e.toString());
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
      Navigator.pop(context);
    }

    if (wpUserInfoResponse != null && wpUserInfoResponse.status == 200) {
      BillingDetails billingDetails =
          await billingDetailsFromWpUserInfoResponse(wpUserInfoResponse);

      _setFieldsFromCustomerAddress(billingDetails.shippingAddress,
          type: "shipping");
      _setFieldsFromCustomerAddress(billingDetails.billingAddress,
          type: "billing");

      setState(() {});
    }
  }
}
