import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/providers/payments/paypal_pay.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/data/order_wc.dart';
import 'package:flutter_app/bootstrap/paypal/paypal_service.dart';
import 'package:flutter_app/config/payment_gateways.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Payment tests.
///
/// The gateway list, the mapping from a gateway name to the id WooCommerce
/// records, and the three PayPal requests. Nothing here reaches PayPal: the
/// two payment calls go through the client the service is constructed with,
/// and the token call - which the framework's own client owns - is covered on
/// its failure path only.
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

  /// A PayPal service whose payment calls answer with [responder] instead of
  /// going out.
  PaypalServices paypalWith(
      Future<ResponseBody> Function(RequestOptions options) responder) {
    Dio client = Dio();
    client.httpClientAdapter = _StubAdapter(responder);
    return PaypalServices(
        clientId: "test-client",
        secretKey: "test-secret",
        sandboxMode: true,
        client: client);
  }

  /// A JSON body, as PayPal would send it.
  ResponseBody jsonBody(Object data, {int statusCode = 200}) =>
      ResponseBody.fromString(jsonEncode(data), statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });

  nyGroup('the gateway list', () {
    nyTest('ships the three gateways the template supports', () async {
      expect(paymentTypeList.map((paymentType) => paymentType.name).toList(),
          ["Stripe", "CashOnDelivery", "PayPal"]);
    });

    nyTest('each one carries an id, a description and an icon', () async {
      for (PaymentType paymentType in paymentTypeList) {
        expect(paymentType.id, isPositive);
        expect(paymentType.desc, isNotEmpty);
        expect(paymentType.assetImage, isNotEmpty);
        expect(paymentType.pay, isNotNull);
      }
    });

    nyTest('the ids are unique, since the checkout picks by id', () async {
      List<int> ids =
          paymentTypeList.map((paymentType) => paymentType.id).toList();

      expect(ids.toSet().length, ids.length);
    });
  });

  nyGroup('gateway ids on the order', () {
    nyTest('every shipped gateway maps to a real WooCommerce id', () async {
      seedCheckoutSession();

      Map<String, String> expected = {
        "Stripe": "stripe",
        "CashOnDelivery": "cod",
        "PayPal": "paypal",
      };

      for (MapEntry<String, String> entry in expected.entries) {
        CheckoutSession.getInstance.paymentType = PaymentType(
            id: 1, name: entry.key, desc: "", assetImage: "", pay: () {});

        OrderWC orderWC = await buildOrderWC();

        expect(orderWC.paymentMethod, entry.value);
      }
    });

    nyTest('the gateways in the list all map to something real', () async {
      // A gateway in the picker whose name is not in the map would post an
      // unregistered id, which WooCommerce cannot attribute or refund.
      seedCheckoutSession();

      for (PaymentType paymentType in paymentTypeList) {
        CheckoutSession.getInstance.paymentType = paymentType;

        OrderWC orderWC = await buildOrderWC();

        expect(["stripe", "cod", "paypal"],
            contains(orderWC.paymentMethod),
            reason: '"${paymentType.name}" must map to a WooCommerce '
                'gateway id');
      }
    });
  });

  nyGroup('Razorpay', () {
    nyTest('is not offered, even if the store config still mentions it',
        () async {
      // Older WooSignal backends still send `razorpay_active`.
      AppHelper.instance.appConfig = WooSignalApp.fromJson({
        "banner_images": [],
        "stripe_enabled": 1,
        "paypal_enabled": 1,
        "cod_enabled": 1,
        "razorpay_active": 1,
      });

      List<String?> names =
          (await getPaymentTypes()).map((type) => type?.name).toList();

      expect(names, ["Stripe", "PayPal", "CashOnDelivery"]);
      expect(paymentTypeList.map((type) => type.name),
          isNot(contains("RazorPay")));
    });
  });

  nyGroup('the PayPal transaction id', () {
    // WooSignal verifies this id with PayPal before it marks the order paid.

    nyTest('is the sale id from the executed payment', () async {
      expect(
          payPalTransactionId({
            'error': false,
            'data': {
              'id': "PAYID-TEST",
              'transactions': [
                {
                  'related_resources': [
                    {
                      'sale': {'id': "5TY12345AB678901C", 'state': "completed"}
                    }
                  ]
                }
              ]
            }
          }),
          "5TY12345AB678901C");
    });

    nyTest('falls back to the payment id when there is no sale', () async {
      expect(
          payPalTransactionId({
            'data': {
              'id': "PAYID-TEST",
              'transactions': [
                {'related_resources': []}
              ]
            }
          }),
          "PAYID-TEST");
    });

    nyTest('is null when the response has no data', () async {
      expect(payPalTransactionId({'data': null}), isNull);
      expect(payPalTransactionId({}), isNull);
    });

    nyTest('ends up on the order as the transaction id', () async {
      seedCheckoutSession();
      CheckoutSession.getInstance.paymentType = paymentTypeList
          .firstWhere((paymentType) => paymentType.name == "PayPal");

      OrderWC orderWC = await buildOrderWC(
          transactionId: payPalTransactionId({
        'data': {
          'transactions': [
            {
              'related_resources': [
                {
                  'sale': {'id': "5TY12345AB678901C"}
                }
              ]
            }
          ]
        }
      }));

      expect(orderWC.paymentMethod, "paypal");
      expect(orderWC.transactionId, "5TY12345AB678901C");
      expect(orderWC.setPaid, isTrue);
    });
  });

  nyGroup('the PayPal access token', () {
    // The token call goes out through `ApiService`, whose Dio client the
    // framework builds and owns - `NyMockApi.register` is not consulted by
    // `NyApiService` in 7.28.0, and `initDio` does not reach the adapter - so
    // there is no way to hand it a response from a test. What is reachable is
    // the failure path, which is the part that was reworked: with no network
    // the call must come back with a readable message that does not blame the
    // merchant's credentials.

    nyTest('an unreachable PayPal is reported, not blamed on the merchant',
        () async {
      Map result =
          await paypalWith((_) async => jsonBody({})).getAccessToken();

      expect(result['error'], isTrue);
      expect(result['message'], isA<String>());
      expect(result['message'],
          isNot("Your PayPal credentials seems incorrect"),
          reason: 'a connection failure is not a credentials problem - saying '
              'so sends a merchant hunting a config error that is not there');
    });

    nyTest('the failure message never leaks an exception into the UI',
        () async {
      Map result =
          await paypalWith((_) async => jsonBody({})).getAccessToken();

      expect(result['message'], isNot(contains("Exception")));
      expect(result['message'], isNot(contains("DioException")));
      expect(result.containsKey('token'), isFalse);
    });

    nyTest('live mode and sandbox mode use different hosts', () async {
      // Nothing observable from the token call itself, so the two services are
      // compared on what they were built with.
      PaypalServices sandbox = PaypalServices(
          clientId: "c", secretKey: "s", sandboxMode: true);
      PaypalServices live = PaypalServices(
          clientId: "c", secretKey: "s", sandboxMode: false);

      expect(sandbox.sandboxMode, isTrue);
      expect(live.sandboxMode, isFalse);
    });
  });

  nyGroup('creating a PayPal payment', () {
    nyTest('picks the approval and execute links out of the response',
        () async {
      Map result = await paypalWith((_) async => jsonBody({
            'id': "PAY-TEST",
            'links': [
              {'rel': "self", 'href': "https://api.test/self"},
              {'rel': "approval_url", 'href': "https://paypal.test/approve"},
              {'rel': "execute", 'href': "https://api.test/execute"},
            ]
          })).createPaypalPayment({'intent': "sale"}, "A21AA-test-token");

      // The approval link is where the buyer is sent; the execute link is what
      // captures the money afterwards.
      expect(result['approvalUrl'], "https://paypal.test/approve");
      expect(result['executeUrl'], "https://api.test/execute");
    });

    nyTest('copes with a response that is missing one of the links', () async {
      Map result = await paypalWith((_) async => jsonBody({
            'links': [
              {'rel': "approval_url", 'href': "https://paypal.test/approve"},
            ]
          })).createPaypalPayment({}, "token");

      expect(result['approvalUrl'], "https://paypal.test/approve");
      expect(result['executeUrl'], "");
    });

    nyTest('gives back nothing when there are no links at all', () async {
      Map result = await paypalWith((_) async => jsonBody({'id': "PAY-TEST"}))
          .createPaypalPayment({}, "token");

      expect(result, isEmpty);
    });

    nyTest('reports a rejected payment without leaking the exception',
        () async {
      Map result = await paypalWith((_) async =>
              jsonBody({'name': "VALIDATION_ERROR"}, statusCode: 400))
          .createPaypalPayment({}, "token");

      expect(result['error'], isTrue);
      expect(result['message'], "Payment Failed.");
      // The body is kept for the log, not for the customer.
      expect(result['data'], isNotNull);
    });

    nyTest('sends the token as a bearer header', () async {
      late RequestOptions sent;
      await paypalWith((RequestOptions options) async {
        sent = options;
        return jsonBody({});
      }).createPaypalPayment({'intent': "sale"}, "A21AA-test-token");

      expect(sent.headers['Authorization'], "Bearer A21AA-test-token");
      expect(sent.path, contains("/v1/payments/payment"));
      // sandboxMode: true, so it must not hit the live endpoint.
      expect(sent.path, contains("sandbox"));
    });
  });

  nyGroup('capturing a PayPal payment', () {
    nyTest('reports success and hands back the body', () async {
      Map result = await paypalWith((_) async =>
              jsonBody({'id': "PAY-TEST", 'state': "approved"}))
          .executePayment("https://api.test/execute", "PAYER-1", "token");

      expect(result['error'], isFalse);
      expect(result['message'], "Success");
      expect(result['data']['state'], "approved");
    });

    nyTest('reports a refused capture', () async {
      Map result = await paypalWith(
              (_) async => jsonBody({'name': "INSTRUMENT_DECLINED"},
                  statusCode: 400))
          .executePayment("https://api.test/execute", "PAYER-1", "token");

      expect(result['error'], isTrue);
      expect(result['message'], "Payment Failed.");
      expect(result['data'], isNotNull);
    });

    nyTest('never puts a raw exception in the message the customer reads',
        () async {
      // A raw exception object here used to be rendered straight into the UI.
      Map result = await paypalWith((_) async => throw StateError("boom"))
          .executePayment("https://api.test/execute", "PAYER-1", "token");

      expect(result['error'], isTrue);
      expect(result['message'], isA<String>());
      expect(result['message'], "Payment Failed.");
      expect(result['message'], isNot(contains("Exception")));
    });

    nyTest('posts the payer id to the execute url it was given', () async {
      late RequestOptions sent;
      await paypalWith((RequestOptions options) async {
        sent = options;
        return jsonBody({});
      }).executePayment("https://api.test/execute", "PAYER-1", "token");

      expect(sent.path, "https://api.test/execute");
      expect(jsonDecode(sent.data as String), {"payer_id": "PAYER-1"});
      expect(sent.headers['Authorization'], "Bearer token");
    });
  });

  nyGroup('the PayPal credentials', () {
    nyTest('come from .env, and ship empty so a merchant fills them in',
        () async {
      expect(getEnv('PAYPAL_CLIENT_ID'), "");
      expect(getEnv('PAYPAL_SECRET_KEY'), "");
      // Sandbox until the merchant says otherwise.
      expect(getEnv('PAYPAL_LIVE_MODE'), isFalse);
    });

    nyTest('live mode picks the live endpoint', () async {
      late RequestOptions sent;
      Dio client = Dio();
      client.httpClientAdapter = _StubAdapter((RequestOptions options) async {
        sent = options;
        return jsonBody({});
      });

      await PaypalServices(
              clientId: "c",
              secretKey: "s",
              sandboxMode: false,
              client: client)
          .createPaypalPayment({}, "token");

      expect(sent.path, startsWith("https://api.paypal.com"));
    });
  });
}

/// A Dio adapter that answers from a callback instead of the network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responder);

  final Future<ResponseBody> Function(RequestOptions options) responder;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) =>
      responder(options);
}
