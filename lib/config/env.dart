// Purpose: Environment configuration for ET Digital Ekub Mobile App
// Author: haptome H.
// Linked Spec Section: FR01-FR03

class Env {
  // API Base URLs
  static const String apiBaseUrl = 'http://localhost:3001/api/v1';
  static const String userServiceUrl = 'http://localhost:3002/api/v1';
  static const String groupServiceUrl = 'http://localhost:3003/api/v1';
  static const String walletServiceUrl = 'http://localhost:3004/api/v1';
  static const String paymentServiceUrl = 'http://localhost:3005/api/v1';
  static const String rotationServiceUrl = 'http://localhost:3006/api/v1';
  static const String notificationServiceUrl = 'http://localhost:3007/api/v1';
  static const String chatServiceUrl = 'ws://localhost:3008';
  static const String ussdServiceUrl = 'http://localhost:3009/api/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String languageKey = 'language';

  // App Configuration
  static const String appName = 'ET Digital Ekub';
  static const String appVersion = '1.0.0';
}

