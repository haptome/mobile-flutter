// Purpose: Firebase Cloud Messaging service for push notifications
// Author: Generated for ET Digital Equb
// Handles FCM token management and notification processing

import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/storage_service.dart';
import 'package:et_digital_equb/core/services/api_service.dart';

class FcmService extends GetxService {
  static FcmService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
      // Request permission for iOS
      await _requestPermissions();

      // Re-enable FCM auto-init at runtime (required for Android)
      await _firebaseMessaging.setAutoInitEnabled(true);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFcmToken();

      // Setup foreground message handlers
      _setupForegroundHandlers();

      _isInitialized.value = true;
      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
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
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'equb_channel',
      'Equb Notifications',
      description: 'Notifications for ET Digital Equb',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Get FCM registration token
  Future<void> _getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken.value = token;

        debugPrint('====================================================');
        debugPrint('FCM Token: $token');
        debugPrint('====================================================');

        // Save token to storage
        final storage = StorageService.to;
        await storage.saveFcmToken(token);

        // Send token to backend
        await _sendTokenToServer(token);
      }
    } catch (e) {
        debugPrint('====================================================');
        debugPrint('Error getting FCM token: $e');
        debugPrint('====================================================');
      
    }
  }

  /// Send FCM token to backend server
  Future<void> _sendTokenToServer(String token) async {
    try {
      final apiService = ApiService.to;
      
      // Use the correct endpoint that matches the backend
      await apiService.userDio.put(
        '/users/me/fcm-token',
        data: {'fcm_token': token, 'device_type': _getDeviceType()},
      );
      debugPrint('FCM token sent to server successfully');
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
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
    // Handle app terminated state — user tapped notification that launched the app
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App launched from terminated state via notification: ${message.notification?.title}');
        // Delay navigation until the app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle tap on notification when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'User tapped notification: ${message.notification?.title}',
      );
      _handleNotificationTap(message);
    });
  }

  /// Handle foreground messages by showing local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      // Show notification for both Android and iOS
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'equb_channel',
            'Equb Notifications',
            channelDescription: 'Notifications for ET Digital Equb',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }

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
  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      try {
        // Parse payload and handle navigation
        debugPrint('Notification tapped with payload: ${response.payload}');
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateBasedOnNotification(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Process notification data payload
  void _processNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    debugPrint('Processing notification data: $data');

    // Extract notification type and handle accordingly
    final type = data['type'] as String?;
    final metadata = data['metadata'] as Map<String, dynamic>? ?? {};

    if (type == null) {
      debugPrint('No notification type specified');
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
      case 'winner_announcement':
        _handleWinnerAnnouncement(metadata);
        break;
      case 'personalized_winner_notification':
        _handlePersonalizedWinnerNotification(metadata);
        break;
      case 'system_announcement':
        _handleSystemAnnouncement(metadata);
        break;
      case 'pre_draw_alert':
        _handlePreDrawAlert(metadata);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Handle payment success notification
  void _handlePaymentSuccess(Map<String, dynamic> metadata) {
    debugPrint('Payment success notification received: $metadata');
    // Show success message or update UI
    Get.snackbar(
      'Payment Successful',
      'Your payment has been processed successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle group invitation notification
  void _handleGroupInvitation(Map<String, dynamic> metadata) {
    debugPrint('Group invitation received: $metadata');
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
    debugPrint('Turn notification received: $metadata');
    Get.snackbar(
      'Your Turn!',
      'It\'s your turn to contribute to your Ekub group',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle winner announcement (public - uses lottery number)
  void _handleWinnerAnnouncement(Map<String, dynamic> metadata) {
    debugPrint('Winner announcement received: $metadata');
    final groupName = metadata['group_name'] as String? ?? 'Ekub Group';
    final lotteryNumber = metadata['lottery_number'] as String?;
    final cycleNumber = metadata['cycle_number'] as int?;
    
    String message;
    if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
      message = 'The winner for $groupName';
      if (cycleNumber != null) {
        message += ' cycle $cycleNumber';
      }
      message += ' is #$lotteryNumber';
    } else {
      // Fallback if lottery number is not available
      final winnerName = metadata['winner_name'] as String? ?? 'Unknown';
      message = 'The winner for $groupName';
      if (cycleNumber != null) {
        message += ' cycle $cycleNumber';
      }
      message += ' is $winnerName';
    }

    Get.snackbar(
      'Winner Announced! 🎉',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          final groupId = metadata['group_id'] as String?;
          if (groupId != null) {
            Get.toNamed('/group-detail', arguments: {'groupId': groupId});
          }
        },
        child: const Text('View Group', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// Handle personalized winner notification (private - uses real name)
  void _handlePersonalizedWinnerNotification(Map<String, dynamic> metadata) {
    debugPrint('Personalized winner notification received: $metadata');
    final groupName = metadata['group_name'] as String? ?? 'Ekub Group';
    final amount = metadata['amount'] as num? ?? 0;
    final cycleNumber = metadata['cycle_number'] as int?;
    
    String message = 'Congratulations! You won';
    if (cycleNumber != null) {
      message += ' cycle $cycleNumber of';
    }
    message += ' $groupName';
    if (amount > 0) {
      message += ' and will receive ${amount.toStringAsFixed(0)} ETB';
    }

    Get.snackbar(
      'Congratulations! 🎉🎊',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      mainButton: TextButton(
        onPressed: () {
          final groupId = metadata['group_id'] as String?;
          if (groupId != null) {
            Get.toNamed('/group-detail', arguments: {'groupId': groupId});
          }
        },
        child: const Text('View Details', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// Handle system announcement
  void _handleSystemAnnouncement(Map<String, dynamic> metadata) {
    debugPrint('System announcement received: $metadata');
    final title = metadata['title'] as String? ?? 'Announcement';
    final message = metadata['message'] as String? ?? 'New announcement';

    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  /// Handle pre-draw alert notification
  void _handlePreDrawAlert(Map<String, dynamic> data) {
    debugPrint('Pre-draw alert received: $data');
    
    // Extract groupId, cycleNumber, and drawingTime from notification data
    final groupId = data['groupId'] as String?;
    final cycleNumber = data['cycleNumber'] as String?;
    final drawingTime = data['drawingTime'] as String?;

    // Validate extracted data
    if (groupId == null || groupId.isEmpty) {
      debugPrint('Error: Missing or invalid groupId in pre-draw alert');
      return;
    }

    // Parse cycleNumber if available
    int? parsedCycleNumber;
    if (cycleNumber != null && cycleNumber.isNotEmpty) {
      try {
        parsedCycleNumber = int.parse(cycleNumber);
      } catch (e) {
        debugPrint('Error parsing cycleNumber: $e');
      }
    }

    // Parse drawingTime if available
    DateTime? parsedDrawingTime;
    if (drawingTime != null && drawingTime.isNotEmpty) {
      try {
        parsedDrawingTime = DateTime.parse(drawingTime);
      } catch (e) {
        debugPrint('Error parsing drawingTime: $e');
      }
    }

    // Navigate to /lottery-draw with correct arguments
    Get.toNamed(
      '/lottery-draw',
      arguments: {
        'groupId': groupId,
        'cycleNumber': parsedCycleNumber,
        'drawingTime': parsedDrawingTime,
      },
    );
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
      case 'winner_announcement':
      case 'personalized_winner_notification':
        final groupId = data['metadata']?['group_id'] as String?;
        if (groupId != null) {
          Get.toNamed('/group-detail', arguments: {'groupId': groupId});
        }
        break;
      case 'pre_draw_alert':
        final groupId = data['groupId'] as String?;
        final cycleNumber = data['cycleNumber'] as String?;
        final drawingTime = data['drawingTime'] as String?;
        if (groupId != null) {
          int? parsedCycleNumber;
          if (cycleNumber != null && cycleNumber.isNotEmpty) {
            try {
              parsedCycleNumber = int.parse(cycleNumber);
            } catch (e) {
              debugPrint('Error parsing cycleNumber: $e');
            }
          }
          DateTime? parsedDrawingTime;
          if (drawingTime != null && drawingTime.isNotEmpty) {
            try {
              parsedDrawingTime = DateTime.parse(drawingTime);
            } catch (e) {
              debugPrint('Error parsing drawingTime: $e');
            }
          }
          Get.toNamed(
            '/lottery-draw',
            arguments: {
              'groupId': groupId,
              'cycleNumber': parsedCycleNumber,
              'drawingTime': parsedDrawingTime,
            },
          );
        }
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
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token (for logout)
  Future<void> deleteFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken.value = '';
      final storage = StorageService.to;
      await storage.clearFcmToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}

/// Background message handler - must be a top-level function
/// This is registered in main.dart before runApp()
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.notification?.title}');

  // Process the message data
  if (message.data.isNotEmpty) {
    debugPrint('Background message data: ${message.data}');
  }
}
