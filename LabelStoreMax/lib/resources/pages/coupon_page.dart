//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/coupon.dart';

class CouponPage extends NyStatefulWidget {
  static RouteView path = ("/checkout-coupons", (_) => CouponPage());

  CouponPage({super.key}) : super(child: () => _CouponPageState());
}

/// Why a coupon cannot be redeemed, or null when it can.
///
/// These are WooCommerce's own coupon restrictions, checked on the device so a
/// customer is told why a code was refused instead of watching it silently do
/// nothing. They live out here, away from the page, because reaching them
/// through the page means first completing the `getCoupons` request that finds
/// the coupon - so this is the only way to check them on their own.
///
/// The order matters: the first rule that matches is the one the customer is
/// told about.
///
/// [productIds] are the products in the cart, [subtotal] the cart subtotal and
/// [emailAddress] the address on the billing details, all of which the rules
/// are checked against.
({String message, String id})? couponRejection({
  required Coupon coupon,
  required List<int?> productIds,
  required String? emailAddress,
  required double subtotal,
  required DateTime dateNow,
}) {
  // Check excludedProductIds
  for (var productId in productIds) {
    if (coupon.excludedProductIds!.contains(productId)) {
      return (
        message:
            "${trans('Sorry, this coupon can not be used with your cart')}.",
        id: 'info'
      );
    }
  }

  // Check email restrictions
  if (coupon.emailRestrictions!.contains(emailAddress)) {
    return (message: trans('You cannot redeem this coupon'), id: 'danger');
  }

  // Check for minimum amount
  double minimumAmount = double.parse(coupon.minimumAmount!);
  if (minimumAmount != 0 && subtotal < minimumAmount) {
    return (
      message: trans("Spend a minimum of minimumAmount to redeem", arguments: {
        "minimumAmount": formatStringCurrency(total: minimumAmount.toString())
      }),
      id: 'danger'
    );
  }

  // Check maximum amount
  double maximumAmount = double.parse(coupon.maximumAmount!);
  if (maximumAmount != 0 && subtotal > maximumAmount) {
    return (
      message: trans("Spend less than maximumAmount to redeem", arguments: {
        "maximumAmount": formatStringCurrency(total: maximumAmount.toString())
      }),
      id: 'danger'
    );
  }

  // Check if coupon has expired
  if (coupon.dateExpires != null &&
      dateNow.isAfter(
        DateTime.parse(coupon.dateExpires!),
      )) {
    return (message: trans("This coupon has expired"), id: 'warning');
  }

  // Check usage limit
  if (coupon.usageLimit != null && coupon.usageCount! >= coupon.usageLimit!) {
    return (message: trans("Usage limit has been reached"), id: 'warning');
  }

  // Check usage limit per user
  int? limitPerUser = coupon.usageLimitPerUser;
  if (limitPerUser != null &&
      coupon.usedBy!
              .map((e) => e.toLowerCase())
              .where((usedBy) => usedBy == emailAddress!.toLowerCase())
              .length >=
          limitPerUser) {
    return (
      message: "${trans('You cannot redeem this coupon')}.",
      id: 'warning'
    );
  }

  return null;
}

class _CouponPageState extends NyPage<CouponPage> {
  List<Coupon> _coupons = [];

  final couponController = TextEditingController();

  void _showAlert({required String message, String? id}) {
    showToast(
      title: trans('Coupon'),
      description: message,
      id: id ?? 'success',
    );
  }

  void _successAddCoupon(Coupon coupon) {
    _showAlert(message: trans("Added to checkout"));
    CheckoutSession.getInstance.coupon = coupon;

    pop(result: coupon);
  }

  Future<void> findCoupon(String couponCode) async {
    _coupons = await (appWooSignal(
      (api) => api.getCoupons(code: couponCode, perPage: 100),
    ));
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget view(BuildContext context) {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;
    return Scaffold(
      body: SafeAreaWidget(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Icon(Icons.local_offer_outlined, size: 30),
            Text(
              trans('Redeem Coupon'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: couponController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return trans('Please enter coupon to redeem');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 0.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 0.0),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide(
                          color: context.color.general.primaryAccent)),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: trans('Add coupon code'),
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Button.primary(
              onPressed: () => _applyCoupon(checkoutSession),
              text: trans('Apply')),
            Button.textOnly(
                text: trans("Cancel"),
                onPressed: () {
                  pop();
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _applyCoupon(CheckoutSession checkoutSession) async {
    // Validate before hitting the network so a blank code never reaches the API
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    await lockRelease('find_coupon', perform: () async {
      await findCoupon(couponController.text);
    });

    // No coupons found
    if (_coupons.isEmpty) {
      _showAlert(
          message: "${trans('Coupon not found')}.",
          id: 'warning');
      return;
    }

    Coupon coupon = _coupons.first;

    List<CartLineItem> cart = await Cart.getInstance.getCart();

    ({String message, String id})? rejection = couponRejection(
      coupon: coupon,
      productIds: cart.map((e) => e.productId).toList(),
      emailAddress:
          checkoutSession.billingDetails!.billingAddress?.emailAddress,
      subtotal: double.parse(await Cart.getInstance.getSubtotal()),
      dateNow: DateTime.now(),
    );

    if (rejection != null) {
      _showAlert(message: rejection.message, id: rejection.id);
      return;
    }

    _successAddCoupon(coupon);
  }
}
