# ET Digital Ekub Mobile App

Flutter mobile application for ET Digital Ekub platform using GetX architecture.

## Architecture

- **State Management**: GetX
- **Routing**: GetX Navigation
- **Dependency Injection**: GetX
- **Networking**: Dio with interceptors
- **Storage**: flutter_secure_storage (tokens), shared_preferences (settings)
- **Localization**: intl (Amharic/English)

## Project Structure

```
lib/
├── bindings/          # Dependency injection bindings
├── controllers/       # Business logic controllers
├── models/           # Data models
├── views/            # UI screens
├── services/         # API and external services
├── widgets/          # Reusable widgets
└── translations/     # Localization files
```

## Setup

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Build for production**:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## Environment Configuration

Create `lib/config/env.dart` with your API base URL:

```dart
class Env {
  static const String apiBaseUrl = 'http://localhost:3001/api/v1';
  static const String wsBaseUrl = 'ws://localhost:3008';
}
```

## Features

- ✅ Phone-based authentication with OTP
- ✅ JWT token management with auto-refresh
- ✅ Multi-language support (Amharic/English)
- ✅ Group management
- ✅ Wallet and payment integration
- ✅ Real-time chat
- ✅ Notifications

## API Integration

The app connects to:
- Auth Service: `http://localhost:3001/api/v1`
- User Service: `http://localhost:3002/api/v1`
- Group Service: `http://localhost:3003/api/v1`
- Wallet Service: `http://localhost:3004/api/v1`
- Payment Service: `http://localhost:3005/api/v1`
- Chat Service: `ws://localhost:3008`

