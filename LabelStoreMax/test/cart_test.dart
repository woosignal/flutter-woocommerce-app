import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/config/storage_keys.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Cart tests.
///
/// The cart is the app's only piece of persistent commercial state: it lives in
/// `NyStorage` under `CART_SESSION` and survives an app restart and an app
/// update. Every total here is a number the customer sees before they pay.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    resetCheckoutSession();
    await clearCart();
  });

  nyGroup('reading and writing', () {
    nyTest('an empty cart reads as an empty list', () async {
      expect(await Cart.getInstance.getCart(), isEmpty);
    });

    nyTest('what is saved is what is read back', () async {
      await seedCart([
        cartLineItemFixture(name: "Blue Shirt", productId: 1, quantity: 2),
        cartLineItemFixture(name: "Red Hat", productId: 2),
      ]);

      List<CartLineItem> cart = await Cart.getInstance.getCart();

      expect(cart.length, 2);
      expect(cart[0].name, "Blue Shirt");
      expect(cart[0].quantity, 2);
      expect(cart[1].name, "Red Hat");
    });

    nyTest('the cart is stored under the legacy key', () async {
      await seedCart([cartLineItemFixture()]);

      // Renaming this key would drop every customer's saved cart on update.
      expect(await NyStorage.read(StorageKeysConfig.cart), isNotNull);
      expect(StorageKeysConfig.cart, "CART_SESSION");
    });

    nyTest('clear empties the cart', () async {
      await seedCart([cartLineItemFixture()]);
      expect(await Cart.getInstance.getCart(), isNotEmpty);

      await Cart.getInstance.clear();

      expect(await Cart.getInstance.getCart(), isEmpty);
    });
  });

  nyGroup('adding', () {
    nyTest('adds a new product', () async {
      await Cart.getInstance
          .addToCart(cartLineItem: cartLineItemFixture(productId: 1));

      expect((await Cart.getInstance.getCart()).length, 1);
    });

    nyTest('replaces the line rather than duplicating the same product',
        () async {
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(productId: 1, quantity: 1));
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(productId: 1, quantity: 5));

      List<CartLineItem> cart = await Cart.getInstance.getCart();

      expect(cart.length, 1);
      expect(cart.first.quantity, 5);
    });

    nyTest('keeps two variations of the same product apart', () async {
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(
              productId: 1, variationId: 10, variationOptions: "Blue"));
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(
              productId: 1, variationId: 11, variationOptions: "Red"));

      expect((await Cart.getInstance.getCart()).length, 2);
    });

    nyTest('replaces a variation line when the same options come back',
        () async {
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(
              productId: 1,
              variationId: 10,
              variationOptions: "Blue",
              quantity: 1));
      await Cart.getInstance.addToCart(
          cartLineItem: cartLineItemFixture(
              productId: 1,
              variationId: 10,
              variationOptions: "Blue",
              quantity: 4));

      List<CartLineItem> cart = await Cart.getInstance.getCart();

      expect(cart.length, 1);
      expect(cart.first.quantity, 4);
    });
  });

  nyGroup('removing', () {
    nyTest('removes a line by its index', () async {
      await seedCart([
        cartLineItemFixture(name: "Blue Shirt", productId: 1),
        cartLineItemFixture(name: "Red Hat", productId: 2),
      ]);

      await Cart.getInstance.removeCartItemForIndex(index: 0);

      List<CartLineItem> cart = await Cart.getInstance.getCart();
      expect(cart.length, 1);
      expect(cart.first.name, "Red Hat");
    });

    nyTest('removes a line by product and variation', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, variationId: 10),
        cartLineItemFixture(productId: 1, variationId: 11),
      ]);

      bool removed = await Cart.getInstance.removeCartItem(
          cartLineItemFixture(productId: 1, variationId: 10));

      expect(removed, isTrue);
      List<CartLineItem> cart = await Cart.getInstance.getCart();
      expect(cart.length, 1);
      expect(cart.first.variationId, 11);
    });
  });

  nyGroup('quantities', () {
    nyTest('increments the line the customer stepped', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, quantity: 1),
        cartLineItemFixture(productId: 2, quantity: 1),
      ]);

      await Cart.getInstance.updateQuantity(
          cartLineItem: cartLineItemFixture(productId: 1, quantity: 1),
          incrementQuantity: 2);

      List<CartLineItem> cart = await Cart.getInstance.getCart();
      expect(cart[0].quantity, 3);
      expect(cart[1].quantity, 1);
    });

    nyTest('decrements down to 1 but never to 0', () async {
      await seedCart([cartLineItemFixture(productId: 1, quantity: 2)]);

      await Cart.getInstance.updateQuantity(
          cartLineItem: cartLineItemFixture(productId: 1),
          incrementQuantity: -1);
      expect((await Cart.getInstance.getCart()).first.quantity, 1);

      // Stepping below 1 is a no-op - the customer removes the line instead.
      await Cart.getInstance.updateQuantity(
          cartLineItem: cartLineItemFixture(productId: 1),
          incrementQuantity: -1);
      expect((await Cart.getInstance.getCart()).first.quantity, 1);
    });

    nyTest('steps a variation without touching its sibling', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, variationId: 10, quantity: 1),
        cartLineItemFixture(productId: 1, variationId: 11, quantity: 1),
      ]);

      await Cart.getInstance.updateQuantity(
          cartLineItem: cartLineItemFixture(productId: 1, variationId: 11),
          incrementQuantity: 3);

      List<CartLineItem> cart = await Cart.getInstance.getCart();
      expect(cart[0].quantity, 1);
      expect(cart[1].quantity, 4);
    });

    nyTest('finds the index of a product, and reports -1 when it is not there',
        () async {
      await seedCart([
        cartLineItemFixture(productId: 1),
        cartLineItemFixture(productId: 2, variationId: 10),
      ]);

      expect(await Cart.getInstance.indexForProduct(productId: 1), 0);
      expect(
          await Cart.getInstance
              .indexForProduct(productId: 2, variationId: 10),
          1);
      expect(await Cart.getInstance.indexForProduct(productId: 99), -1);
    });
  });

  nyGroup('totals', () {
    nyTest('the subtotal multiplies each line subtotal by its quantity',
        () async {
      await seedCart([
        cartLineItemFixture(quantity: 2, subtotal: "10.00"),
        cartLineItemFixture(productId: 2, quantity: 3, subtotal: "1.50"),
      ]);

      expect(await Cart.getInstance.getSubtotal(), "24.50");
      expect(await Cart.getInstance.getSubtotal(withFormat: true), r"$24.50");
    });

    nyTest('the total uses the line total, not the line subtotal', () async {
      // A sale line carries a discounted `total` and the pre-sale `subtotal`.
      await seedCart([
        cartLineItemFixture(quantity: 2, subtotal: "12.00", total: "10.00")
      ]);

      expect(await Cart.getInstance.getTotal(), "20.00");
      expect(await Cart.getInstance.getSubtotal(), "24.00");
    });

    nyTest('the total takes a redeemed coupon off', () async {
      await seedCart([cartLineItemFixture(quantity: 1, subtotal: "100.00")]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "fixed_cart", amount: "15");

      expect(await Cart.getInstance.getTotal(), "85.00");
    });

    nyTest('an empty cart totals zero', () async {
      expect(await Cart.getInstance.getTotal(), "0.00");
      expect(await Cart.getInstance.getSubtotal(), "0.00");
    });

    nyTest('describes the cart in one line', () async {
      await seedCart([
        cartLineItemFixture(name: "Blue Shirt", productId: 1, quantity: 2),
        cartLineItemFixture(name: "Red Hat", productId: 2, quantity: 1),
      ]);

      expect(await Cart.getInstance.cartShortDesc(),
          "2 x | Blue Shirt,1 x | Red Hat");
    });
  });

  nyGroup('coupon discounts', () {
    nyTest('no coupon means no discount', () async {
      await seedCart([cartLineItemFixture(subtotal: "50.00")]);

      expect(await Cart.getInstance.couponDiscountAmount(), "0");
    });

    nyTest('a percentage comes off the eligible subtotal', () async {
      await seedCart([
        cartLineItemFixture(quantity: 2, subtotal: "50.00")
      ]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "percent", amount: "10");

      expect(await Cart.getInstance.couponDiscountAmount(), "10.00");
    });

    nyTest('a fixed cart discount is the amount, whatever is in the cart',
        () async {
      await seedCart([cartLineItemFixture(quantity: 5, subtotal: "50.00")]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "fixed_cart", amount: "7.50");

      expect(await Cart.getInstance.couponDiscountAmount(), "7.50");
    });

    nyTest('a fixed product discount is the amount per eligible line',
        () async {
      await seedCart([
        cartLineItemFixture(productId: 1),
        cartLineItemFixture(productId: 2),
        cartLineItemFixture(productId: 3),
      ]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "fixed_product", amount: "2");

      expect(await Cart.getInstance.couponDiscountAmount(), "6.00");
    });

    nyTest('an unknown discount type discounts nothing', () async {
      await seedCart([cartLineItemFixture(subtotal: "50.00")]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "buy_one_get_one", amount: "10");

      expect(await Cart.getInstance.couponDiscountAmount(), "0");
    });

    nyTest('skips a product the coupon excludes', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, subtotal: "50.00"),
        cartLineItemFixture(productId: 2, subtotal: "50.00"),
      ]);
      CheckoutSession.getInstance.coupon = couponFixture(
          discountType: "percent", amount: "10", excludedProductIds: [2]);

      // Only the £50 line counts.
      expect(await Cart.getInstance.couponDiscountAmount(), "5.00");
    });

    nyTest('skips a product outside the coupon product list', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, subtotal: "50.00"),
        cartLineItemFixture(productId: 2, subtotal: "50.00"),
      ]);
      CheckoutSession.getInstance.coupon = couponFixture(
          discountType: "percent", amount: "10", productIds: [1]);

      expect(await Cart.getInstance.couponDiscountAmount(), "5.00");
    });

    nyTest('skips a line in an excluded category', () async {
      await seedCart([
        cartLineItemFixture(
            productId: 1,
            subtotal: "50.00",
            categories: [ws_product.Category(15, "Clothing", "clothing")]),
        cartLineItemFixture(
            productId: 2,
            subtotal: "50.00",
            categories: [ws_product.Category(16, "Sale", "sale")]),
      ]);
      CheckoutSession.getInstance.coupon = couponFixture(
          discountType: "percent",
          amount: "10",
          excludedProductCategories: [16]);

      expect(await Cart.getInstance.couponDiscountAmount(), "5.00");
    });

    nyTest('skips a line outside the coupon category list', () async {
      await seedCart([
        cartLineItemFixture(
            productId: 1,
            subtotal: "50.00",
            categories: [ws_product.Category(15, "Clothing", "clothing")]),
        cartLineItemFixture(
            productId: 2,
            subtotal: "50.00",
            categories: [ws_product.Category(16, "Sale", "sale")]),
      ]);
      CheckoutSession.getInstance.coupon = couponFixture(
          discountType: "percent", amount: "10", productCategories: [15]);

      expect(await Cart.getInstance.couponDiscountAmount(), "5.00");
    });

    nyTest('skips a sale item when the coupon excludes them', () async {
      await seedCart([
        cartLineItemFixture(productId: 1, subtotal: "50.00", onSale: false),
        cartLineItemFixture(productId: 2, subtotal: "50.00", onSale: true),
      ]);
      CheckoutSession.getInstance.coupon = couponFixture(
          discountType: "percent", amount: "10", excludeSaleItems: true);

      expect(await Cart.getInstance.couponDiscountAmount(), "5.00");
    });
  });

  nyGroup('tax', () {
    nyTest('a cart of non-taxable lines is not taxed', () async {
      await seedCart([
        cartLineItemFixture(taxStatus: "none", subtotal: "100.00"),
      ]);

      expect(await Cart.getInstance.taxAmount(taxRateFixture()), "0");
    });

    nyTest('an empty cart is not taxed', () async {
      expect(await Cart.getInstance.taxAmount(taxRateFixture()), "0");
    });

    nyTest('taxes the cart subtotal when store prices include tax', () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 1));
      await seedCart([
        cartLineItemFixture(
            taxStatus: "taxable", quantity: 2, subtotal: "50.00")
      ]);

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "20.00");
    });

    nyTest('takes the coupon off before taxing', () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 1));
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.coupon =
          couponFixture(discountType: "fixed_cart", amount: "50");

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "10.00");
    });

    nyTest('does not tax the cart when store prices exclude tax', () async {
      seedAppConfig(
          wooSignalApp: wooSignalAppFixture(productPricesIncludeTax: 0));
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);

      // Tax on the goods is worked out by WooCommerce in this configuration.
      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "0.00");
    });

    nyTest('taxes a taxable flat rate shipping cost', () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.shippingType =
          flatRateShippingFixture(cost: "10.00", taxable: true);

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "2.00");
    });

    nyTest('does not tax a flat rate shipping cost that is not taxable',
        () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.shippingType =
          flatRateShippingFixture(cost: "10.00", taxable: false);

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "0.00");
    });

    nyTest('taxes a taxable local pickup cost', () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.shippingType =
          localPickupShippingFixture(cost: "5.00", taxable: true);

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "1.00");
    });

    nyTest('treats a blank shipping cost as zero', () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.shippingType =
          flatRateShippingFixture(cost: "", taxable: true);

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "0.00");
    });

    nyTest('free shipping is never taxed', () async {
      await seedCart([cartLineItemFixture(subtotal: "100.00")]);
      CheckoutSession.getInstance.shippingType = freeShippingFixture();

      expect(await Cart.getInstance.taxAmount(taxRateFixture(rate: "20.0")),
          "0.00");
    });
  });
}
