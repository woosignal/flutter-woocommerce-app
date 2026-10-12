import '/bootstrap/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* ApiService
| -------------------------------------------------------------------------
| Define your API endpoints
|
| Note: Label StoreMax talks to WooCommerce through the `woosignal` package and
| to WordPress through `wp_json_api`, so this service only handles the few
| requests the app makes itself (currently PayPal, see
| bootstrap/paypal/paypal_service.dart).
|
| Learn more https://nylo.dev/docs/7.x/networking
|-------------------------------------------------------------------------- */

class ApiService extends NyApiService {
  ApiService()
      : super(
          decoders: modelDecoders,
          // Debug builds only. NetworkLogger writes with print(), which is not
          // stripped from a release build, and the requests this service makes
          // carry the PayPal Basic auth header and access tokens.
          useNetworkLogger: getEnv('APP_DEBUG', defaultValue: false) == true,
          // baseOptions: (BaseOptions baseOptions) {
          //   return baseOptions
          //             ..connectTimeout = Duration(seconds: 5)
          //             ..sendTimeout = Duration(seconds: 5)
          //             ..receiveTimeout = Duration(seconds: 5);
          // },
        );

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  Map<Type, Interceptor> get interceptors => <Type, Interceptor>{
        ...super.interceptors,
        // MyCustomInterceptor: MyCustomInterceptor(),
      };

/* Helpers
  |-------------------------------------------------------------------------- */

  /* Authentication Headers
  |--------------------------------------------------------------------------
  | Set your auth headers
  | Authenticate your API requests using a bearer token or any other method
  |-------------------------------------------------------------------------- */

  // @override
  // Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
  //   String? myAuthToken = await StorageKeysConfig.bearerToken.read();
  //   if (myAuthToken != null) {
  //     headers.addBearerToken(myAuthToken);
  //   }
  //   return headers;
  // }

  /* Should Refresh Token
  |--------------------------------------------------------------------------
  | Check if your Token should be refreshed
  | Set `false` if your API does not require a token refresh
  |-------------------------------------------------------------------------- */

  // @override
  // Future<bool> shouldRefreshToken() async {
  //   return false;
  // }

  /* Refresh Token
  |--------------------------------------------------------------------------
  | If `shouldRefreshToken` returns true then this method
  | will be called to refresh your token. Save your new token to
  | local storage and then use the value in `setAuthHeaders`.
  |-------------------------------------------------------------------------- */

  // @override
  // refreshToken(Dio dio) async {
  //  dynamic response = (await dio.get("https://example.com/refresh-token")).data;
  //  // Save the new token
  //   await StorageKeysConfig.bearerToken.save(response['token']);
  // }
}
