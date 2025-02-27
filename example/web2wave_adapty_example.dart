import 'package:flutter/material.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:web2wave/web2wave.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  late AppsFlyerSdk _appsflyerSdk;

  @override
  void initState() {
    super.initState();
    Web2Wave.shared.initialize(apiKey: 'your-api-key');
    Adapty().activatePublicSdkKey('your_adapty_public_sdk_key');

    _appsflyerSdk = AppsFlyerSdk(
      AppsFlyerOptions(afDevKey: 'your_apps_flyer_dev_key', appId: 'your_app_id', showDebug: true),
    )..onDeepLink((deepLinkData) => _handleDeepLink(deepLinkData))
     ..startSDK();
  }

  void _handleDeepLink(Map<String, dynamic> deepLink) async {
    final deepLinkValue = deepLink['deep_link_value'];
    if (deepLinkValue is String) {
      try {
        final extractedUserId = jsonDecode(deepLinkValue)['user_id'];
        if (extractedUserId is String) {
          setState(() => userId = extractedUserId);
          final profile = await Adapty().getProfile();
          if (profile?.profileId != null) {
            await Web2Wave.shared.setAdaptyProfileID(userId: extractedUserId, adaptyProfileId: profile!.profileId!);
          }
        }
      } catch (e) {
        print('Error parsing deep link JSON: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Web2Wave Integration')),
      body: Center(
        child: Text(userId != null ? 'User ID: $userId' : 'Waiting for deep link...'),
      ),
    );
  }
}
