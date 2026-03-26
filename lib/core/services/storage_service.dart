// Purpose: Secure storage service for tokens and sensitive data
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../models/user_model.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage (for tokens)
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage
          .write(key: 'access_token', value: token)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] saveAccessToken failed (degraded mode): $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage
          .read(key: 'access_token')
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
    } catch (e) {
      debugPrint('[StorageService] getAccessToken failed (degraded mode): $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage
          .write(key: 'refresh_token', value: token)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] saveRefreshToken failed (degraded mode): $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage
          .read(key: 'refresh_token')
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
    } catch (e) {
      debugPrint('[StorageService] getRefreshToken failed (degraded mode): $e');
      return null;
    }
  }

  Future<void> saveFcmToken(String token) async {
    try {
      await _secureStorage
          .write(key: 'fcm_token', value: token)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] saveFcmToken failed, falling back to prefs: $e');
      await _prefs.setString('fcm_token', token);
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _secureStorage
          .read(key: 'fcm_token')
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
    } catch (e) {
      debugPrint('[StorageService] getFcmToken failed (degraded mode): $e');
      return null;
    }
  }

  Future<void> clearFcmToken() async {
    try {
      await _secureStorage
          .delete(key: 'fcm_token')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] clearFcmToken failed, falling back to prefs: $e');
      await _prefs.remove('fcm_token');
    }
  }

  Future<void> clearTokens() async {
    try {
      await _secureStorage
          .delete(key: 'access_token')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] clearTokens (access_token) failed (degraded mode): $e');
    }
    try {
      await _secureStorage
          .delete(key: 'refresh_token')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] clearTokens (refresh_token) failed (degraded mode): $e');
    }
  }

  // User data storage (using SharedPreferences for JSON storage)
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString('user_data', userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString('user_data');
    if (userJson == null) return null;
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove('user_data');
  }

  // Preferences (for non-sensitive data)
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage
          .deleteAll()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[StorageService] clearAll (secure) failed (degraded mode): $e');
    }
    await _prefs.clear();
  }

  // Language preference
  Future<void> saveLanguage(String languageCode) async {
    await saveString('language', languageCode);
  }

  String? getLanguage() {
    return getString('language');
  }
}
