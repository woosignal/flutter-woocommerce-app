import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/billing_details.dart';
import 'package:flutter_app/app/models/bottom_nav_item.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/app/models/default_shipping.dart';
import 'package:flutter_app/app/models/notification_item.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/models/shipping_type.dart';
import 'package:flutter/material.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Model tests.
///
/// Everything in `lib/app/models/` that a customer's device persists or that
/// the checkout reads. The JSON round trips matter most: the cart, the billing
/// address and the shipping address are all written to the device, so a change
/// to one of these shapes silently drops data on the next app update.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
  });

  nyGroup('CartLineItem', () {
    nyTest('survives a JSON round trip', () async {
      CartLineItem cartLineItem = cartLineItemFixture(
          name: "Blue Shirt",
          productId: 55,
          variationId: 66,
          quantity: 3,
          subtotal: "12.50",
          total: "12.50",
          variationOptions: "Blue; Large");

      CartLineItem restored =
          CartLineItem.fromJson(jsonDecode(jsonEncode(cartLineItem.toJson())));

      expect(restored.name, "Blue Shirt");
      expect(restored.productId, 55);
      expect(restored.variationId, 66);
      expect(restored.quantity, 3);
      expect(restored.subtotal, "12.50");
      expect(restored.total, "12.50");
      expect(restored.variationOptions, "Blue; Large");
      expect(restored.taxStatus, "taxable");
      expect(restored.stockStatus, "instock");
      expect(restored.imageSrc, "https://example.test/image.png");
      expect(restored.categories!.first.id, 15);
      expect(restored.categories!.first.name, "Clothing");
    });

    nyTest('defaults a missing quantity argument to 1', () async {
      expect(CartLineItem(productId: 1).quantity, 1);
    });

    nyTest('reads a null is_managed_stock as false', () async {
      // The field is nullable in the payload but drives an `if` in the
      // quantity stepper, so it has to land as a real bool.
      Map<String, dynamic> json = cartLineItemFixture().toJson();
      json['is_managed_stock'] = null;

      expect(CartLineItem.fromJson(json).isManagedStock, false);

      json['is_managed_stock'] = "true"; // not a bool
      expect(CartLineItem.fromJson(json).isManagedStock, false);
    });

    nyTest('keeps a null categories list null and writes it back as empty',
        () async {
      Map<String, dynamic> json = cartLineItemFixture().toJson();
      json['categories'] = null;

      CartLineItem restored = CartLineItem.fromJson(json);
      expect(restored.categories, isNull);
      expect(restored.toJson()['categories'], isEmpty);
    });

    nyTest('tolerates both app_meta_data shapes', () async {
      // The shape changed from {key: value} to {"key": ..., "value": ...} and
      // the cart is persisted, so a device upgrading from an older build still
      // has the old shape sitting in storage.
      Map<String, dynamic> legacy = cartLineItemFixture().toJson();
      legacy['app_meta_data'] = [
        {"_colour": "blue"}
      ];
      CartLineItem fromLegacy = CartLineItem.fromJson(legacy);
      expect(fromLegacy.appMetaData, [
        {"_colour": "blue"}
      ]);

      Map<String, dynamic> current = cartLineItemFixture().toJson();
      current['app_meta_data'] = [
        {"key": "_colour", "value": "blue"}
      ];
      CartLineItem fromCurrent = CartLineItem.fromJson(current);
      expect(fromCurrent.appMetaData, [
        {"key": "_colour", "value": "blue"}
      ]);

      // Both shapes round trip back out unchanged.
      expect(fromLegacy.toJson()['app_meta_data'], legacy['app_meta_data']);
      expect(fromCurrent.toJson()['app_meta_data'], current['app_meta_data']);
    });

    nyTest('reads a missing meta_data as an empty list', () async {
      Map<String, dynamic> json = cartLineItemFixture().toJson();
      json.remove('meta_data');
      json.remove('app_meta_data');

      CartLineItem restored = CartLineItem.fromJson(json);
      expect(restored.metaData, isEmpty);
      expect(restored.appMetaData, isEmpty);
    });

    nyTest('multiplies the line total by the quantity', () async {
      expect(
          cartLineItemFixture(quantity: 3, subtotal: "12.50").getCartTotal(),
          "37.50");
      // A price that will not parse counts as zero rather than throwing.
      expect(cartLineItemFixture(quantity: 2, subtotal: "").getCartTotal(),
          "0.00");
    });

    nyTest('reports the unit price, optionally formatted', () async {
      CartLineItem cartLineItem =
          cartLineItemFixture(quantity: 4, subtotal: "9.5");

      expect(cartLineItem.getPrice(), "9.50");
      expect(cartLineItem.getPrice(formatToCurrency: true), r"$9.50");
    });

    nyTest('builds from a product', () async {
      ws_product.Product product = productFixture(overrides: {
        'meta_data': [
          {'id': 1, 'key': "_custom", 'value': "yes"}
        ]
      });

      CartLineItem cartLineItem =
          CartLineItem.fromProduct(quantityAmount: 2, product: product);

      expect(cartLineItem.name, "Test Product");
      expect(cartLineItem.productId, 101);
      expect(cartLineItem.variationId, isNull);
      expect(cartLineItem.quantity, 2);
      expect(cartLineItem.subtotal, "10.00");
      expect(cartLineItem.total, "10.00");
      expect(cartLineItem.taxStatus, "taxable");
      expect(cartLineItem.imageSrc, "https://example.test/image.png");
      // The two meta shapes are built side by side from the same source.
      expect(cartLineItem.metaData, [
        {"_custom": "yes"}
      ]);
      expect(cartLineItem.appMetaData, [
        {"key": "_custom", "value": "yes"}
      ]);
    });

    nyTest('falls back to the placeholder image when a product has none',
        () async {
      CartLineItem cartLineItem = CartLineItem.fromProduct(
          product: productFixture(overrides: {'images': []}));

      expect(cartLineItem.imageSrc, getEnv("PRODUCT_PLACEHOLDER_IMAGE"));
    });
  });

  nyGroup('CustomerAddress', () {
    nyTest('survives a JSON round trip', () async {
      CustomerAddress address = customerAddressFixture();

      CustomerAddress restored =
          CustomerAddress.fromJson(jsonDecode(jsonEncode(address.toJson())));

      expect(restored.firstName, "Anthony");
      expect(restored.lastName, "Gordon");
      expect(restored.addressLine, "1 Test Street");
      expect(restored.city, "Birmingham");
      expect(restored.postalCode, "AL1 1AA");
      expect(restored.emailAddress, "test@example.test");
      expect(restored.phoneNumber, "07000000000");
      expect(restored.customerCountry!.countryCode, "US");
      expect(restored.customerCountry!.name, "United States");
      expect(restored.customerCountry!.state!.code, "US:AL");
      expect(restored.customerCountry!.state!.name, "Alabama");
    });

    nyTest('drops an empty phone number from the payload', () async {
      CustomerAddress address = customerAddressFixture(phoneNumber: "");

      expect(address.toJson().containsKey('phone_number'), isFalse);
    });

    nyTest('initAddress gives every field an empty string', () async {
      CustomerAddress address = CustomerAddress();
      address.initAddress();

      expect(address.firstName, "");
      expect(address.lastName, "");
      expect(address.addressLine, "");
      expect(address.city, "");
      expect(address.postalCode, "");
      expect(address.emailAddress, "");
      expect(address.phoneNumber, "");
      expect(address.customerCountry, isNotNull);
    });

    nyTest('hasMissingFields spots each required field', () async {
      expect(customerAddressFixture().hasMissingFields(), isFalse);

      expect(customerAddressFixture(firstName: "").hasMissingFields(), isTrue);
      expect(customerAddressFixture(lastName: "").hasMissingFields(), isTrue);
      expect(
          customerAddressFixture(addressLine: "").hasMissingFields(), isTrue);
      expect(customerAddressFixture(city: "").hasMissingFields(), isTrue);
      expect(customerAddressFixture(postalCode: "").hasMissingFields(), isTrue);

      // A country with no state does not need one.
      expect(
          customerAddressFixture(stateCode: null, stateName: null)
              .hasMissingFields(),
          isFalse);
      // A country that does have a state needs it named.
      expect(
          customerAddressFixture(stateCode: "US:AL", stateName: "")
              .hasMissingFields(),
          isTrue);
    });

    nyTest('addressFull joins only the parts that are set', () async {
      expect(customerAddressFixture().addressFull(),
          "1 Test Street, Birmingham, AL1 1AA, Alabama, United States");

      expect(
          customerAddressFixture(
                  addressLine: "", city: "", stateCode: null, stateName: null)
              .addressFull(),
          "AL1 1AA, United States");
    });

    nyTest('nameFull joins the names it has', () async {
      expect(customerAddressFixture().nameFull(), "Anthony, Gordon");
      expect(customerAddressFixture(lastName: "").nameFull(), "Anthony");
      expect(customerAddressFixture(firstName: "", lastName: "").nameFull(), "");
    });

    nyTest('toUserMetaDataItem strips the country from the state code',
        () async {
      List<dynamic> billing =
          customerAddressFixture().toUserMetaDataItem("billing");

      Map<String?, dynamic> byKey = {
        for (var meta in billing) meta.key: meta.value
      };

      expect(byKey['billing_first_name'], "Anthony");
      expect(byKey['billing_last_name'], "Gordon");
      expect(byKey['billing_address_1'], "1 Test Street");
      expect(byKey['billing_city'], "Birmingham");
      expect(byKey['billing_postcode'], "AL1 1AA");
      expect(byKey['billing_phone'], "07000000000");
      expect(byKey['billing_email'], "test@example.test");
      expect(byKey['billing_country'], "US");
      // "US:AL" is stored, but WordPress wants the bare state.
      expect(byKey['billing_state'], "AL");
    });

    nyTest('toUserMetaDataItem leaves the email off a shipping address',
        () async {
      List<dynamic> shipping =
          customerAddressFixture().toUserMetaDataItem("shipping");

      expect(shipping.where((meta) => meta.key == "shipping_email"), isEmpty);
      expect(shipping.where((meta) => meta.key == "shipping_state").first.value,
          "AL");
    });
  });

  nyGroup('CustomerCountry', () {
    nyTest('survives a JSON round trip', () async {
      CustomerCountry country = CustomerCountry(
          countryCode: "GB",
          name: "United Kingdom",
          state: DefaultShippingState(code: "GB:BIR", name: "Birmingham"));

      CustomerCountry restored =
          CustomerCountry.fromJson(jsonDecode(jsonEncode(country.toJson())));

      expect(restored.countryCode, "GB");
      expect(restored.name, "United Kingdom");
      expect(restored.state!.code, "GB:BIR");
      expect(restored.state!.name, "Birmingham");
    });

    nyTest('accepts a null payload without throwing', () async {
      CustomerCountry restored = CustomerCountry.fromJson(null);

      expect(restored.countryCode, isNull);
      expect(restored.name, isNull);
      expect(restored.state, isNull);
    });

    nyTest('hasState is true only when the state is named', () async {
      expect(CustomerCountry().hasState(), isFalse);
      expect(
          CustomerCountry(
                  state: DefaultShippingState(code: "US:AL", name: null))
              .hasState(),
          isFalse);
      expect(
          CustomerCountry(
                  state: DefaultShippingState(code: "US:AL", name: "Alabama"))
              .hasState(),
          isTrue);
    });

    nyTest('takes the only state a country has from default shipping',
        () async {
      CustomerCountry one = CustomerCountry.fromDefaultShipping(
          defaultShipping: DefaultShipping(code: "SG", country: "Singapore", states: [
        DefaultShippingState(code: "SG:01", name: "Singapore")
      ]));
      expect(one.countryCode, "SG");
      expect(one.state!.name, "Singapore");

      // More than one state, and the customer has to pick.
      CustomerCountry many = CustomerCountry.fromDefaultShipping(
          defaultShipping: DefaultShipping(code: "US", country: "United States", states: [
        DefaultShippingState(code: "US:AL", name: "Alabama"),
        DefaultShippingState(code: "US:AK", name: "Alaska"),
      ]));
      expect(many.state, isNull);
    });
  });

  nyGroup('DefaultShippingState', () {
    nyTest('survives a JSON round trip', () async {
      DefaultShippingState state =
          DefaultShippingState(code: "US:AL", name: "Alabama");

      DefaultShippingState restored =
          DefaultShippingState.fromJson(jsonDecode(jsonEncode(state.toJson())));

      expect(restored.code, "US:AL");
      expect(restored.name, "Alabama");
    });
  });

  nyGroup('NotificationItem', () {
    nyTest('survives a JSON round trip', () async {
      NotificationItem item = NotificationItem(
          id: "n1",
          title: "Your order shipped",
          message: "Order #12 is on its way",
          type: "order",
          meta: {"order_id": "12"},
          createdAt: "2026-01-01 10:00:00");

      NotificationItem restored =
          NotificationItem.fromJson(jsonDecode(jsonEncode(item.toJson())));

      expect(restored.id, "n1");
      expect(restored.title, "Your order shipped");
      expect(restored.message, "Order #12 is on its way");
      expect(restored.type, "order");
      expect(restored.meta, {"order_id": "12"});
      expect(restored.createdAt, "2026-01-01 10:00:00");
      expect(restored.hasRead, false);
    });

    nyTest('starts unread', () async {
      expect(NotificationItem().hasRead, false);
    });

    nyTest('the instance fromJson overwrites in place', () async {
      NotificationItem item = NotificationItem(title: "Old");
      item.fromJson({"title": "New", "has_read": true});

      expect(item.title, "New");
      expect(item.hasRead, true);
    });
  });

  nyGroup('ShippingType', () {
    nyTest('reads the title off the method it wraps', () async {
      expect(flatRateShippingFixture(title: "Standard").getTitle(), "Standard");
      expect(localPickupShippingFixture().getTitle(), "Local pickup");
      expect(freeShippingFixture().getTitle(), "Free shipping");
      // Nothing to read from.
      expect(
          ShippingType(methodId: "flat_rate", cost: "1", minimumValue: null)
              .getTitle(),
          "");
      expect(
          ShippingType(
                  methodId: "something_else",
                  cost: "1",
                  minimumValue: null,
                  object: Object())
              .getTitle(),
          "");
    });

    nyTest('reports its cost raw or formatted', () async {
      ShippingType shippingType = flatRateShippingFixture(cost: "5.00");

      expect(shippingType.getTotal(), "5.00");
      expect(shippingType.getTotal(withFormatting: true), r"$5.00");

      expect(
          ShippingType(methodId: "flat_rate", cost: "5", minimumValue: null)
              .getTotal(),
          "0");
    });

    nyTest('builds the WooCommerce shipping line', () async {
      expect(flatRateShippingFixture(cost: "4.99").toShippingLineFee(), {
        'method_title': "Flat rate",
        'method_id': "flat_rate",
        'total': "4.99",
      });

      expect(localPickupShippingFixture(cost: "0").toShippingLineFee(), {
        'method_title': "Local pickup",
        'method_id': "local_pickup",
        'total': "0",
      });

      expect(freeShippingFixture().toShippingLineFee(), {
        'method_title': "Free shipping",
        'method_id': "free_shipping",
        'total': "0",
      });

      // No method object, or a method the app does not know: no line.
      expect(
          ShippingType(methodId: "flat_rate", cost: "1", minimumValue: null)
              .toShippingLineFee(),
          isNull);
      expect(
          ShippingType(
                  methodId: "pigeon",
                  cost: "1",
                  minimumValue: null,
                  object: Object())
              .toShippingLineFee(),
          isNull);
    });

    nyTest('serialises its own fields', () async {
      ShippingType shippingType = flatRateShippingFixture(cost: "3.00");
      Map<String, dynamic> json = shippingType.toJson();

      expect(json['methodId'], "flat_rate");
      expect(json['cost'], "3.00");
      expect(json['minimumValue'], isNull);
      expect(json['object'], isNotNull);
    });
  });

  nyGroup('BillingDetails', () {
    nyTest('initSession gives it both addresses', () async {
      BillingDetails billingDetails = BillingDetails();
      expect(billingDetails.billingAddress, isNull);

      billingDetails.initSession();

      expect(billingDetails.billingAddress, isNotNull);
      expect(billingDetails.shippingAddress, isNotNull);
    });

    nyTest('createStripeDetails maps the address Stripe expects', () async {
      BillingDetails billingDetails = BillingDetails();
      billingDetails.billingAddress = customerAddressFixture();
      billingDetails.shippingAddress = customerAddressFixture(
          firstName: "Jane", lastName: "Doe", city: "Leeds");

      Map<String, dynamic> stripe = billingDetails.createStripeDetails();

      expect(stripe['address'], {
        'line1': "1 Test Street",
        'city': "Birmingham",
        'postal_code': "AL1 1AA",
        'state': "Alabama",
        'country': "US",
      });
      expect(stripe['shipping']['name'], "Jane, Doe");
      expect(stripe['shipping']['city'], "Leeds");
      expect(stripe['email'], "test@example.test");
      expect(stripe['name'], "Anthony, Gordon");
      expect(stripe['phone'], "07000000000");
    });

    nyTest('createStripeDetails leaves out what it does not have', () async {
      BillingDetails billingDetails = BillingDetails();
      billingDetails.billingAddress = CustomerAddress();
      billingDetails.shippingAddress = CustomerAddress();

      Map<String, dynamic> stripe = billingDetails.createStripeDetails();

      expect(stripe['address'], isEmpty);
      expect(stripe.containsKey('email'), isFalse);
      expect(stripe.containsKey('phone'), isFalse);
    });

    nyTest('getShippingAddressStripe uses the country name', () async {
      BillingDetails billingDetails = BillingDetails();
      billingDetails.shippingAddress = customerAddressFixture();

      expect(billingDetails.getShippingAddressStripe(), {
        "name": "Anthony, Gordon",
        "line1": "1 Test Street",
        "city": "Birmingham",
        "postal_code": "AL1 1AA",
        "country": "United States",
      });
    });

    nyTest('fromWpMeta splits billing_ and shipping_ prefixes', () async {
      BillingDetails billingDetails = BillingDetails();

      await billingDetails.fromWpMeta({
        'billing_first_name': "Anthony",
        'billing_last_name': "Gordon",
        'billing_address_1': "1 Test Street",
        'billing_city': "Birmingham",
        'billing_postcode': "AL1 1AA",
        'billing_email': "test@example.test",
        'billing_phone': "07000000000",
        'shipping_first_name': "Jane",
        'shipping_last_name': "Doe",
        'shipping_city': "Leeds",
      });

      expect(billingDetails.billingAddress!.firstName, "Anthony");
      expect(billingDetails.billingAddress!.city, "Birmingham");
      expect(billingDetails.billingAddress!.emailAddress, "test@example.test");
      expect(billingDetails.shippingAddress!.firstName, "Jane");
      expect(billingDetails.shippingAddress!.city, "Leeds");
      // No country in the meta, so no country was looked up.
      expect(billingDetails.billingAddress!.customerCountry, isNull);
    });
  });

  nyGroup('PaymentType and BottomNavItem', () {
    nyTest('a payment type carries what the checkout list renders', () async {
      bool paid = false;
      PaymentType paymentType = PaymentType(
          id: 9,
          name: "TestPay",
          desc: "Pay with test",
          assetImage: "testpay.png",
          pay: () => paid = true);

      expect(paymentType.id, 9);
      expect(paymentType.name, "TestPay");
      expect(paymentType.desc, "Pay with test");
      expect(paymentType.assetImage, "testpay.png");
      paymentType.pay();
      expect(paid, isTrue);
    });

    nyTest('a bottom nav item pairs a bar item with its tab', () async {
      BottomNavItem item = BottomNavItem(
          id: 1,
          bottomNavigationBarItem: BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          tabWidget: SizedBox.shrink());

      expect(item.id, 1);
      expect(item.bottomNavigationBarItem.label, "Home");
      expect(item.tabWidget, isA<SizedBox>());
    });
  });
}
