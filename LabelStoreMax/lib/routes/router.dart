import '/resources/pages/notifications_page.dart';
import '/resources/pages/account_delete_page.dart';
import '/resources/pages/account_detail_page.dart';
import '/resources/pages/account_login_page.dart';
import '/resources/pages/account_order_detail_page.dart';
import '/resources/pages/account_profile_update_page.dart';
import '/resources/pages/account_register_page.dart';
import '/resources/pages/account_shipping_details_page.dart';
import '/resources/pages/browse_category_page.dart';
import '/resources/pages/browse_search_page.dart';
import '/resources/pages/cart_page.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/pages/checkout_details_page.dart';
import '/resources/pages/checkout_payment_type_page.dart';
import '/resources/pages/checkout_shipping_type_page.dart';
import '/resources/pages/checkout_status_page.dart';
import '/resources/pages/coupon_page.dart';
import '/resources/pages/customer_countries_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/home_search_page.dart';
import '/resources/pages/leave_review_page.dart';
import '/resources/pages/no_connection_page.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/pages/product_image_viewer_page.dart';
import '/resources/pages/product_reviews_page.dart';
import '/resources/pages/wishlist_page_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.route(HomePage.path, (context) => HomePage(), initialRoute: true);

      router.route(CartPage.path, (context) => CartPage());

      router.route(CheckoutConfirmationPage.path,
          (context) => CheckoutConfirmationPage());

      router.route(BrowseCategoryPage.path, (context) => BrowseCategoryPage(),
          transition: PageTransitionType.fade);

      router.route(BrowseSearchPage.path, (context) => BrowseSearchPage(),
          transition: PageTransitionType.fade);

      router.route(ProductDetailPage.path, (context) => ProductDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(ProductReviewsPage.path, (context) => ProductReviewsPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(LeaveReviewPage.path, (context) => LeaveReviewPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(
          ProductImageViewerPage.path, (context) => ProductImageViewerPage(),
          transition: PageTransitionType.fade);

      router.route(WishListPageWidget.path, (context) => WishListPageWidget(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(
          AccountOrderDetailPage.path, (context) => AccountOrderDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(CheckoutStatusPage.path, (context) => CheckoutStatusPage(),
          transition: PageTransitionType.rightToLeftWithFade);

      router.route(CheckoutDetailsPage.path, (context) => CheckoutDetailsPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          CheckoutPaymentTypePage.path, (context) => CheckoutPaymentTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route(CheckoutShippingTypePage.path,
          (context) => CheckoutShippingTypePage(),
          transition: PageTransitionType.bottomToTop);

      router.route(CouponPage.path, (context) => CouponPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(HomeSearchPage.path, (context) => HomeSearchPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          CustomerCountriesPage.path, (context) => CustomerCountriesPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(NoConnectionPage.path, (context) => NoConnectionPage());

      // Account Section

      router.route(AccountLoginPage.path, (context) => AccountLoginPage(),
          transition: PageTransitionType.bottomToTop);

      router.route(
          AccountRegistrationPage.path, (context) => AccountRegistrationPage());

      router.route(AccountDetailPage.path, (context) => AccountDetailPage());

      router.route(AccountProfileUpdatePage.path,
          (context) => AccountProfileUpdatePage());

      router.route(AccountDeletePage.path, (context) => AccountDeletePage());

      router.route(AccountShippingDetailsPage.path,
          (context) => AccountShippingDetailsPage());

      router.route(NotificationsPage.path, (context) => NotificationsPage());
    });
