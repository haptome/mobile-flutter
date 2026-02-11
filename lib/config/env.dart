// Purpose: Environment configuration for ET Digital Ekub Mobile App
// Author: haptome H.
// Linked Spec Section: FR01-FR03

/// Environment enum for app configuration
enum AppEnvironment { development, staging, production }

/// Environment configuration for the mobile app
/// All API requests go through the API Gateway which routes to appropriate microservices
class Env {
  // ========== Environment Configuration ==========
  // Change this to switch between environments
  static const AppEnvironment _currentEnvironment = AppEnvironment.development;

  // ========== API Gateway Configuration ==========
  // All services route through the API Gateway
  // The gateway automatically routes based on path prefix:
  // /api/v1/auth/* → Auth Service
  // /api/v1/users/* → User Service
  // /api/v1/groups/* → Group Service
  // /api/v1/wallets/* → Wallet Service
  // /api/v1/payments/* → Payment Service
  // /api/v1/rotations/* → Rotation Service
  // /api/v1/notifications/* → Notification Service
  // /api/v1/chat/* → Chat Service (REST)
  // /socket.io/* → Chat Service (WebSocket)
  // /api/v1/ussd/* → USSD Service

  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case AppEnvironment.development:
        // API Gateway on port 3000 routes to:
        // - Auth Service (port 3807) via /api/v1/auth/* and /api/v1/otp/*
        // - User Service (port 3806) via /api/v1/users/*
        // - Other services via their respective path prefixes
        return 'http://localhost:3000/api/v1';
      case AppEnvironment.staging:
        return 'http://188.245.198.252:3000/api/v1';
      case AppEnvironment.production:
        return 'https://api.et-ekub.com/api/v1';
    }
  }

  // WebSocket URL for chat (routed through gateway)
  static String get chatServiceUrl {
    switch (_currentEnvironment) {
      case AppEnvironment.development:
        // WebSocket connections route through gateway on port 3000
        return 'ws://localhost:3000/socket.io';
      case AppEnvironment.staging:
        return 'wss://staging-api.et-ekub.com/socket.io';
      case AppEnvironment.production:
        return 'wss://api.et-ekub.com/socket.io';
    }
  }

  // Legacy service URLs - DEPRECATED
  // All services now route through API Gateway at apiBaseUrl
  // These are kept for backward compatibility but should not be used
  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get userServiceUrl => apiBaseUrl;

  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get groupServiceUrl => apiBaseUrl;

  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get walletServiceUrl => apiBaseUrl;

  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get paymentServiceUrl => apiBaseUrl;

  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get rotationServiceUrl => apiBaseUrl;

  @Deprecated('Use apiBaseUrl - all services route through API Gateway')
  static String get notificationServiceUrl => apiBaseUrl;

  @Deprecated('Use chatServiceUrl for WebSocket connections')
  static String get ussdServiceUrl => apiBaseUrl;

  // ========== Network Configuration ==========
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== Storage Keys ==========
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String languageKey = 'language';

  // ========== App Configuration ==========
  static const String appName = 'ET Digital Ekub';
  static const String appVersion = '1.0.0';

  // ========== OTP Configuration ==========
  static const int otpLength = 6;
  static const Duration otpExpirationTime = Duration(minutes: 10);
  static const int maxOtpAttempts = 5;
  static const Duration otpResendCooldown = Duration(seconds: 60);

  // ========== Token Configuration ==========
  // Access token expires in 15 minutes (backend default)
  static const Duration accessTokenExpiration = Duration(minutes: 15);
  // Refresh token expires in 7 days (backend default)
  static const Duration refreshTokenExpiration = Duration(days: 7);

  // ========== Helper Methods ==========
  static bool get isDevelopment =>
      _currentEnvironment == AppEnvironment.development;
  static bool get isStaging => _currentEnvironment == AppEnvironment.staging;
  static bool get isProduction =>
      _currentEnvironment == AppEnvironment.production;
}
