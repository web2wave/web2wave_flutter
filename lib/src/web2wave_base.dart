import 'package:http/http.dart' as http;
import 'dart:convert';

class Web2WaveResponse {
  bool isSuccess;
  String? errorMessage;

  Web2WaveResponse(this.isSuccess, [this.errorMessage]);
}

class Web2Wave {
  static final Web2Wave shared = Web2Wave._internal();

  Web2Wave._internal();

  final String _baseURL = 'https://api.web2wave.com';
  String? apiKey;

  Map<String, String> get _headers => {
        'api-key': apiKey!,
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      };

  void initialize({required String apiKey}) {
    this.apiKey = apiKey;
  }

  Future<Map<String, dynamic>?> _fetchSubscriptionStatus(String userId) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/subscriptions?user=$userId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasActiveSubscription({required String userId}) async {
    final subscriptionStatus = await _fetchSubscriptionStatus(userId);
    if (subscriptionStatus == null) return false;

    final subscriptions = subscriptionStatus['subscription'] as List<dynamic>?;
    return subscriptions?.any((sub) =>
            sub['status'] == 'active' || sub['status'] == 'trialing') ??
        false;
  }

  Future<List<dynamic>?> fetchSubscriptions({required String userId}) async {
    final response = await _fetchSubscriptionStatus(userId);
    return response?['subscription'] as List<dynamic>?;
  }

  Future<Map<String, String>?> fetchUserProperties(
      {required String userId}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/properties?user=$userId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final propertiesList = data['properties'] as List<dynamic>?;
      return propertiesList?.fold<Map<String, String>>({}, (map, item) {
        map[item['property']] = item['value'];
        return map;
      });
    }
    return null;
  }

  Future<Web2WaveResponse> updateUserProperty(
      {required String userId,
      required String property,
      required String value}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/properties?user=$userId');
    final response = await http.post(uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode({'property': property, 'value': value}));

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Web2WaveResponse(result['result'] == '1');
    } else {
      return Web2WaveResponse(false, result['error_msg']);
    }
  }

  Future<Web2WaveResponse> setRevenuecatProfileID(
      {required String userId, required String revenuecatProfileId}) async {
    return updateUserProperty(
        userId: userId,
        property: 'revenuecat_profile_id',
        value: revenuecatProfileId);
  }

  Future<Web2WaveResponse> setAdaptyProfileID(
      {required String userId, required String adaptyProfileId}) async {
    return updateUserProperty(
        userId: userId, property: 'adapty_profile_id', value: adaptyProfileId);
  }

  Future<Web2WaveResponse> setQonversionProfileID(
      {required String userId, required String qonverionProfileId}) async {
    return updateUserProperty(
        userId: userId,
        property: 'qonversion_profile_id',
        value: qonverionProfileId);
  }
}
