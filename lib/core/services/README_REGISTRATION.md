# Registration API Usage Guide

## Overview
This guide shows how to use the registration API with GetX in the ET Digital Ekub app.

## API Endpoint
- **URL**: `http://188.245.198.252:3800/api/v1/auth/register`
- **Method**: `POST`
- **Content-Type**: `application/json`

## Request Model

```dart
RegisterRequest(
  phone: "+251900000000",
  fullName: "John Doe",
  password: "SecurePass123!",
  workStatus: "employed",
  fcmToken: "fcm-token-xyz",  // Optional
  deviceId: "device-uuid-or-install-id",  // Optional
  deviceType: "android",  // Optional (auto-detected)
)
```

## Usage Examples

### Example 1: Using AuthService directly

```dart
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/models/register_request.dart';
import 'package:et_digital_equb/core/utils/device_info.dart';

// In your widget or service
final authService = AuthService.to;

final request = RegisterRequest(
  phone: "+251900000000",
  fullName: "John Doe",
  password: "SecurePass123!",
  workStatus: "employed",
  fcmToken: "your-fcm-token",
  deviceId: DeviceInfo.getDeviceId(),
  deviceType: DeviceInfo.getDeviceType(),
);

try {
  final response = await authService.register(request);
  
  if (response.success) {
    print('Registration successful!');
    // Handle success (e.g., navigate to OTP screen)
  } else {
    print('Error: ${response.error?.message}');
  }
} catch (e) {
  print('Exception: $e');
}
```

### Example 2: Using AuthController (GetX)

```dart
import 'package:et_digital_equb/controllers/auth_controller.dart';
import 'package:get/get.dart';

// In your widget
final authController = Get.find<AuthController>();

// Set form values
authController.phone.value = "900000000";
authController.fullName.value = "John Doe";
authController.password.value = "SecurePass123!";
authController.workStatus.value = "employed";

// Register
await authController.register(
  fcmToken: "your-fcm-token",
  deviceId: "device-id",
);
```

### Example 3: Complete signup screen integration

```dart
class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  
  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      await authController.register(
        fcmToken: await getFcmToken(), // Your FCM token getter
      );
      
      if (authController.isOtpSent.value) {
        Get.toNamed('/otp');
      }
    }
  }
}
```

## Response Format

The API returns an `ApiResponse<Map<String, dynamic>>`:

```dart
{
  "success": true,
  "data": {
    "access_token": "...",  // If registration includes login
    "refresh_token": "...",  // If registration includes login
    "user": { ... }  // User object if returned
  },
  "message": "Registration successful"
}
```

Or on error:

```dart
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Phone number already exists"
  }
}
```

## Work Status Values

Common values for `workStatus`:
- `"employed"`
- `"self-employed"`
- `"student"`
- `"unemployed"`

## Device Type Values

Auto-detected by `DeviceInfo.getDeviceType()`:
- `"android"`
- `"ios"`
- `"web"`
- `"windows"`
- `"macos"`
- `"linux"`

## Notes

1. The phone number should include country code (e.g., "+251900000000")
2. Device ID and FCM token are optional but recommended for push notifications
3. The service automatically handles token storage if registration includes authentication
4. Error handling is built into the service layer

