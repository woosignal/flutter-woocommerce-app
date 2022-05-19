//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/shipping_type.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/shipping_method.dart';

class CheckoutShippingTypePage extends StatefulWidget {
  CheckoutShippingTypePage();

  @override
  _CheckoutShippingTypePageState createState() =>
      _CheckoutShippingTypePageState();
}

class _CheckoutShippingTypePageState extends State<CheckoutShippingTypePage> {
  _CheckoutShippingTypePageState();

  bool _isShippingSupported = true, _isLoading = true;
  final List<Map<String, dynamic>> _wsShippingOptions = [];
  WSShipping? _shipping;

  @override
  void initState() {
    super.initState();
    _getShippingMethods();
  }

  _getShippingMethods() async {
    List<WSShipping> wsShipping =
        await (appWooSignal((api) => api.getShippingMethods()));

    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails!.shippingAddress!;
    String? postalCode = customerAddress.postalCode;
    CustomerCountry? customerCountry = customerAddress.customerCountry;

    if (customerCountry == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    for (final shipping in wsShipping) {
      if (shipping.locations == null) {
        continue;
      }

      Locations? location = shipping.locations!.firstWhereOrNull(
        (ws) {
          if (customerCountry.countryCode == null || ws.code == null) {
            return false;
          }

          if (ws.type == "state") {
            if (customerCountry.state != null &&
                (customerCountry.state?.code ?? "") != "") {
              return ws.code == customerCountry.state!.code;
            }
          }

          if (ws.type == "postcode" && ws.code == postalCode) {
            return true;
          }

          if (ws.type == "country" && ws.code == customerCountry.countryCode) {
            return true;
          }

          return false;
        },
      );

      if (location != null) {
        _shipping = shipping;
        break;
      }
    }

    await _handleShippingZones(_shipping);

    if (_shipping == null) {
      WSShipping? noZones =
          wsShipping.firstWhereOrNull((element) => element.parentId == 0);
      await _handleShippingZones(noZones);
    }
    if (_wsShippingOptions.isEmpty) {
      _isShippingSupported = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _getShippingPrice(int index) async {
    double total = 0;
    List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();

    total += (await (workoutShippingCostWC(
            sum: _wsShippingOptions[index]['cost']))) ??
        0;

    switch (_wsShippingOptions[index]['method_id']) {
      case "flat_rate":
        FlatRate? flatRate = (_wsShippingOptions[index]['object'] as FlatRate?);

        if (cartLineItem.firstWhereOrNull(
                (t) => t.shippingClassId == null || t.shippingClassId == "0") !=
            null) {
          total += await (workoutShippingClassCostWC(
                  sum: flatRate!.classCost,
                  cartLineItem: cartLineItem
                      .where((t) =>
                          t.shippingClassId == null || t.shippingClassId == "0")
                      .toList())) ??
              0;
        }

        List<CartLineItem> cItemsWithShippingClasses = cartLineItem
            .where((t) => t.shippingClassId != null && t.shippingClassId != "0")
            .toList();
        for (int i = 0; i < cItemsWithShippingClasses.length; i++) {
          ShippingClasses? shippingClasses = flatRate!.shippingClasses!
              .firstWhereOrNull(
                  (d) => d.id == cItemsWithShippingClasses[i].shippingClassId);
          if (shippingClasses != null) {
            double classTotal = await (workoutShippingClassCostWC(
                    sum: shippingClasses.cost,
                    cartLineItem: cartLineItem
                        .where((g) => g.shippingClassId == shippingClasses.id)
                        .toList())) ??
                0;
            total += classTotal;
          }
        }
        break;
      default:
        break;
    }
    return (total).toString();
  }

  _handleShippingZones(WSShipping? shipping) async {
    if (shipping != null && shipping.methods != null) {
      if (shipping.methods!.flatRate != null) {
        shipping.methods!.flatRate!.toList().forEach((flatRate) {
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

      if (shipping.methods!.localPickup != null) {
        shipping.methods!.localPickup!.toList().forEach((localPickup) {
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

      if (shipping.methods!.freeShipping != null) {
        List<FreeShipping> freeShipping = shipping.methods!.freeShipping!;

        for (int i = 0; i < freeShipping.length; i++) {
          if (isNumeric(freeShipping[i].cost) ||
              freeShipping[i].cost == 'min_amount') {
            if (freeShipping[i].cost == 'min_amount') {
              String total = await Cart.getInstance.getTotal();

              double doubleTotal = double.parse(total);
              double doubleMinimumValue =
                  double.parse(freeShipping[i].minimumOrderAmount!);

              if (doubleTotal < doubleMinimumValue) {
                continue;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Shipping Methods")),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image.asset(
                      getImageAsset('shipping_icon.png'),
                      height: 100,
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? null
                          : Colors.white,
                      fit: BoxFit.fitHeight,
                    ),
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
                            ? Expanded(child: AppLoaderWidget())
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
                                            left: 16,
                                            right: 16,
                                          ),
                                          title: Text(
                                            _wsShippingOptions[index]['title'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                                  if (snapshot.hasError) {
                                                    return Text('');
                                                  } else {
                                                    Map<String, dynamic>
                                                        shippingOption =
                                                        _wsShippingOptions[
                                                            index];
                                                    return RichText(
                                                      text: TextSpan(
                                                        text: '',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        children: <TextSpan>[
                                                          (shippingOption[
                                                                      "object"]
                                                                  is FreeShipping
                                                              ? TextSpan(
                                                                  text: trans(
                                                                      "Free postage"),
                                                                )
                                                              : TextSpan(
                                                                  text:
                                                                      "${trans("Price")}: ${formatStringCurrency(total: snapshot.data)}",
                                                                )),
                                                          if (shippingOption[
                                                                  "min_amount"] !=
                                                              null)
                                                            TextSpan(
                                                                text: "\n${trans("Spend a minimum of")} " +
                                                                    formatStringCurrency(
                                                                        total: shippingOption[
                                                                            "min_amount"]),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText2!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14))
                                                        ],
                                                      ),
                                                    );
                                                  }
                                              }
                                            },
                                          ),
                                          trailing: (CheckoutSession.getInstance
                                                          .shippingType !=
                                                      null &&
                                                  CheckoutSession
                                                          .getInstance
                                                          .shippingType!
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
                                    trans(
                                        "Shipping is not supported for your country, sorry"),
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                    textAlign: TextAlign.center,
                                  ))),
                        LinkButton(
                          title: trans("CANCEL"),
                          action: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context)!.backgroundContainer,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
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
    Map<String, dynamic> shippingOptions = _wsShippingOptions[index];
    ShippingType shippingType = ShippingType(
        methodId: shippingOptions['method_id'],
        object: shippingOptions['object'],
        cost: (await _getShippingPrice(index)),
        minimumValue: null);

    if (_wsShippingOptions[index]['min_amount'] != null) {
      shippingType.minimumValue = _wsShippingOptions[index]['min_amount'];
    }

    CheckoutSession.getInstance.shippingType = shippingType;

    Navigator.pop(context);
  }
}
