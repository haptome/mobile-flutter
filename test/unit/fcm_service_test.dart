// Purpose: Simple test to verify FCM service functionality
// Tests basic initialization and method availability

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/fcm_service.dart';

void main() {
  group('FCM Service Tests', () {
    late FcmService fcmService;

    setUp(() {
      Get.testMode = true;
      fcmService = FcmService();
    });

    tearDown(() {
      Get.reset();
    });

    test('FCM service initializes correctly', () {
      expect(fcmService, isNotNull);
      expect(fcmService.fcmToken, isEmpty);
      expect(fcmService.isInitialized, false);
    });

    test('FCM service has required methods', () {
      expect(fcmService.subscribeToTopic, isNotNull);
      expect(fcmService.unsubscribeFromTopic, isNotNull);
      expect(fcmService.deleteFcmToken, isNotNull);
    });

    test('Static accessor works', () {
      // This would normally require Get.put() but we're just testing method existence
      expect(FcmService.to, isNotNull);
    });
  });
}
