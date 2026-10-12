import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Order payload tests.
///
/// `buildOrderWC` is the last thing that runs before an order is posted to a
/// merchant's store, and it is the one piece of the app whose output a merchant
/// sees directly: the gateway the order is attributed to, the status it lands
/// in, the address it ships to. Every field here corresponds to a column on the
/// WooCommerce order screen.
void main() {
  NyTest.init();

  /// What the payload says about the platform. Derived rather than hard coded
  /// so the suite gives the same answer on every host.
  final String platformName = Platform.isAndroid ? "Android App" : "iOS App";

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    resetCheckoutSession();
    await clearCart();
    await clearWpUser();
  });

  /// Set the payment gateway the order is being placed with.
  void useGateway(String name) {
    CheckoutSession.getInstance.paymentType = PaymentType(
        id: 1, name: name, desc: "", assetImage: "", pay: () async {});
  }

  nyGroup('payment method', () {
    nyTest('maps each shipped gateway to its WooCommerce id', () async {
      seedCheckoutSession();

      Map<String, String> expected = {
        "Stripe": "stripe",
        "CashOnDelivery": "cod",
        "PayPal": "paypal",
      };

      for (MapEntry<String, String> entry in expected.entries) {
        useGateway(entry.key);
        OrderWC orderWC = await buildOrderWC();

        expect(orderWC.paymentMethod, entry.value,
            reason: '"${entry.key}" must post as the gateway id '
                '"${entry.value}", or WooCommerce cannot tie the order to a '
                'registered gateway');
      }
    });

    nyTest('falls back to the lowercased name for a custom gateway', () async {
      seedCheckoutSession();
      useGateway("MyNewPaymentMethod");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.paymentMethod, "mynewpaymentmethod");
      // Nothing to look the label up from, so the name is used as written.
      expect(orderWC.paymentMethodTitle,
          "MyNewPaymentMethod ($platformName)");
    });

    nyTest('titles the order with the readable gateway name and the platform',
        () async {
      seedCheckoutSession();

      Map<String, String> expected = {
        "Stripe": "Stripe",
        "CashOnDelivery": "Cash on delivery",
        "PayPal": "PayPal",
      };

      for (MapEntry<String, String> entry in expected.entries) {
        useGateway(entry.key);
        OrderWC orderWC = await buildOrderWC();

        expect(orderWC.paymentMethodTitle, "${entry.value} ($platformName)");
      }
    });
  });

  nyGroup('status and payment', () {
    nyTest('a paid order is created pending and marked paid', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC(markPaid: true);

      // WooCommerce advances a `pending` + `set_paid` order to
      // processing/completed itself.
      expect(orderWC.status, "pending");
      expect(orderWC.setPaid, isTrue);
    });

    nyTest('an unpaid order is created processing and not marked paid',
        () async {
      seedCheckoutSession();
      useGateway("CashOnDelivery");

      OrderWC orderWC = await buildOrderWC(markPaid: false);

      // Cash on delivery: stock is reduced and the order is ready to fulfil.
      expect(orderWC.status, "processing");
      expect(orderWC.setPaid, isFalse);
    });

    nyTest('records the transaction id in the core field and in our own meta',
        () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC(transactionId: "pi_12345");

      expect(orderWC.transactionId, "pi_12345");
      expect(orderWC.metaData, isNotNull);
      expect(orderWC.metaData!.length, 1);
      // Gateway plugins overwrite `transaction_id` freely, so reconciliation
      // needs a copy that stays put.
      expect(orderWC.metaData!.first.key, "_woosignal_payment_ref");
      expect(orderWC.metaData!.first.value, "pi_12345");
    });

    nyTest('leaves the transaction id and meta off when there is none',
        () async {
      seedCheckoutSession();
      useGateway("CashOnDelivery");

      for (String? transactionId in [null, ""]) {
        OrderWC orderWC = await buildOrderWC(transactionId: transactionId);

        expect(orderWC.transactionId, isNull);
        expect(orderWC.metaData, isNull);
      }
    });
  });

  nyGroup('customer', () {
    nyTest('a guest order carries no customer id', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.customerId, isNull);
    });

    nyTest('a signed in customer is attached to the order', () async {
      await seedWpUser(id: 42);
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.customerId, 42);
    });

    nyTest('an expired session is not attached to the order', () async {
      // wp_json_api 5 tokens expire; the order goes through as a guest one.
      await seedWpUser(
          id: 42,
          expiresAt: DateTime.now()
                  .subtract(const Duration(minutes: 1))
                  .millisecondsSinceEpoch ~/
              1000);
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.customerId, isNull);
    });

    nyTest('a session saved by wp_json_api 4.x is not attached', () async {
      await seedWpUser(id: 42, legacySession: true);
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.customerId, isNull);
    });

    nyTest('a signed in customer is ignored when WordPress logins are off',
        () async {
      await seedWpUser(id: 42);
      seedAppConfig(wooSignalApp: wooSignalAppFixture(wpLoginEnabled: 0));
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.customerId, isNull);
    });
  });

  nyGroup('addresses', () {
    nyTest('sends ISO state and country codes, not display names', () async {
      seedCheckoutSession(
          billingAddress: customerAddressFixture(
              countryCode: "US",
              countryName: "United States",
              stateCode: "US:AL",
              stateName: "Alabama"));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      // Shipping zones and state tax rates match on the code, never the name.
      expect(orderWC.billing!.state, "AL");
      expect(orderWC.billing!.country, "US");
      expect(orderWC.shipping!.state, "AL");
      expect(orderWC.shipping!.country, "US");
    });

    nyTest('passes a state code that carries no country prefix straight through',
        () async {
      seedCheckoutSession(
          billingAddress: customerAddressFixture(
              stateCode: "AL", stateName: "Alabama"));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.billing!.state, "AL");
    });

    nyTest('leaves the state off for a country that has none', () async {
      seedCheckoutSession(
          billingAddress: customerAddressFixture(
              countryCode: "SG",
              countryName: "Singapore",
              stateCode: null,
              stateName: null));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.billing!.state, isNull);
      expect(orderWC.billing!.country, "SG");
    });

    nyTest('copies the rest of the billing address across', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.billing!.firstName, "Anthony");
      expect(orderWC.billing!.lastName, "Gordon");
      expect(orderWC.billing!.address1, "1 Test Street");
      expect(orderWC.billing!.city, "Birmingham");
      expect(orderWC.billing!.postcode, "AL1 1AA");
      expect(orderWC.billing!.email, "test@example.test");
      expect(orderWC.billing!.phone, "07000000000");
    });

    nyTest('leaves an empty phone number off the billing address', () async {
      seedCheckoutSession(
          billingAddress: customerAddressFixture(phoneNumber: ""));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.billing!.phone, isNull);
    });

    nyTest('ships to the shipping address, which can differ from billing',
        () async {
      seedCheckoutSession(
          billingAddress: customerAddressFixture(city: "Birmingham"),
          shippingAddress: customerAddressFixture(
              firstName: "Jane", lastName: "Doe", city: "Leeds"));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.billing!.city, "Birmingham");
      expect(orderWC.shipping!.firstName, "Jane");
      expect(orderWC.shipping!.lastName, "Doe");
      expect(orderWC.shipping!.city, "Leeds");
    });
  });

  nyGroup('line items', () {
    nyTest('carries every cart line with its quantity and line subtotal',
        () async {
      await seedCart([
        cartLineItemFixture(
            name: "Blue Shirt", productId: 1, quantity: 2, subtotal: "10.00"),
        cartLineItemFixture(
            name: "Red Hat", productId: 2, quantity: 1, subtotal: "7.50"),
      ]);
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.lineItems!.length, 2);
      expect(orderWC.lineItems![0].name, "Blue Shirt");
      expect(orderWC.lineItems![0].productId, 1);
      expect(orderWC.lineItems![0].quantity, 2);
      expect(orderWC.lineItems![0].subtotal, "20.0");
      expect(orderWC.lineItems![1].name, "Red Hat");
      expect(orderWC.lineItems![1].quantity, 1);
      expect(orderWC.lineItems![1].subtotal, "7.5");
    });

    nyTest('sends a variation id only when the line has a real one', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, variationId: 99),
        cartLineItemFixture(productId: 2, variationId: 0),
        cartLineItemFixture(productId: 3),
      ]);
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.lineItems![0].variationId, 99);
      // 0 is "no variation" in WooCommerce and must not be sent.
      expect(orderWC.lineItems![1].variationId, isNull);
      expect(orderWC.lineItems![2].variationId, isNull);
    });

    nyTest('an empty cart produces an empty line item list', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.lineItems, isEmpty);
    });
  });

  nyGroup('shipping, coupons, tax and notes', () {
    nyTest('adds the chosen shipping method as a shipping line', () async {
      seedCheckoutSession(
          shippingType: flatRateShippingFixture(cost: "4.99", title: "Standard"));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.shippingLines!.length, 1);
      expect(orderWC.shippingLines!.first.methodId, "flat_rate");
      expect(orderWC.shippingLines!.first.methodTitle, "Standard");
      expect(orderWC.shippingLines!.first.total, "4.99");
    });

    nyTest('sends no shipping line when the store has shipping switched off',
        () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(disableShipping: 1));
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.shippingLines, isEmpty);
    });

    nyTest('builds the order when shipping is on but none was chosen',
        () async {
      // A customer can reach the confirmation page without a shipping method:
      // the shipping methods call failed, the store toggled shipping on after
      // they started, or no method matched their address. The order still has
      // to be placeable - it just carries no shipping line.
      seedAppConfig(wooSignalApp: wooSignalAppFixture(disableShipping: 0));
      seedCheckoutSession();
      CheckoutSession.getInstance.shippingType = null;
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.shippingLines, isEmpty);
      // And the rest of the order is intact.
      expect(orderWC.paymentMethod, "stripe");
      expect(orderWC.billing!.firstName, "Anthony");
      expect(orderWC.currency, "USD");
    });

    nyTest('builds the order when shipping is off and none was chosen',
        () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(disableShipping: 1));
      seedCheckoutSession();
      CheckoutSession.getInstance.shippingType = null;
      useGateway("CashOnDelivery");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.shippingLines, isEmpty);
      expect(orderWC.paymentMethod, "cod");
    });

    nyTest('a shipping type with no method behind it adds no line', () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(disableShipping: 0));
      seedCheckoutSession();
      CheckoutSession.getInstance.shippingType!.object = null;
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.shippingLines, isEmpty);
    });

    nyTest('adds the coupon the customer redeemed', () async {
      seedCheckoutSession(coupon: couponFixture(code: "SAVE10"));
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.couponLines!.length, 1);
      expect(orderWC.couponLines!.first.code, "SAVE10");
    });

    nyTest('sends no coupon lines when none was redeemed', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.couponLines, isNull);
    });

    nyTest('adds tax as a taxable fee line', () async {
      await seedCart([
        cartLineItemFixture(quantity: 1, subtotal: "100.00")
      ]);
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 1));
      seedCheckoutSession(
          shippingType: flatRateShippingFixture(cost: "0", taxable: false));
      useGateway("Stripe");

      OrderWC orderWC =
          await buildOrderWC(taxRate: taxRateFixture(rate: "20.0", name: "VAT"));

      expect(orderWC.feeLines!.length, 1);
      expect(orderWC.feeLines!.first.name, "VAT");
      expect(orderWC.feeLines!.first.total, "20.00");
      expect(orderWC.feeLines!.first.taxStatus, "taxable");
      expect(orderWC.feeLines!.first.taxClass, "");
    });

    nyTest('sends no fee lines when there is no tax rate', () async {
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      expect(orderWC.feeLines, isNull);
    });

    nyTest('passes the customer note through only when it has content',
        () async {
      useGateway("Stripe");

      seedCheckoutSession(customerNote: "Leave with a neighbour");
      expect((await buildOrderWC()).customerNote, "Leave with a neighbour");

      seedCheckoutSession(customerNote: "");
      expect((await buildOrderWC()).customerNote, isNull);

      seedCheckoutSession();
      expect((await buildOrderWC()).customerNote, isNull);
    });
  });

  nyGroup('currency', () {
    nyTest('upper-cases the store currency code', () async {
      seedAppConfig(wooSignalApp: wooSignalAppFixture(currencyCode: "gbp"));
      seedCheckoutSession();
      useGateway("Stripe");

      OrderWC orderWC = await buildOrderWC();

      // WooCommerce rejects a lowercase currency code.
      expect(orderWC.currency, "GBP");
    });
  });
}
