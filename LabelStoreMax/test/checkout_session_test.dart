import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/storage_keys.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Checkout session tests.
///
/// The session is an in-memory singleton that survives between pages, plus two
/// addresses written to the device so a returning customer does not retype
/// them. Both of those storage keys are legacy strings: renaming one loses the
/// saved address.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    resetCheckoutSession();
    await clearCart();
    await CheckoutSession.getInstance.clearBillingAddress();
    await CheckoutSession.getInstance.clearShippingAddress();
  });

  nyGroup('session lifecycle', () {
    nyTest('initSession gives the session a billing details holder', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.clear();
      expect(checkoutSession.billingDetails, isNull);

      checkoutSession.initSession();

      expect(checkoutSession.billingDetails, isNotNull);
      expect(checkoutSession.shippingType, isNull);
    });

    nyTest('clear drops everything the finished order carried', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      seedCheckoutSession(
          coupon: couponFixture(), customerNote: "Leave with a neighbour");
      checkoutSession.paymentType = PaymentType(
          id: 1, name: "Stripe", desc: "", assetImage: "", pay: () {});

      checkoutSession.clear();

      expect(checkoutSession.billingDetails, isNull);
      expect(checkoutSession.shippingType, isNull);
      expect(checkoutSession.paymentType, isNull);
      expect(checkoutSession.coupon, isNull);
      // The session outlives the order, so a note left behind would be
      // pre-filled into the next checkout and posted with the next order.
      expect(checkoutSession.customerNote, isNull);
    });
  });

  nyGroup('saved addresses', () {
    nyTest('a billing address round trips through storage', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.initSession();
      checkoutSession.billingDetails!.billingAddress =
          customerAddressFixture(city: "Birmingham");

      await checkoutSession.saveBillingAddress();
      CustomerAddress? restored = await checkoutSession.getBillingAddress();

      expect(restored, isNotNull);
      expect(restored!.city, "Birmingham");
      expect(restored.firstName, "Anthony");
      expect(restored.customerCountry!.countryCode, "US");
      expect(restored.customerCountry!.state!.name, "Alabama");
    });

    nyTest('a shipping address round trips through storage', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.initSession();
      checkoutSession.billingDetails!.shippingAddress =
          customerAddressFixture(city: "Leeds");

      await checkoutSession.saveShippingAddress();
      CustomerAddress? restored = await checkoutSession.getShippingAddress();

      expect(restored!.city, "Leeds");
    });

    nyTest('reading an address that was never saved gives null', () async {
      expect(await CheckoutSession.getInstance.getBillingAddress(), isNull);
      expect(await CheckoutSession.getInstance.getShippingAddress(), isNull);
    });

    nyTest('clearing an address removes it', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.initSession();
      checkoutSession.billingDetails!.billingAddress = customerAddressFixture();
      await checkoutSession.saveBillingAddress();
      expect(await checkoutSession.getBillingAddress(), isNotNull);

      await checkoutSession.clearBillingAddress();

      expect(await checkoutSession.getBillingAddress(), isNull);
    });

    nyTest('saving with no address on the session is a no-op', () async {
      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.initSession();
      checkoutSession.billingDetails!.billingAddress = null;

      await checkoutSession.saveBillingAddress();

      expect(await checkoutSession.getBillingAddress(), isNull);
    });

    nyTest('the addresses use the legacy storage keys', () async {
      // Renaming either of these strings orphans the address already saved on
      // a customer's device.
      expect(StorageKeysConfig.customerBillingDetails, "CS_BILLING_DETAILS");
      expect(StorageKeysConfig.customerShippingDetails, "CS_SHIPPING_DETAILS");

      CheckoutSession checkoutSession = CheckoutSession.getInstance;
      checkoutSession.initSession();
      checkoutSession.billingDetails!.billingAddress = customerAddressFixture();
      await checkoutSession.saveBillingAddress();

      expect(
          await NyStorage.read(StorageKeysConfig.customerBillingDetails),
          isNotNull);
    });
  });

  nyGroup('order total', () {
    nyTest('with nothing in the cart the total is zero', () async {
      expect(await CheckoutSession.getInstance.total(), "0.00");
    });

    nyTest('is the cart total when there is no shipping or tax', () async {
      await seedCart([cartLineItemFixture(quantity: 2, subtotal: "10.00")]);

      expect(await CheckoutSession.getInstance.total(), "20.00");
    });

    nyTest('adds the cost of each kind of shipping method', () async {
      await seedCart([cartLineItemFixture(subtotal: "10.00")]);
      CheckoutSession checkoutSession = CheckoutSession.getInstance;

      checkoutSession.shippingType = flatRateShippingFixture(cost: "5.00");
      expect(await checkoutSession.total(), "15.00");

      checkoutSession.shippingType = localPickupShippingFixture(cost: "2.50");
      expect(await checkoutSession.total(), "12.50");

      checkoutSession.shippingType = freeShippingFixture();
      expect(await checkoutSession.total(), "10.00");
    });

    nyTest('ignores a shipping type with no method behind it', () async {
      await seedCart([cartLineItemFixture(subtotal: "10.00")]);
      CheckoutSession.getInstance.shippingType = flatRateShippingFixture();
      CheckoutSession.getInstance.shippingType!.object = null;

      expect(await CheckoutSession.getInstance.total(), "10.00");
    });

    nyTest('adds tax when a tax rate applies', () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 1));
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);

      expect(
          await CheckoutSession.getInstance
              .total(taxRate: taxRateFixture(rate: "20.0")),
          "120.00");
    });

    nyTest('takes a coupon off the total', () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "percent", amount: "25");
      CheckoutSession.getInstance.shippingType =
          flatRateShippingFixture(cost: "5.00");

      // 100 - 25 discount + 5 shipping
      expect(await CheckoutSession.getInstance.total(), "80.00");
    });

    nyTest('formats the total when asked', () async {
      await seedCart([cartLineItemFixture(subtotal: "10.00")]);

      expect(await CheckoutSession.getInstance.total(withFormat: true),
          r"$10.00");
    });
  });

  nyGroup('the checkout helper', () {
    nyTest('hands the total, the billing details and the cart to its callback',
        () async {
      await seedCart([cartLineItemFixture(quantity: 2, subtotal: "10.00")]);
      seedCheckoutSession();

      String? seenTotal;
      Object? seenBillingDetails;
      Cart? seenCart;

      await checkout(null, (total, billingDetails, cart) async {
        seenTotal = total;
        seenBillingDetails = billingDetails;
        seenCart = cart;
      });

      expect(seenTotal, "25.00"); // 20 goods + 5 flat rate shipping
      expect(seenBillingDetails, isNotNull);
      expect(seenCart, same(Cart.getInstance));
    });
  });
}
