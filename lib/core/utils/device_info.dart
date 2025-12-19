// Purpose: Device information utility for registration and analytics
// Author: Auto-generated

import 'dart:io';
import 'package:flutter/foundation.dart';

class DeviceInfo {
  /// Get device type (android, ios, web, etc.)
  static String getDeviceType() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }

  /// Get device ID placeholder
  /// Note: For production, use device_info_plus package
  /// Example: final deviceInfo = await DeviceInfoPlugin().androidInfo;
  ///          deviceId = deviceInfo.id;
  static String getDeviceId() {
    // TODO: Implement with device_info_plus package
    // For now, return a placeholder
    return 'device-uuid-placeholder';
  }

  /// Check if device is mobile
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }
}

