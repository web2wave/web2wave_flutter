import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:web2wave/web2wave.dart';

void main() {
  final web2wave = Web2Wave.shared;
  late List<http.Request> requests;

  void respondWith(String body, int status) {
    requests = [];
    web2wave.httpClient = MockClient((request) async {
      requests.add(request);
      return http.Response(
        body,
        status,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  setUp(() => web2wave.initialize(apiKey: 'test-key'));

  test('cancelSubscription reports success: true as success', () async {
    respondWith('{"success": true, "error": 0, "message": "ok"}', 200);
    final r = await web2wave.cancelSubscription(paySystemId: 'sub_1');
    expect(r.isSuccess, isTrue);
    expect(requests.single.method, 'PUT');
    expect(requests.single.url.path, '/api/subscription/cancel');
    expect(requests.single.headers['api-key'], 'test-key');
    expect(requests.single.bodyFields['pay_system_id'], 'sub_1');
  });

  test('cancelSubscription surfaces a 403 scope error', () async {
    respondWith(
      '{"error":1,"error_msg":"This API key does not have the '
      '\'subscriptions:write\' scope","required_scope":"subscriptions:write"}',
      403,
    );
    final r = await web2wave.cancelSubscription(paySystemId: 'sub_1');
    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, contains('subscriptions:write'));
  });

  test('refundSubscription reports success: 1 as success', () async {
    respondWith(
      '{"success": 1, "error": 0, "message": "Request accepted"}',
      200,
    );
    final r = await web2wave.refundSubscription(
      paySystemId: 'sub_1',
      invoiceId: 'in_1',
    );
    expect(r.isSuccess, isTrue);
    expect(requests.single.bodyFields['invoice_id'], 'in_1');
  });

  test('refundSubscription surfaces error_msg on 400', () async {
    respondWith('{"error":1,"error_msg":"Invoice not found"}', 400);
    final r = await web2wave.refundSubscription(
      paySystemId: 'sub_1',
      invoiceId: 'in_1',
    );
    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, 'Invoice not found');
  });

  test('chargeUser sends JSON with an integer price_id', () async {
    respondWith(
      '{"success": true, "message": "ok", "subscription_id": 7}',
      200,
    );
    final r = await web2wave.chargeUser(web2waveUserId: 'u1', priceId: 123);
    expect(r.isSuccess, isTrue);
    final req = requests.single;
    expect(req.method, 'POST');
    expect(req.url.path, '/api/subscription/user/charge');
    expect(req.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(req.body), {'user_id': 'u1', 'price_id': 123});
  });

  test('chargeUser reports success: false with its message', () async {
    respondWith('{"success": false, "message": "Card declined"}', 200);
    final r = await web2wave.chargeUser(web2waveUserId: 'u1', priceId: 123);
    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, 'Card declined');
  });

  test('updateUserProperty keeps result: "1" handling', () async {
    respondWith('{"result":"1"}', 200);
    final r = await web2wave.updateUserProperty(
      web2waveUserId: 'u1',
      property: 'p',
      value: 'v',
    );
    expect(r.isSuccess, isTrue);
  });
}
