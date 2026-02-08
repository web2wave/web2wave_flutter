import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformInfo {
  static final _deviceInfo = DeviceInfoPlugin();
  static String? _cachedOsVersion;

  static Future<String> getOsVersion() async {
    if (_cachedOsVersion != null) return _cachedOsVersion!;

    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      _cachedOsVersion = ios.systemVersion; // "18.4.1"
      return _cachedOsVersion!;
    }

    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      _cachedOsVersion = android.version.release; // "10", "7.0"
      return _cachedOsVersion!;
    }

    return 'unknown';
  }
}
