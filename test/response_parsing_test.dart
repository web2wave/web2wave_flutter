import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:web2wave/src/response_parsing.dart';

void main() {
  group('isSuccessValue', () {
    test('accepts the success flags the API returns', () {
      expect(isSuccessValue(true), isTrue);
      expect(isSuccessValue(1), isTrue);
      expect(isSuccessValue('1'), isTrue);
      expect(isSuccessValue('true'), isTrue);
      expect(isSuccessValue('TRUE'), isTrue);
    });

    test('rejects everything else', () {
      expect(isSuccessValue(false), isFalse);
      expect(isSuccessValue(0), isFalse);
      expect(isSuccessValue('0'), isFalse);
      expect(isSuccessValue('false'), isFalse);
      expect(isSuccessValue(''), isFalse);
      expect(isSuccessValue(null), isFalse);
      expect(isSuccessValue(2), isFalse);
    });
  });

  group('extractErrorMessage', () {
    test('prefers error_msg over message and skips empty values', () {
      expect(
        extractErrorMessage({'error': 1, 'error_msg': 'boom', 'message': ''}),
        'boom',
      );
      expect(
        extractErrorMessage({'error_msg': '', 'message': 'from message'}),
        'from message',
      );
      expect(extractErrorMessage({'success': false}), isNull);
      expect(extractErrorMessage(null), isNull);
    });
  });

  group('parseActionResponse', () {
    http.Response res(String body, int status) => http.Response(body, status);

    test('cancel success (success: true)', () {
      final r = parseActionResponse(
        res('{"success": true, "error": 0, "message": "Cancelled"}', 200),
      );
      expect(r.isSuccess, isTrue);
      expect(r.errorMessage, isNull);
    });

    test('refund success (success: 1)', () {
      final r = parseActionResponse(
        res('{"success": 1, "error": 0, "message": "Request accepted"}', 200),
      );
      expect(r.isSuccess, isTrue);
    });

    test('charge success (success: true)', () {
      final r = parseActionResponse(
        res(
          '{"success": true, "message": "Charged", "subscription_id": 42}',
          200,
        ),
      );
      expect(r.isSuccess, isTrue);
    });

    test('charge failure with HTTP 200 carries the message', () {
      final r = parseActionResponse(
        res('{"success": false, "message": "Please, select a price."}', 200),
      );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, 'Please, select a price.');
    });

    test('user property success (result: "1")', () {
      final r = parseActionResponse(
        res('{"result":"1"}', 200),
        successKey: 'result',
      );
      expect(r.isSuccess, isTrue);
    });

    test('400 uses error_msg, not the empty message', () {
      final r = parseActionResponse(
        res(
          '{"error":1,"error_msg":"Subscription not found","message":""}',
          400,
        ),
      );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, 'Subscription not found');
    });

    test('403 missing scope reaches the caller', () {
      final r = parseActionResponse(
        res(
          '{"error":1,"error_msg":"This API key does not have the '
          '\'subscriptions:write\' scope","required_scope":"subscriptions:write"}',
          403,
        ),
      );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('subscriptions:write'));
    });

    test('2xx with error flag in body is not a success', () {
      final r = parseActionResponse(res('{"error":1,"error_msg":"x"}', 200));
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, 'x');
    });

    test('non-JSON error body does not throw', () {
      final r = parseActionResponse(
        res('<html><body>502 Bad Gateway</body></html>', 502),
      );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('502'));
    });

    test('empty body does not throw', () {
      final r = parseActionResponse(res('', 500));
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('500'));
    });

    test('JSON array body is not a success', () {
      final r = parseActionResponse(res('[]', 200));
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, isNotNull);
    });
  });
}
