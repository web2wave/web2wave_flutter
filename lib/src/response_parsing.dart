import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of a write call to the Web2Wave API.
///
/// [errorMessage] carries the reason reported by the backend (`error_msg`
/// or `message`) when [isSuccess] is false.
class Web2WaveResponse {
  bool isSuccess;
  String? errorMessage;

  Web2WaveResponse(this.isSuccess, [this.errorMessage]);
}

/// Whether a backend `success` / `result` flag means success.
///
/// The API is not consistent about the type of this flag: cancel and charge
/// return `true`, refund returns the number `1`, user properties return the
/// string `"1"`. All of them (and `"true"`) count as success.
bool isSuccessValue(dynamic value) {
  if (value == true || value == 1) return true;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

/// Decodes a JSON object body, or returns null when the body is empty,
/// not JSON (e.g. an HTML error page from a proxy) or not an object.
Map<String, dynamic>? decodeJsonObject(String body) {
  if (body.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// The error reason from a backend response: `error_msg` first, then
/// `message`, ignoring empty values.
String? extractErrorMessage(Map<String, dynamic>? result) {
  if (result == null) return null;
  for (final key in const ['error_msg', 'message']) {
    final value = result[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

/// Turns an HTTP response of a write endpoint into a [Web2WaveResponse].
///
/// Succeeds only for a 2xx status whose [successKey] flag passes
/// [isSuccessValue]. Otherwise the backend reason is returned as the error
/// message (for example a 403 about a missing API key scope), falling back
/// to the HTTP status when the body has none.
Web2WaveResponse parseActionResponse(
  http.Response response, {
  String successKey = 'success',
}) {
  final result = decodeJsonObject(response.body);
  final isHttpSuccess = response.statusCode >= 200 && response.statusCode < 300;

  if (isHttpSuccess && result != null && isSuccessValue(result[successKey])) {
    return Web2WaveResponse(true);
  }

  return Web2WaveResponse(
    false,
    extractErrorMessage(result) ??
        (isHttpSuccess
            ? 'Unexpected response from Web2Wave API'
            : 'Web2Wave API request failed with HTTP ${response.statusCode}'),
  );
}
