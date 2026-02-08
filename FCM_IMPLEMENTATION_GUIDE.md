# Firebase Cloud Messaging (FCM) Implementation Guide

## Overview
This document describes the complete FCM implementation for the ET Digital Equb mobile application, enabling push notifications for user engagement and real-time updates.

## Architecture

### Components Implemented

1. **FcmService** - Core FCM functionality
   - Token management
   - Notification handling (foreground/background)
   - Local notification display
   - Topic subscription management

2. **Storage Integration** - Persistent token storage
   - Secure FCM token storage
   - Token synchronization with backend

3. **Backend Integration** - Server-side notification delivery
   - Device token registration endpoint
   - Notification sending via Firebase Admin SDK

## Implementation Details

### 1. Dependencies Added

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.10.1
  firebase_messaging: ^15.1.6
  flutter_local_notifications: ^18.0.1
```

### 2. FCM Service Features

#### Token Management
- Automatic FCM token generation on app start
- Secure storage of tokens using SharedPreferences
- Token synchronization with backend API
- Token cleanup on user logout

#### Notification Handling
- **Foreground**: Local notifications displayed via flutter_local_notifications
- **Background**: Background message handler for silent notifications
- **Terminated**: Notification tap opens app and navigates appropriately

#### Notification Types Supported
1. **Payment Success** - Confirms successful transactions
2. **Group Invitation** - Notifies users of group invitations
3. **Turn Notification** - Alerts when it's user's turn to contribute
4. **System Announcement** - General system notifications

### 3. Android Configuration

#### Required Files:
1. `android/app/google-services.json` - Firebase project configuration
2. Updated `android/app/build.gradle.kts` with Google Services plugin

#### Permissions Added:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 4. iOS Configuration

#### Required Files:
1. `ios/Runner/GoogleService-Info.plist` - iOS Firebase configuration
2. Notification capabilities enabled in Xcode project

#### Permissions:
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## API Integration

### Backend Endpoints

1. **Register Device Token**
   ```
   POST /users/{userId}/device-tokens
   {
     "device_token": "FCM_TOKEN",
     "device_type": "ANDROID|IOS"
   }
   ```

2. **Send Notification** (Backend)
   ```
   POST /notifications/send
   {
     "user_id": "user123",
     "type": "payment_success",
     "title": "Payment Successful",
     "body": "Your payment has been processed",
     "metadata": { ... }
   }
   ```

## Usage Examples

### Sending Notifications from Backend

```typescript
// Example notification payload
const notificationPayload = {
  user_id: 'user123',
  type: 'payment_success',
  title: 'Payment Successful',
  body: 'Your payment of 500 ETB has been processed successfully',
  metadata: {
    amount: 500,
    currency: 'ETB',
    transaction_id: 'txn_456'
  }
};

// Send via notification service
await notificationService.sendPushNotification(
  notificationPayload.user_id,
  notificationPayload.type,
  notificationPayload.title,
  notificationPayload.body,
  notificationPayload.metadata
);
```

### Client-Side Notification Handling

```dart
// Subscribe to topics
await FcmService.to.subscribeToTopic('announcements');

// Handle specific notification types
FcmService.to.handleNotificationTap(notificationData);

// Delete token on logout
await FcmService.to.deleteFcmToken();
```

## Testing

### Manual Testing Steps

1. **Token Registration**
   - Launch app and verify FCM token is generated
   - Check that token is stored securely
   - Verify token is sent to backend

2. **Foreground Notifications**
   - Send test notification while app is open
   - Verify local notification appears
   - Check notification data processing

3. **Background Notifications**
   - Close app completely
   - Send notification
   - Open app via notification tap
   - Verify navigation occurs

4. **Topic Subscriptions**
   - Subscribe to test topic
   - Send broadcast to topic
   - Verify all subscribers receive notification

## Security Considerations

1. **Token Security**
   - FCM tokens stored securely using SharedPreferences
   - Tokens cleared on logout
   - Device type validation on backend

2. **Notification Validation**
   - Backend validates notification payloads
   - Rate limiting on notification sending
   - User authorization checks

3. **Data Privacy**
   - Sensitive data not included in notification payloads
   - Metadata encrypted where necessary
   - GDPR compliance for EU users

## Troubleshooting

### Common Issues

1. **Token Not Generated**
   - Check Firebase configuration files
   - Verify Google Services plugin installation
   - Ensure internet connectivity

2. **Notifications Not Received**
   - Verify device token registration
   - Check Firebase project settings
   - Confirm notification permissions granted

3. **Background Handler Not Working**
   - Ensure `@pragma('vm:entry-point')` annotation
   - Check background execution permissions
   - Verify Firebase initialization

## Future Enhancements

1. **Rich Notifications**
   - Image support in notifications
   - Action buttons in notifications
   - Custom notification layouts

2. **Advanced Features**
   - Notification scheduling
   - Geofencing notifications
   - Personalized notification content

3. **Analytics**
   - Notification open rates
   - User engagement metrics
   - A/B testing framework

## Deployment Checklist

- [ ] Firebase project created and configured
- [ ] `google-services.json` added to Android project
- [ ] `GoogleService-Info.plist` added to iOS project
- [ ] Google Services plugin configured in build files
- [ ] Notification icons prepared for both platforms
- [ ] Backend notification endpoints implemented
- [ ] Testing completed on both platforms
- [ ] Production certificates configured
- [ ] Monitoring and logging implemented

This FCM implementation provides a robust foundation for real-time user engagement in the ET Digital Equb application.