import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  BuildContext? dialogContext;

  String _getPlatform() {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'Other';
    }
  }

  String _getScreenSize() {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final physicalSize = views.first.physicalSize;
        final devicePixelRatio = views.first.devicePixelRatio;
        final width = (physicalSize.width / devicePixelRatio).round();
        final height = (physicalSize.height / devicePixelRatio).round();
        return '${width}x$height';
      }
    } catch (e) {
      // Fallback if unable to get screen size
    }
    return '0x0';
  }

  String _getTimezone() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = (totalMinutes % 60).abs();

    final sign = hours >= 0 ? '+' : '-';
    final hoursStr = hours.abs().toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');

    return 'UTC$sign$hoursStr:$minutesStr';
  }

  Map<String, String> get _headers => {
        'api-key': apiKey!,
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'platform': _getPlatform(),
        'screen_size': _getScreenSize(),
        'timezone': _getTimezone(),
      };

  void initialize({required String apiKey}) {
    this.apiKey = apiKey;
  }

  Future<Map<String, dynamic>?> _fetchSubscriptionStatus(
      String web2waveUserId) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri =
        Uri.parse('$_baseURL/api/user/subscriptions?user=$web2waveUserId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasActiveSubscription({required String web2waveUserId}) async {
    final subscriptionStatus = await _fetchSubscriptionStatus(web2waveUserId);
    if (subscriptionStatus == null) return false;

    final subscriptions = subscriptionStatus['subscription'] as List<dynamic>?;
    return subscriptions?.any((sub) =>
            sub['status'] == 'active' || sub['status'] == 'trialing') ??
        false;
  }

  Future<List<dynamic>?> fetchSubscriptions(
      {required String web2waveUserId}) async {
    final response = await _fetchSubscriptionStatus(web2waveUserId);
    return response?['subscription'] as List<dynamic>?;
  }

  Future<Web2WaveResponse> chargeUser(
      {required String web2waveUserId, required int priceId}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/subscription/user/charge');

    Map<String, dynamic> body = {
      'user_id': web2waveUserId,
      'price_id': priceId,
    };

    final response = await http.post(uri, body: body, headers: _headers);
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Web2WaveResponse(result['success'] == '1');
    } else {
      return Web2WaveResponse(false, result['message']);
    }
  }

  Future<Web2WaveResponse> cancelSubscription(
      {required String paySystemId, String? comment}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/subscription/cancel');

    Map<String, String> body = {
      'pay_system_id': paySystemId,
    };
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    final response = await http.put(uri, body: body, headers: _headers);
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Web2WaveResponse(result['success'] == '1');
    } else {
      return Web2WaveResponse(false, result['error_msg']);
    }
  }

  Future<Web2WaveResponse> refundSubscription(
      {required String paySystemId,
      required String invoiceId,
      String? comment}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/subscription/refund');

    Map<String, String> body = {
      'pay_system_id': paySystemId,
      'invoice_id': invoiceId,
    };
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    final response = await http.put(uri, body: body, headers: _headers);
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Web2WaveResponse(result['success'] == '1');
    } else {
      return Web2WaveResponse(false, result['error_msg']);
    }
  }

  Future<Map<String, String?>?> fetchUserProperties(
      {required String web2waveUserId}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/properties?user=$web2waveUserId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final propertiesList = data['properties'] as List<dynamic>?;
      return propertiesList?.fold<Map<String, String?>>({}, (map, item) {
        map[item['property']] = item['value'];
        return map;
      });
    }
    return null;
  }

  Future<Web2WaveResponse> updateUserProperty(
      {required String web2waveUserId,
      required String property,
      required String value}) async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/properties?user=$web2waveUserId');
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
      {required String web2waveUserId,
      required String revenuecatProfileId}) async {
    return updateUserProperty(
        web2waveUserId: web2waveUserId,
        property: 'revenuecat_profile_id',
        value: revenuecatProfileId);
  }

  Future<Web2WaveResponse> setAdaptyProfileID(
      {required String web2waveUserId, required String adaptyProfileId}) async {
    return updateUserProperty(
        web2waveUserId: web2waveUserId,
        property: 'adapty_profile_id',
        value: adaptyProfileId);
  }

  Future<Web2WaveResponse> setQonversionProfileID(
      {required String web2waveUserId,
      required String qonverionProfileId}) async {
    return updateUserProperty(
        web2waveUserId: web2waveUserId,
        property: 'qonversion_profile_id',
        value: qonverionProfileId);
  }

  Future<Map<String, dynamic>?> identify() async {
    assert(apiKey != null, 'You must initialize apiKey before use');

    final uri = Uri.parse('$_baseURL/api/user/identify');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
