// Purpose: Firebase Cloud Messaging service for push notifications
// Author: Generated for ET Digital Equb
// Handles FCM token management and notification processing

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/storage_service.dart';
import 'package:et_digital_equb/core/services/api_service.dart';

class FcmService extends GetxService {
  static FcmService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _localNotifications =
  //     FlutterLocalNotificationsPlugin();

  final RxString _fcmToken = ''.obs;
  final RxBool _isInitialized = false.obs;

  String get fcmToken => _fcmToken.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initializeFcm();
  }

  /// Initialize Firebase and FCM
  Future<void> _initializeFcm() async {
    try {
      // Firebase is already initialized in main.dart, no need to initialize again

      // Request permission for iOS
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFcmToken();

      // Setup foreground message handlers
      _setupForegroundHandlers();

      _isInitialized.value = true;
      print('FCM Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM: $e');
      _isInitialized.value = false;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');

    // const DarwinInitializationSettings initializationSettingsIOS =
    //     DarwinInitializationSettings(
    //       requestAlertPermission: true,
    //       requestBadgePermission: true,
    //       requestSoundPermission: true,
    //     );

    // const InitializationSettings initializationSettings =
    //     InitializationSettings(
    //       android: initializationSettingsAndroid,
    //       iOS: initializationSettingsIOS,
    //     );

    // await _localNotifications.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: _onSelectNotification,
    // );
  }

  /// Get FCM registration token
  Future<void> _getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken.value = token;
        print('FCM Token: $token');

        // Save token to storage
        final storage = StorageService.to;
        await storage.saveFcmToken(token);

        // Send token to backend
        await _sendTokenToServer(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Send FCM token to backend server
  Future<void> _sendTokenToServer(String token) async {
    try {
      final apiService = ApiService.to;
      final userId = await apiService.getCurrentUserId();

      if (userId != null) {
        await apiService.userDio.post(
          '/users/$userId/device-tokens',
          data: {'device_token': token, 'device_type': _getDeviceType()},
        );
        print('FCM token sent to server successfully');
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
      // Don't throw error, just log it - token will be sent on next app start
    }
  }

  /// Get device type for token registration
  String _getDeviceType() {
    if (GetPlatform.isAndroid) return 'ANDROID';
    if (GetPlatform.isIOS) return 'IOS';
    return 'UNKNOWN';
  }

  /// Setup foreground message handlers
  void _setupForegroundHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle tap on notification when app is in foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
        'User tapped notification in foreground: ${message.notification?.title}',
      );
      _handleNotificationTap(message);
    });
  }

  /// Handle foreground messages by showing local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // if (notification != null) {
    //   // Show notification for both Android and iOS
    //   await _localNotifications.show(
    //     notification.hashCode,
    //     notification.title,
    //     notification.body,
    //     NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'equb_channel',
    //         'Equb Notifications',
    //         channelDescription: 'Notifications for ET Digital Equb',
    //         importance: Importance.max,
    //         priority: Priority.high,
    //         icon: '@mipmap/ic_launcher',
    //       ),
    //       iOS: const DarwinNotificationDetails(
    //         badgeNumber: 1,
    //         presentAlert: true,
    //         presentBadge: true,
    //         presentSound: true,
    //       ),
    //     ),
    //     payload: message.data.toString(), id: null,
    //   );
    // }

    // Handle data payload
    if (message.data.isNotEmpty) {
      _processNotificationData(message.data);
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    // Process the notification data
    _processNotificationData(message.data);

    // Navigate based on notification type
    _navigateBasedOnNotification(message.data);
  }

  /// Handle notification tap from local notifications
  // void _onSelectNotification(NotificationResponse response) {
  //   if (response.payload != null) {
  //     try {
  //       // Parse payload and handle navigation
  //       print('Notification tapped with payload: ${response.payload}');
  //       // You can parse the payload and navigate accordingly
  //     } catch (e) {
  //       print('Error parsing notification payload: $e');
  //     }
  //   }
  // }

  /// Process notification data payload
  void _processNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    
    print('Processing notification data: $data');

    // Extract notification type and handle accordingly
    final type = data['type'] as String?;
    final metadata = data['metadata'] as Map<String, dynamic>? ?? {};

    if (type == null) {
      print('No notification type specified');
      return;
    }

    switch (type) {
      case 'payment_success':
        _handlePaymentSuccess(metadata);
        break;
      case 'group_invitation':
        _handleGroupInvitation(metadata);
        break;
      case 'turn_notification':
        _handleTurnNotification(metadata);
        break;
      case 'system_announcement':
        _handleSystemAnnouncement(metadata);
        break;
      default:
        print('Unknown notification type: $type');
    }
  }

  /// Handle payment success notification
  void _handlePaymentSuccess(Map<String, dynamic> metadata) {
    print('Payment success notification received: $metadata');
    // Show success message or update UI
    Get.snackbar(
      'Payment Successful',
      'Your payment has been processed successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle group invitation notification
  void _handleGroupInvitation(Map<String, dynamic> metadata) {
    print('Group invitation received: $metadata');
    final groupId = metadata['group_id'] as String?;
    if (groupId != null) {
      Get.snackbar(
        'Group Invitation',
        'You have been invited to join a group',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            Get.toNamed('/group-detail', arguments: {'groupId': groupId});
          },
          child: const Text('View'),
        ),
      );
    }
  }

  /// Handle turn notification
  void _handleTurnNotification(Map<String, dynamic> metadata) {
    print('Turn notification received: $metadata');
    Get.snackbar(
      'Your Turn!',
      'It\'s your turn to contribute to your Ekub group',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle system announcement
  void _handleSystemAnnouncement(Map<String, dynamic> metadata) {
    print('System announcement received: $metadata');
    final title = metadata['title'] as String? ?? 'Announcement';
    final message = metadata['message'] as String? ?? 'New announcement';

    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  /// Navigate based on notification type
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'group_invitation':
        final groupId = data['metadata']?['group_id'] as String?;
        if (groupId != null) {
          Get.toNamed('/group-detail', arguments: {'groupId': groupId});
        }
        break;
      case 'payment_success':
        Get.toNamed('/transactions');
        break;
      case 'turn_notification':
        Get.toNamed('/your-ekubs');
        break;
      default:
        // Default navigation or no navigation
        break;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token (for logout)
  Future<void> deleteFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken.value = '';
      final storage = StorageService.to;
      await storage.clearFcmToken();
      print('FCM token deleted');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

/// Background message handler - must be a top-level function
/// This is registered in main.dart before runApp()
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Don't initialize Firebase here - it's already initialized in main.dart
  print('Handling background message: ${message.notification?.title}');
  
  // Process the message data
  // Note: This runs in isolate, so GetX services may not be available
  // Store data locally or send to main isolate for processing
  if (message.data.isNotEmpty) {
    print('Background message data: ${message.data}');
  }
}
