import 'package:flutter_app/app/controllers/account_order_detail_controller.dart';
import 'package:flutter_app/app/controllers/browse_category_controller.dart';
import 'package:flutter_app/app/controllers/checkout_status_controller.dart';
import 'package:flutter_app/app/controllers/leave_review_controller.dart';
import 'package:flutter_app/app/controllers/product_detail_controller.dart';
import 'package:flutter_app/app/controllers/product_image_viewer_controller.dart';
import 'package:flutter_app/app/controllers/product_reviews_controller.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| Model Decoders
| -------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models. Learn more https://nylo.dev/docs/5.x/decoders#model-decoders
|--------------------------------------------------------------------------
*/

final Map<Type, dynamic> modelDecoders = {
  // ...
  User: (data) => User.fromJson(data)
};

/*
|--------------------------------------------------------------------------
| API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
| Learn more https://nylo.dev/docs/5.x/decoders#api-decoders
|--------------------------------------------------------------------------
*/

final Map<Type, NyApiService> apiDecoders = {
  ApiService: ApiService(),

  // ...
};

/*
|--------------------------------------------------------------------------
| Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
| E.g. NyPage<MyController>
|
| Learn more https://nylo.dev/docs/5.x/controllers#using-controllers-with-ny-page
|--------------------------------------------------------------------------
*/
final Map<Type, BaseController> controllers = {
  ProductDetailController: ProductDetailController(),
  AccountOrderDetailController: AccountOrderDetailController(),
  BrowseCategoryController: BrowseCategoryController(),
  CheckoutStatusController: CheckoutStatusController(),
  LeaveReviewController: LeaveReviewController(),
  ProductImageViewerController: ProductImageViewerController(),
  ProductReviewsController: ProductReviewsController()

  // ...

};