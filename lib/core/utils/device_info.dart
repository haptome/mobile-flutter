// Purpose: Device information utility for registration and analytics
// Author: Auto-generated

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfo {
  static const _deviceIdKey = 'et_ekub_device_id';
  static String? _cachedDeviceId;

  /// Get device type (android, ios, web, etc.)
  static String getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Returns a stable device ID.
  /// Uses the real hardware ID (Android ID / identifierForVendor on iOS),
  /// falling back to a UUID that is persisted in SharedPreferences.
  static Future<String> getDeviceIdAsync() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final plugin = DeviceInfoPlugin();
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final info = await plugin.androidInfo;
          // androidId is stable per device + app signing key
          if (info.id.isNotEmpty) {
            _cachedDeviceId = info.id;
            return _cachedDeviceId!;
          }
        } else if (Platform.isIOS) {
          final info = await plugin.iosInfo;
          // identifierForVendor is stable per vendor per device
          final vendorId = info.identifierForVendor;
          if (vendorId != null && vendorId.isNotEmpty) {
            _cachedDeviceId = vendorId;
            return _cachedDeviceId!;
          }
        }
      }
    } catch (e) {
      debugPrint('DeviceInfo: could not read hardware ID: $e');
    }

    // Fallback: persist a UUID so it survives app restarts
    return _getOrCreatePersistedId();
  }

  static Future<String> _getOrCreatePersistedId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      _cachedDeviceId = existing;
      return existing;
    }
    final newId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, newId);
    _cachedDeviceId = newId;
    return newId;
  }

  /// Synchronous getter — returns cached value or a placeholder if not yet loaded.
  /// Call [getDeviceIdAsync] at app startup to pre-warm the cache.
  static String getDeviceId() {
    return _cachedDeviceId ?? 'pending-device-id';
  }

  /// Check if device is mobile
  static bool isMobile() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
