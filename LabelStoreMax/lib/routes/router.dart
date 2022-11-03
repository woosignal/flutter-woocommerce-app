import 'package:flutter_app/resources/pages/account_delete_page.dart';
import 'package:flutter_app/resources/pages/account_detail_page.dart';
import 'package:flutter_app/resources/pages/account_landing_page.dart';
import 'package:flutter_app/resources/pages/account_order_detail_page.dart';
import 'package:flutter_app/resources/pages/account_profile_update_page.dart';
import 'package:flutter_app/resources/pages/account_register_page.dart';
import 'package:flutter_app/resources/pages/account_shipping_details_page.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/pages/cart_page.dart';
import 'package:flutter_app/resources/pages/checkout_confirmation_page.dart';
import 'package:flutter_app/resources/pages/checkout_details_page.dart';
import 'package:flutter_app/resources/pages/checkout_payment_type_page.dart';
import 'package:flutter_app/resources/pages/checkout_shipping_type_page.dart';
import 'package:flutter_app/resources/pages/checkout_status_page.dart';
import 'package:flutter_app/resources/pages/coupon_page.dart';
import 'package:flutter_app/resources/pages/customer_countries_page.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/pages/home_search_page.dart';
import 'package:flutter_app/resources/pages/leave_review_page.dart';
import 'package:flutter_app/resources/pages/no_connection_page.dart';
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:flutter_app/resources/pages/product_image_viewer_page.dart';
import 'package:flutter_app/resources/pages/product_reviews_page.dart';
import 'package:flutter_app/resources/pages/wishlist_page_widget.dart';
import 'package:flutter_app/resources/widgets/checkout_paypal.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| App Router
|--------------------------------------------------------------------------
*/

appRouter() => nyRoutes((router) {
      router.route("/home", (context) => HomePage());

      router.route("/cart", (context) => CartPage());

      router.route("/checkout", (context) => CheckoutConfirmationPage());

      router.route("/browse-category", (context) => BrowseCategoryPage(),
          transition: PageTransitionType.fade);

      router.route("/product-search", (context) => BrowseSearchPage(),
          transition: PageTransitionType.fade);

      router.route("/product-detail", (context) => ProductDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route("/product-reviews", (context) => ProductReviewsPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route("/product-leave-review", (context) => LeaveReviewPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route("/product-images", (context) => ProductImageViewerPage(),
          transition: PageTransitionType.fade);

      router.route("/wishlist", (context) => WishListPageWidget(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(
          "/account-order-detail", (context) => AccountOrderDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route("/checkout-status", (context) => CheckoutStatusPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route("/checkout-details", (context) => CheckoutDetailsPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          "/checkout-payment-type", (context) => CheckoutPaymentTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          "/checkout-shipping-type", (context) => CheckoutShippingTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route("/checkout-coupons", (context) => CouponPage(),
          transition: PageTransitionType.bottomToTop);

      router.route("/home-search", (context) => HomeSearchPage(),
          transition: PageTransitionType.bottomToTop);

      router.route('/paypal', (context) => PayPalCheckout());

      router.route("/customer-countries", (context) => CustomerCountriesPage(),
          transition: PageTransitionType.bottomToTop);

      router.route("/no-connection", (context) => NoConnectionPage());

      // Account Section

      router.route("/account-landing", (context) => AccountLandingPage(),
          transition: PageTransitionType.bottomToTop);

      router.route("/account-register", (context) => AccountRegistrationPage());

      router.route("/account-detail", (context) => AccountDetailPage());

      router.route("/account-update", (context) => AccountProfileUpdatePage());

      router.route("/account-delete", (context) => AccountDeletePage());

      router.route("/account-shipping-details",
          (context) => AccountShippingDetailsPage());
    });
