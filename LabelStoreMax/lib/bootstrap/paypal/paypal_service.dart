import 'dart:convert';
import 'dart:async';
import 'dart:convert' as convert;

import '/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PaypalServices {
  final String clientId, secretKey;
  final bool sandboxMode;

  /// The client the two PayPal payment calls go out on.
  ///
  /// Defaults to a plain [Dio], which is what it was before. It is injectable
  /// only so a test can hand in a client with a mock adapter: these two calls
  /// do not go through [ApiService], so Nylo's API mocking cannot reach them.
  final Dio _client;

  PaypalServices({
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    Dio? client,
  }) : _client = client ?? Dio();

  Future<Map> getAccessToken() async {
    String baseUrl = sandboxMode
        ? "https://api-m.sandbox.paypal.com"
        : "https://api.paypal.com";

    try {
      String authToken = base64.encode(
        utf8.encode("$clientId:$secretKey"),
      );
      final dynamic body = await api<ApiService>(
          (request) => request
              .post('$baseUrl/v1/oauth2/token?grant_type=client_credentials'),
          headers: {
            'Authorization': 'Basic $authToken',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return {
        'error': false,
        'message': "Success",
        'token': body["access_token"]
      };
    } on DioException catch (e, stackTrace) {
      // Only 401/403 actually mean bad credentials. Reporting a timeout or a
      // 5xx as "credentials incorrect" sends merchants hunting a config problem
      // that isn't there.
      int? statusCode = e.response?.statusCode;
      bool isAuthFailure = statusCode == 401 || statusCode == 403;

      NyLogger.error(
        "PayPal getAccessToken failed "
        "(status: ${statusCode ?? 'none'}, type: ${e.type}): ${e.message}\n"
        "$stackTrace",
      );

      return {
        'error': true,
        'message': isAuthFailure
            ? "Your PayPal credentials seems incorrect"
            : "Unable to reach PayPal, please try again shortly."
      };
    } catch (e, stackTrace) {
      // Previously swallowed silently and blamed the user's connection, which
      // is wrong for a PayPal API or parsing failure and left nothing to debug.
      NyLogger.error("PayPal getAccessToken failed: $e\n$stackTrace");

      return {
        'error': true,
        'message': "Unable to proceed, please try again shortly."
      };
    }
  }

  Future<Map> createPaypalPayment(
    Map transactions,
    String accessToken,
  ) async {
    String domain = sandboxMode
        ? "https://api.sandbox.paypal.com"
        : "https://api.paypal.com";

    try {
      final Response<dynamic> response =
          await _client.post('$domain/v1/payments/payment',
              data: jsonEncode(transactions),
              options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json'
                },
              ));

      final dynamic body = response.data;
      if (body["links"] != null && body["links"].length > 0) {
        List links = body["links"];

        String executeUrl = "";
        String approvalUrl = "";
        final dynamic item = links.firstWhere((o) => o["rel"] == "approval_url",
            orElse: () => null);
        if (item != null) {
          approvalUrl = item["href"];
        }
        final dynamic item1 =
            links.firstWhere((o) => o["rel"] == "execute", orElse: () => null);
        if (item1 != null) {
          executeUrl = item1["href"];
        }
        return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
      }
      return {};
    } on DioException catch (e, stackTrace) {
      NyLogger.error(
        "PayPal createPaypalPayment failed "
        "(status: ${e.response?.statusCode ?? 'none'}, type: ${e.type}): "
        "${e.message}\n${e.response?.data}\n$stackTrace",
      );

      return {
        'error': true,
        'message': "Payment Failed.",
        'data': e.response?.data,
      };
    } catch (e, stackTrace) {
      // Rethrown deliberately, but log first — callers do not wrap this and an
      // uncaught error here surfaces with no record of what actually failed.
      NyLogger.error("PayPal createPaypalPayment failed: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<Map> executePayment(
    String url,
    String payerId,
    String accessToken,
  ) async {
    try {
      final Response<dynamic> response = await _client.post(url,
          data: convert.jsonEncode({"payer_id": payerId}),
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json'
            },
          ));

      final dynamic body = response.data;
      return {'error': false, 'message': "Success", 'data': body};
    } on DioException catch (e, stackTrace) {
      // Payment CAPTURE path. If this fails the buyer may already have approved
      // the payment, so the log is the only record tying the attempt to a payer.
      NyLogger.error(
        "PayPal executePayment failed for payerId=$payerId "
        "(status: ${e.response?.statusCode ?? 'none'}, type: ${e.type}): "
        "${e.message}\n${e.response?.data}\n$stackTrace",
      );

      return {
        'error': true,
        'message': "Payment Failed.",
        'data': e.response?.data,
      };
    } catch (e, stackTrace) {
      NyLogger.error(
        "PayPal executePayment failed for payerId=$payerId: $e\n$stackTrace",
      );

      // 'message' must stay a String — it is rendered to the user, and a raw
      // exception object here leaks "Exception: ..." into the UI.
      return {
        'error': true,
        'message': "Payment Failed.",
        'exception': true,
        'data': null,
      };
    }
  }
}
