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
      router.add(HomePage.path).initialRoute();

      router.add(CartPage.path);

      router.add(CheckoutConfirmationPage.path);

      router.add(BrowseCategoryPage.path,
          transitionType: TransitionType.fade());

      router.add(BrowseSearchPage.path, transitionType: TransitionType.fade());

      router.add(ProductDetailPage.path);

      router.add(ProductReviewsPage.path);

      router.add(LeaveReviewPage.path);

      router.add(ProductImageViewerPage.path,
          transitionType: TransitionType.fade());

      router.add(WishListPageWidget.path);

      router.add(AccountOrderDetailPage.path);

      router.add(CheckoutStatusPage.path);

      router.add(CheckoutDetailsPage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(CheckoutPaymentTypePage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(CheckoutShippingTypePage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(CouponPage.path, transitionType: TransitionType.bottomToTop());

      router.add(HomeSearchPage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(CustomerCountriesPage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(NoConnectionPage.path);

      // Account Section

      router.add(AccountLoginPage.path,
          transitionType: TransitionType.bottomToTop());

      router.add(AccountRegistrationPage.path);

      router.add(AccountDetailPage.path);

      router.add(AccountProfileUpdatePage.path);

      router.add(AccountDeletePage.path);

      router.add(AccountShippingDetailsPage.path);

      router.add(NotificationsPage.path);
    });
