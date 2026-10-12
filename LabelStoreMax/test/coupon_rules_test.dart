import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/resources/pages/coupon_page.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Coupon restriction tests.
///
/// [couponRejection] is WooCommerce's coupon rules checked on the device. Each
/// one refuses a code the store would refuse anyway, so a customer is told why
/// rather than watching the code silently do nothing. Order matters: the first
/// rule that matches is the one the customer is shown.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
  });

  /// Run the rules against a coupon, with a cart and a customer that pass
  /// everything by default.
  ({String message, String id})? check({
    required dynamic coupon,
    List<int?> productIds = const [1],
    String? emailAddress = "test@example.test",
    double subtotal = 50,
    DateTime? dateNow,
  }) =>
      couponRejection(
        coupon: coupon,
        productIds: productIds,
        emailAddress: emailAddress,
        subtotal: subtotal,
        dateNow: dateNow ?? DateTime(2026, 6, 1),
      );

  nyGroup('a coupon with no restrictions', () {
    nyTest('is accepted', () async {
      expect(check(coupon: couponFixture()), isNull);
    });
  });

  nyGroup('excluded products', () {
    nyTest('refuses a cart holding an excluded product', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(excludedProductIds: [2]),
          productIds: [1, 2]);

      expect(rejection, isNotNull);
      expect(rejection!.id, 'info');
      expect(rejection.message,
          "${trans('Sorry, this coupon can not be used with your cart')}.");
    });

    nyTest('accepts a cart holding none of them', () async {
      expect(
          check(
              coupon: couponFixture(excludedProductIds: [99]),
              productIds: [1, 2]),
          isNull);
    });
  });

  nyGroup('email restrictions', () {
    nyTest('refuses an address on the restriction list', () async {
      ({String message, String id})? rejection = check(
          coupon:
              couponFixture(emailRestrictions: ["blocked@example.test"]),
          emailAddress: "blocked@example.test");

      expect(rejection!.id, 'danger');
      expect(rejection.message, trans('You cannot redeem this coupon'));
    });

    nyTest('accepts an address that is not on it', () async {
      expect(
          check(
              coupon:
                  couponFixture(emailRestrictions: ["blocked@example.test"]),
              emailAddress: "test@example.test"),
          isNull);
    });
  });

  nyGroup('minimum spend', () {
    nyTest('refuses a cart below the minimum', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(minimumAmount: "100"), subtotal: 99.99);

      expect(rejection!.id, 'danger');
      // The customer is told the figure, formatted in the store currency.
      expect(rejection.message, contains(r"$100.00"));
    });

    nyTest('accepts a cart exactly on the minimum', () async {
      expect(
          check(coupon: couponFixture(minimumAmount: "100"), subtotal: 100),
          isNull);
    });

    nyTest('a minimum of zero is no minimum at all', () async {
      expect(
          check(coupon: couponFixture(minimumAmount: "0"), subtotal: 0.01),
          isNull);
    });
  });

  nyGroup('maximum spend', () {
    nyTest('refuses a cart above the maximum', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(maximumAmount: "100"), subtotal: 100.01);

      expect(rejection!.id, 'danger');
      expect(rejection.message, contains(r"$100.00"));
    });

    nyTest('accepts a cart exactly on the maximum', () async {
      expect(
          check(coupon: couponFixture(maximumAmount: "100"), subtotal: 100),
          isNull);
    });

    nyTest('a maximum of zero is no maximum at all', () async {
      expect(
          check(coupon: couponFixture(maximumAmount: "0"), subtotal: 99999),
          isNull);
    });
  });

  nyGroup('expiry', () {
    nyTest('refuses a coupon whose expiry date has passed', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(dateExpires: "2026-01-01T00:00:00"),
          dateNow: DateTime(2026, 6, 1));

      expect(rejection!.id, 'warning');
      expect(rejection.message, trans("This coupon has expired"));
    });

    nyTest('accepts a coupon that has not expired yet', () async {
      expect(
          check(
              coupon: couponFixture(dateExpires: "2026-12-31T00:00:00"),
              dateNow: DateTime(2026, 6, 1)),
          isNull);
    });

    nyTest('accepts a coupon with no expiry date', () async {
      expect(check(coupon: couponFixture(dateExpires: null)), isNull);
    });
  });

  nyGroup('usage limit', () {
    nyTest('refuses a coupon that has been used up', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(usageLimit: 10, usageCount: 10));

      expect(rejection!.id, 'warning');
      expect(rejection.message, trans("Usage limit has been reached"));
    });

    nyTest('accepts a coupon with uses left', () async {
      expect(
          check(coupon: couponFixture(usageLimit: 10, usageCount: 9)), isNull);
    });

    nyTest('accepts a coupon with no usage limit', () async {
      expect(
          check(coupon: couponFixture(usageLimit: null, usageCount: 9999)),
          isNull);
    });
  });

  nyGroup('usage limit per customer', () {
    nyTest('refuses a customer who has already used it enough', () async {
      ({String message, String id})? rejection = check(
          coupon: couponFixture(
              usageLimitPerUser: 1, usedBy: ["test@example.test"]),
          emailAddress: "test@example.test");

      expect(rejection!.id, 'warning');
      expect(rejection.message, "${trans('You cannot redeem this coupon')}.");
    });

    nyTest('matches the address regardless of case', () async {
      expect(
          check(
              coupon: couponFixture(
                  usageLimitPerUser: 1, usedBy: ["TEST@Example.TEST"]),
              emailAddress: "test@example.test"),
          isNotNull);
    });

    nyTest('accepts a customer who has not reached the limit', () async {
      expect(
          check(
              coupon: couponFixture(
                  usageLimitPerUser: 2, usedBy: ["test@example.test"]),
              emailAddress: "test@example.test"),
          isNull);
    });

    nyTest('ignores uses by other customers', () async {
      expect(
          check(
              coupon: couponFixture(
                  usageLimitPerUser: 1, usedBy: ["someone@example.test"]),
              emailAddress: "test@example.test"),
          isNull);
    });

    nyTest('a coupon nobody has used passes even for a guest', () async {
      // The email is only read once the coupon has been used by somebody, so
      // an unused coupon does not need one.
      expect(
          check(
              coupon: couponFixture(usageLimitPerUser: 1, usedBy: []),
              emailAddress: null),
          isNull);
    });
  });

  nyGroup('rule order', () {
    nyTest('reports the first rule that matches', () async {
      // A coupon that fails the excluded-product rule and the minimum-spend
      // rule reports the excluded product, because that is checked first.
      ({String message, String id})? rejection = check(
          coupon: couponFixture(
              excludedProductIds: [1], minimumAmount: "1000"),
          productIds: [1],
          subtotal: 1);

      expect(rejection!.id, 'info');
    });
  });
}
