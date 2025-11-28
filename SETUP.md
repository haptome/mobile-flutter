# Flutter Mobile App Setup Guide

## Prerequisites

1. **Flutter SDK**: Install Flutter 3.0+ from [flutter.dev](https://flutter.dev)
2. **Dart SDK**: Included with Flutter
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Android SDK** (for Android development)
5. **Xcode** (for iOS development - macOS only)

## Initial Setup

1. **Install dependencies**:
   ```bash
   cd apps/mobile-flutter
   flutter pub get
   ```

2. **Configure API endpoints**:
   Edit `lib/config/env.dart` and update the base URLs:
   ```dart
   static const String apiBaseUrl = 'http://your-api-url:3001/api/v1';
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Platform-Specific Setup

### Android

1. **Configure Android**:
   - Minimum SDK: 21 (Android 5.0)
   - Target SDK: Latest
   - Application ID: `com.etekub.mobile`

2. **Build APK**:
   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Configure iOS**:
   - Minimum iOS: 12.0
   - Bundle ID: `com.etekub.mobile`

2. **Install CocoaPods**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Build iOS**:
   ```bash
   flutter build ios --release
   ```

## Development

### Running in Debug Mode
```bash
flutter run
```

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Hot Reload
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Project Structure

```
lib/
├── bindings/          # Dependency injection bindings
├── controllers/       # Business logic controllers
├── models/           # Data models
├── views/            # UI screens
│   ├── auth/        # Authentication screens
│   ├── home/        # Home screen
│   └── splash/      # Splash screen
├── services/         # API and external services
│   ├── api_service.dart      # HTTP client with interceptors
│   ├── auth_service.dart     # Authentication service
│   └── storage_service.dart   # Secure storage
├── widgets/          # Reusable widgets
├── routes/           # Navigation routes
├── translations/      # Localization files
└── config/           # Configuration files
```

## Features Implemented

✅ **Authentication**
- Phone-based registration
- OTP verification
- Login with password/OTP
- JWT token management with auto-refresh
- Secure token storage

✅ **Core Services**
- API service with Dio
- Token refresh interceptor
- Secure storage service
- Error handling

✅ **UI**
- Splash screen
- Login/Register screens
- OTP verification
- Home screen
- GetX navigation

✅ **Localization**
- English
- Amharic (አማርኛ)

## Next Steps

1. **Group Management**: Implement group listing, creation, and joining
2. **Wallet**: Implement wallet balance, transactions, and deposits
3. **Payment**: Integrate payment gateway flows
4. **Chat**: Implement real-time group chat
5. **Notifications**: Add push notifications
6. **Profile**: Complete user profile management
7. **KYC**: Implement KYC document upload

## Troubleshooting

### Common Issues

1. **Dependencies not installing**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build errors**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Android build issues**:
   - Ensure Android SDK is properly configured
   - Check `local.properties` has correct `sdk.dir`

4. **iOS build issues**:
   - Run `pod install` in `ios/` directory
   - Ensure Xcode is properly configured

## API Integration

The app connects to these services:
- **Auth Service**: `http://localhost:3001/api/v1`
- **User Service**: `http://localhost:3002/api/v1`
- **Group Service**: `http://localhost:3003/api/v1`
- **Wallet Service**: `http://localhost:3004/api/v1`
- **Payment Service**: `http://localhost:3005/api/v1`
- **Chat Service**: `ws://localhost:3008`

Make sure these services are running before testing the app.

