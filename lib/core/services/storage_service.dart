// Purpose: Secure storage service for tokens and sensitive data
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../models/user_model.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage (for tokens)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: 'fcm_token', value: token);
  }

  Future<String?> getFcmToken() async {
    return await _secureStorage.read(key: 'fcm_token');
  }

  Future<void> clearFcmToken() async {
    await _secureStorage.delete(key: 'fcm_token');
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
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
    await _secureStorage.deleteAll();
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
