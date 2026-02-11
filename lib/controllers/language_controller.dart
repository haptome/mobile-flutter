// Purpose: Language controller for managing app localization
// Author: ET Digital Equb Team

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  // Observable for current locale
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  // Available languages
  final List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'nativeName': 'English',
      'locale': const Locale('en', 'US'),
      'flag': '🇺🇸',
      'code': 'en',
    },
    {
      'name': 'Amharic',
      'nativeName': 'አማርኛ',
      'locale': const Locale('am', 'ET'),
      'flag': '🇪🇹',
      'code': 'am',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      final countryCode = prefs.getString('country_code');

      if (languageCode != null && countryCode != null) {
        final locale = Locale(languageCode, countryCode);
        currentLocale.value = locale;
        Get.updateLocale(locale);
      }
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  /// Change app language
  Future<void> changeLanguage(Locale locale) async {
    try {
      // Update GetX locale
      Get.updateLocale(locale);
      currentLocale.value = locale;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');

      // Trigger rebuild
      update();

      // Show success message
      Get.snackbar(
        'language'.tr,
        'settings_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error changing language: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Get current language name
  String getCurrentLanguageName() {
    final language = languages.firstWhere(
      (lang) => lang['locale'] == currentLocale.value,
      orElse: () => languages[0],
    );
    return language['nativeName'];
  }

  /// Get current language flag
  String getCurrentLanguageFlag() {
    final language = languages.firstWhere(
      (lang) => lang['locale'] == currentLocale.value,
      orElse: () => languages[0],
    );
    return language['flag'];
  }

  /// Check if current language is English
  bool isEnglish() {
    return currentLocale.value.languageCode == 'en';
  }

  /// Check if current language is Amharic
  bool isAmharic() {
    return currentLocale.value.languageCode == 'am';
  }

  /// Toggle between English and Amharic
  Future<void> toggleLanguage() async {
    if (isEnglish()) {
      await changeLanguage(const Locale('am', 'ET'));
    } else {
      await changeLanguage(const Locale('en', 'US'));
    }
  }
}
