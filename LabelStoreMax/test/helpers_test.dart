import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/bootstrap/extensions.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/storage_keys.dart';

import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Helper tests.
///
/// `bootstrap/helpers.dart` is where the app's arithmetic lives - prices, sale
/// percentages, WooCommerce's shipping cost formulas - along with the wishlist
/// and the encryption switch. None of it touches the network.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
    await clearCart();
    await NyStorage.delete(StorageKeysConfig.wishlistProducts);
  });

  nyGroup('prices', () {
    nyTest('parses a WooCommerce price string', () async {
      expect(parseWcPrice("10.50"), 10.5);
      expect(parseWcPrice("0"), 0);
      expect(parseWcPrice("-3.25"), -3.25);
    });

    nyTest('treats an unparseable price as zero rather than throwing',
        () async {
      // WooCommerce sends "" for a product with no price set.
      expect(parseWcPrice(null), 0);
      expect(parseWcPrice(""), 0);
      expect(parseWcPrice("free"), 0);
    });

    nyTest('formats a double in the store currency', () async {
      expect(formatDoubleCurrency(total: 10), r"$10.00");
      expect(formatDoubleCurrency(total: 1234.5), r"$1,234.50");
      expect(formatDoubleCurrency(total: 0), r"$0.00");
    });

    nyTest('formats a price string, treating blanks as zero', () async {
      expect(formatStringCurrency(total: "10.5"), r"$10.50");
      expect(formatStringCurrency(total: ""), r"$0.00");
      expect(formatStringCurrency(total: null), r"$0.00");
    });

    nyTest('uses the currency symbol the store is configured with', () async {
      seedAppConfig(
          wooSignalApp:
              wooSignalAppFixture(currencyCode: "eur", currencySymbol: "€"));

      expect(formatDoubleCurrency(total: 9.99), "€9.99");
    });

    nyTest('works out the sale discount as a percentage', () async {
      expect(workoutSaleDiscount(salePrice: "50", priceBefore: "100"), "50");
      expect(workoutSaleDiscount(salePrice: "75", priceBefore: "100"), "25");
      expect(workoutSaleDiscount(salePrice: "90", priceBefore: "100"), "10");
    });
  });

  nyGroup('small utilities', () {
    nyTest('isNumeric recognises numbers and nothing else', () async {
      expect(isNumeric("10"), isTrue);
      expect(isNumeric("10.5"), isTrue);
      expect(isNumeric("-1"), isTrue);
      expect(isNumeric("ten"), isFalse);
      expect(isNumeric(""), isFalse);
      expect(isNumeric(null), isFalse);
    });

    nyTest('isEmail accepts real addresses and rejects the rest', () async {
      expect(isEmail("test@example.com"), isTrue);
      expect(isEmail("first.last+tag@sub.example.co.uk"), isTrue);
      expect(isEmail("test@example"), isFalse);
      expect(isEmail("test.example.com"), isFalse);
      expect(isEmail("@example.com"), isFalse);
      expect(isEmail(""), isFalse);
    });

    nyTest('truncateString cuts long text and leaves short text alone',
        () async {
      expect(truncateString("A very long product name", 6), "A very...");
      expect(truncateString("Short", 10), "Short");
      // Exactly at the limit still gets an ellipsis.
      expect(truncateString("12345", 5), "12345...");
    });

    nyTest('parseHtmlString strips the markup WooCommerce sends', () async {
      expect(parseHtmlString("<p>Hello <b>world</b></p>"), "Hello world");
      expect(parseHtmlString(""), "");
      expect(parseHtmlString(null), "");
    });

    nyTest('formats dates for each of the three display formats', () async {
      expect(formatForDateTime(FormatType.date), "yyyy-MM-dd");
      expect(formatForDateTime(FormatType.dateTime), "dd-MM-yyyy hh:mm a");
      expect(formatForDateTime(FormatType.time), "hh:mm a");

      expect(
          dateFormatted(
              date: "2026-03-04T15:30:00",
              formatType: formatForDateTime(FormatType.date)),
          "2026-03-04");
    });

    nyTest('parses a date string', () async {
      expect(parseDateTime("2026-03-04T15:30:00"), DateTime(2026, 3, 4, 15, 30));
    });
  });

  nyGroup('the shipping cost calculator', () {
    nyTest('evaluates a plain arithmetic expression', () async {
      expect(strCal(sum: "2 + 3"), 5);
      expect(strCal(sum: "(10 * 2) / 4"), 5);
      expect(strCal(sum: ""), 0);
    });

    nyTest('an empty cost is free', () async {
      expect(await workoutShippingCostWC(sum: null), 0);
      expect(await workoutShippingCostWC(sum: ""), 0);
    });

    nyTest('a flat cost is passed through', () async {
      await seedCart([cartLineItemFixture(quantity: 1)]);

      expect(await workoutShippingCostWC(sum: "5"), 5);
    });

    nyTest('substitutes [qty] with the total number of items in the cart',
        () async {
      await seedCart([
        cartLineItemFixture(productId: 1, quantity: 2),
        cartLineItemFixture(productId: 2, quantity: 3),
      ]);

      // WooCommerce's own "2 * [qty]" flat rate formula.
      expect(await workoutShippingCostWC(sum: "2 * [qty]"), 10);
    });

    nyTest('works out a percentage fee against the cart subtotal', () async {
      await seedCart([cartLineItemFixture(quantity: 1, subtotal: "200.00")]);

      expect(await workoutShippingCostWC(sum: '[fee percent="10"]'), 20);
    });

    nyTest('floors a percentage fee at min_fee', () async {
      await seedCart([cartLineItemFixture(quantity: 1, subtotal: "10.00")]);

      expect(
          await workoutShippingCostWC(
              sum: '[fee percent="10" min_fee="5"]'),
          5);
    });

    nyTest('caps a percentage fee at max_fee', () async {
      await seedCart([cartLineItemFixture(quantity: 1, subtotal: "1000.00")]);

      expect(
          await workoutShippingCostWC(
              sum: '[fee percent="10" max_fee="20"]'),
          20);
    });

    nyTest('the shipping class calculator takes its own cart lines', () async {
      expect(
          await workoutShippingClassCostWC(
              sum: "2 * [qty]",
              cartLineItem: [cartLineItemFixture(quantity: 4)]),
          8);
      expect(await workoutShippingClassCostWC(sum: null), 0);
    });

    nyTest('defaultRegex is case insensitive unless asked to be strict',
        () async {
      expect(defaultRegex(r'qty').hasMatch("QTY"), isTrue);
      expect(defaultRegex(r'qty', strict: true).hasMatch("QTY"), isFalse);
    });
  });

  nyGroup('the wishlist', () {
    nyTest('starts empty', () async {
      expect(await getWishlistProducts(), isEmpty);
      expect(await hasAddedWishlistProduct(101), isFalse);
    });

    nyTest('saves a product and finds it again', () async {
      await saveWishlistProduct(product: productFixture());

      expect(await hasAddedWishlistProduct(101), isTrue);
      expect(await getWishlistProducts(), [
        {"id": 101}
      ]);
    });

    nyTest('does not save the same product twice', () async {
      await saveWishlistProduct(product: productFixture());
      await saveWishlistProduct(product: productFixture());

      expect((await getWishlistProducts()).length, 1);
    });

    nyTest('removes a product', () async {
      await saveWishlistProduct(product: productFixture());
      await saveWishlistProduct(
          product: productFixture(overrides: {'id': 202}));

      await removeWishlistProduct(product: productFixture());

      expect(await hasAddedWishlistProduct(101), isFalse);
      expect(await hasAddedWishlistProduct(202), isTrue);
    });

    nyTest('uses the legacy storage key', () async {
      // Renaming this drops every customer's saved wishlist.
      expect(StorageKeysConfig.wishlistProducts, "CS_WISHLIST_PRODUCTS");
    });
  });

  nyGroup('new product badge', () {
    nyTest('a product created today is new', () async {
      String today = DateTime.now()
          .subtract(Duration(hours: 1))
          .toIso8601String()
          .split('.')
          .first;

      expect(
          isProductNew(
              productFixture(overrides: {'date_created_gmt': today})),
          isTrue);
    });

    nyTest('a product created a week ago is not', () async {
      String lastWeek = DateTime.now()
          .subtract(Duration(days: 7))
          .toIso8601String()
          .split('.')
          .first;

      expect(
          isProductNew(
              productFixture(overrides: {'date_created_gmt': lastWeek})),
          isFalse);
    });

    nyTest('an unparseable or missing creation date is not new', () async {
      expect(
          isProductNew(
              productFixture(overrides: {'date_created_gmt': "not a date"})),
          isFalse);
      expect(
          isProductNew(
              productFixture(overrides: {'date_created_gmt': null})),
          isFalse);
    });
  });

  nyGroup('date extensions', () {
    nyTest('isBetween covers the range inclusively', () async {
      DateTime from = DateTime(2026, 1, 1);
      DateTime to = DateTime(2026, 12, 31);

      expect(DateTime(2026, 6, 1).isBetween(from, to), isTrue);
      expect(from.isBetween(from, to), isTrue);
      expect(to.isBetween(from, to), isTrue);
      expect(DateTime(2025, 12, 31).isBetween(from, to), isFalse);
      expect(DateTime(2027, 1, 1).isBetween(from, to), isFalse);
    });

    nyTest('a null date answers null', () async {
      DateTime? nothing;

      expect(nothing.isBetween(DateTime(2026), DateTime(2027)), isNull);
      expect(nothing.isAfterOrEqualTo(DateTime(2026)), isNull);
      expect(nothing.isBeforeOrEqualTo(DateTime(2026)), isNull);
    });
  });

  nyGroup('encryption switch', () {
    nyTest('is off when neither key is set', () async {
      await withEnv({'ENCRYPT_KEY': null, 'ENCRYPT_SECRET': null},
          () async => expect(shouldEncrypt(), isFalse));
      await withEnv({'ENCRYPT_KEY': "", 'ENCRYPT_SECRET': ""},
          () async => expect(shouldEncrypt(), isFalse));
    });

    nyTest('is off when only one of the pair is set', () async {
      await withEnv({'ENCRYPT_KEY': "a-key", 'ENCRYPT_SECRET': null},
          () async => expect(shouldEncrypt(), isFalse));
      await withEnv({'ENCRYPT_KEY': null, 'ENCRYPT_SECRET': "a-secret"},
          () async => expect(shouldEncrypt(), isFalse));
    });

    nyTest('is on only when both are set', () async {
      await withEnv({'ENCRYPT_KEY': "a-key", 'ENCRYPT_SECRET': "a-secret"},
          () async => expect(shouldEncrypt(), isTrue));
    });

    nyTest('is off for the shipped .env, which leaves both unset', () async {
      expect(shouldEncrypt(), isFalse);
    });
  });

  nyGroup('push notifications switch', () {
    nyTest('follows the store setting when there is one', () async {
      seedAppConfig().firebaseFcmIsEnabled = true;
      expect(isFirebaseEnabled(), isTrue);

      seedAppConfig().firebaseFcmIsEnabled = false;
      expect(isFirebaseEnabled(), isFalse);
    });

    nyTest('falls back to the env flag when the store says nothing', () async {
      seedAppConfig().firebaseFcmIsEnabled = null;

      await withEnv({'FCM_ENABLED': true},
          () async => expect(isFirebaseEnabled(), isTrue));
      await withEnv({'FCM_ENABLED': null},
          () async => expect(isFirebaseEnabled(), isFalse));
    });
  });

  nyGroup('country and state lookups', () {
    nyTest('loads the bundled country list', () async {
      // Reads assets/json/default_shipping.json off disk, no network.
      List<dynamic> shipping = await getDefaultShipping();

      expect(shipping, isNotEmpty);
      expect(shipping.any((country) => country.code == "US"), isTrue);
    });

    nyTest('finds a country by its code', () async {
      expect((await findCountryMetaForShipping("US"))!.country,
          "United States (US)");
      expect(await findCountryMetaForShipping("ZZ"), isNull);
    });

    nyTest('finds a state by its full code, and nothing by a bad one',
        () async {
      dynamic us = await findCountryMetaForShipping("US");

      expect(findDefaultShippingStateByCode(us, "US:AL")!.name, "Alabama");
      expect(findDefaultShippingStateByCode(us, "US:ZZ"), isNull);
      // The bare code is not what the list is keyed by.
      expect(findDefaultShippingStateByCode(us, "AL"), isNull);
    });
  });
}
