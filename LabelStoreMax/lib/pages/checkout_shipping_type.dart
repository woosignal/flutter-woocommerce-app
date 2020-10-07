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
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/models/shipping_type.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:woosignal/models/response/shipping_method.dart';
import 'package:label_storemax/app_country_options.dart';

class CheckoutShippingTypePage extends StatefulWidget {
  CheckoutShippingTypePage();

  @override
  _CheckoutShippingTypePageState createState() =>
      _CheckoutShippingTypePageState();
}

class _CheckoutShippingTypePageState extends State<CheckoutShippingTypePage> {
  _CheckoutShippingTypePageState();

  bool _isShippingSupported;
  bool _isLoading;
  List<Map<String, dynamic>> _wsShippingOptions;
  WSShipping _shipping;

  @override
  void initState() {
    super.initState();

    _isShippingSupported = true;
    _wsShippingOptions = [];

    _isLoading = true;
    _getShippingMethods();
  }

  _getShippingMethods() async {
    List<WSShipping> wsShipping =
        await appWooSignal((api) => api.getShippingMethods());
    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails.shippingAddress;
    String postalCode = customerAddress.postalCode;
    String country = customerAddress.country;
    String state = customerAddress.state;

    String countryCode = appCountryOptions
        .firstWhere((c) => c['name'] == country, orElse: () => null)["code"];

    Map<String, dynamic> stateMap = appStateOptions
        .firstWhere((c) => c['name'] == state, orElse: () => null);

    for (final shipping in wsShipping) {
      Locations location = shipping.locations.firstWhere(
          (ws) => (ws.type == "state" &&
                  stateMap["code"] != null &&
                  ws.code == "$countryCode:" + stateMap["code"] ||
              ws.code == postalCode ||
              ws.code == countryCode),
          orElse: () => null);

      if (location != null) {
        _shipping = shipping;
        break;
      }
    }

    if (_shipping != null && _shipping.methods != null) {
      if (_shipping.methods.flatRate != null) {
        _shipping.methods.flatRate
            .where((t) => t != null)
            .toList()
            .forEach((flatRate) {
          Map<String, dynamic> tmpShippingOption = {};
          tmpShippingOption = {
            "id": flatRate.id,
            "title": flatRate.title,
            "method_id": "flat_rate",
            "cost": flatRate.cost,
            "object": flatRate
          };
          _wsShippingOptions.add(tmpShippingOption);
        });
      }

      if (_shipping.methods.localPickup != null) {
        _shipping.methods.localPickup
            .where((t) => t != null)
            .toList()
            .forEach((localPickup) {
          Map<String, dynamic> tmpShippingOption = {};
          tmpShippingOption = {
            "id": localPickup.id,
            "method_id": "local_pickup",
            "title": localPickup.title,
            "cost": localPickup.cost,
            "object": localPickup
          };
          _wsShippingOptions.add(tmpShippingOption);
        });
      }

      if (_shipping.methods.freeShipping != null) {
        List<FreeShipping> freeShipping =
            _shipping.methods.freeShipping.where((t) => t != null).toList();

        for (int i = 0; i < freeShipping.length; i++) {
          if (isNumeric(freeShipping[i].cost) ||
              freeShipping[i].cost == 'min_amount') {
            if (freeShipping[i].cost == 'min_amount') {
              String total = await Cart.getInstance.getTotal();
              if (total != null) {
                double doubleTotal = double.parse(total);
                double doubleMinimumValue =
                    double.parse(freeShipping[i].minimumOrderAmount);

                if (doubleTotal < doubleMinimumValue) {
                  continue;
                }
              }
            }

            Map<String, dynamic> tmpShippingOption = {};
            tmpShippingOption = {
              "id": freeShipping[i].id,
              "method_id": "free_shipping",
              "title": freeShipping[i].title,
              "cost": "0.00",
              "min_amount": freeShipping[i].minimumOrderAmount,
              "object": freeShipping[i]
            };
            _wsShippingOptions.add(tmpShippingOption);
          }
        }
      }
    }

    if (_wsShippingOptions.length == 0) {
      _isShippingSupported = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _getShippingPrice(int index) async {
    double total = 0;
    List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();

    total +=
        await workoutShippingCostWC(sum: _wsShippingOptions[index]['cost']);

    switch (_wsShippingOptions[index]['method_id']) {
      case "flat_rate":
        FlatRate flatRate = (_wsShippingOptions[index]['object'] as FlatRate);

        if (cartLineItem.firstWhere(
                (t) => t.shippingClassId == null || t.shippingClassId == "0",
                orElse: () => null) !=
            null) {
          total += await workoutShippingClassCostWC(
              sum: flatRate.classCost,
              cartLineItem: cartLineItem
                  .where((t) =>
                      t.shippingClassId == null || t.shippingClassId == "0")
                  .toList());
        }

        List<CartLineItem> cItemsWithShippingClasses = cartLineItem
            .where((t) => t.shippingClassId != null && t.shippingClassId != "0")
            .toList();
        for (int i = 0; i < cItemsWithShippingClasses.length; i++) {
          ShippingClasses shippingClasses = flatRate.shippingClasses.firstWhere(
              (d) => d.id == cItemsWithShippingClasses[i].shippingClassId,
              orElse: () => null);
          if (shippingClasses != null) {
            double classTotal = await workoutShippingClassCostWC(
                sum: shippingClasses.cost,
                cartLineItem: cartLineItem
                    .where((g) => g.shippingClassId == shippingClasses.id)
                    .toList());
            total += classTotal;
          }
        }

        break;
      default:
        break;
    }
    return (total).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(
            context,
            "Shipping Methods",
          ),
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/shipping_icon.png"),
                        height: 100,
                        fit: BoxFit.fitHeight),
                  ),
                  padding: EdgeInsets.only(top: 20),
                ),
                SizedBox(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        (_isLoading
                            ? Expanded(child: showAppLoader())
                            : (_isShippingSupported
                                ? Expanded(
                                    child: ListView.separated(
                                      itemCount: _wsShippingOptions.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        color: Colors.black12,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          contentPadding: EdgeInsets.only(
                                              left: 16, right: 16),
                                          title: Text(
                                            _wsShippingOptions[index]['title'],
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .subtitle1,
                                          ),
                                          selected: true,
                                          subtitle: FutureBuilder<String>(
                                            future: _getShippingPrice(index),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.none:
                                                  return Text('');
                                                case ConnectionState.active:
                                                case ConnectionState.waiting:
                                                  return Text('');
                                                case ConnectionState.done:
                                                  if (snapshot.hasError)
                                                    return Text('');
                                                  return RichText(
                                                      text: TextSpan(
                                                    text: '',
                                                    style: DefaultTextStyle.of(
                                                            context)
                                                        .style,
                                                    children: <TextSpan>[
                                                      (_wsShippingOptions[index]
                                                                  ["object"]
                                                              is FreeShipping
                                                          ? TextSpan(
                                                              text:
                                                                  "Free postage")
                                                          : TextSpan(
                                                              text: trans(
                                                                      context,
                                                                      "Price") +
                                                                  ": " +
                                                                  formatStringCurrency(
                                                                      total: snapshot
                                                                          .data),
                                                            )),
                                                      _wsShippingOptions[index][
                                                                  "min_amount"] !=
                                                              null
                                                          ? TextSpan(
                                                              text: "\nSpend a minimum of " +
                                                                  formatStringCurrency(
                                                                      total: _wsShippingOptions[
                                                                              index]
                                                                          [
                                                                          "min_amount"]),
                                                              style: Theme.of(
                                                                      context)
                                                                  .primaryTextTheme
                                                                  .bodyText2
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14))
                                                          : null,
                                                    ]
                                                        .where((e) => e != null)
                                                        .toList(),
                                                  ));
                                              }
                                              return null;
                                            },
                                          ),
                                          trailing: (CheckoutSession.getInstance
                                                          .shippingType !=
                                                      null &&
                                                  CheckoutSession
                                                          .getInstance
                                                          .shippingType
                                                          .object ==
                                                      _wsShippingOptions[index]
                                                          ["object"]
                                              ? Icon(Icons.check)
                                              : null),
                                          onTap: () =>
                                              _handleCheckoutTapped(index),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    trans(context,
                                        "Shipping is not supported for your country, sorry"),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6,
                                    textAlign: TextAlign.center))),
                        wsLinkButton(
                          context,
                          title: trans(context, "CANCEL"),
                          action: () => Navigator.pop(context),
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleCheckoutTapped(int index) async {
    ShippingType shippingType = ShippingType();
    shippingType.object = _wsShippingOptions[index]['object'];
    shippingType.methodId = _wsShippingOptions[index]['method_id'];
    if (_wsShippingOptions[index]['min_amount'] != null) {
      shippingType.minimumValue = _wsShippingOptions[index]['min_amount'];
    }
    shippingType.cost = await _getShippingPrice(index);

    CheckoutSession.getInstance.shippingType = shippingType;

    Navigator.pop(context);
  }
}
