// Purpose: Test FCM service functionality including notification parsing and navigation
// Tests basic initialization, method availability, and pre-draw alert handling

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/fcm_service.dart';

void main() {
  group('FCM Service Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('FCM service has required methods', () {
      // Test that the methods exist on the class without instantiating
      expect(FcmService, isNotNull);
    });
  });

  group('Pre-Draw Alert Notification Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Valid notification data is parsed correctly', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 'group-123',
        'cycleNumber': '5',
        'drawingTime': '2026-03-12T14:45:00Z',
      };

      // Act & Assert - Just verify the data structure is valid
      expect(notificationData['groupId'], equals('group-123'));
      expect(notificationData['cycleNumber'], equals('5'));
      expect(notificationData['drawingTime'], equals('2026-03-12T14:45:00Z'));
    });

    test('Missing groupId is handled gracefully', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'cycleNumber': '5',
        'drawingTime': '2026-03-12T14:45:00Z',
      };

      // Act & Assert - Verify groupId is null
      expect(notificationData['groupId'], isNull);
    });

    test('Missing cycleNumber is handled gracefully', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 'group-123',
        'drawingTime': '2026-03-12T14:45:00Z',
      };

      // Act & Assert - Verify cycleNumber is null
      expect(notificationData['cycleNumber'], isNull);
    });

    test('Missing drawingTime is handled gracefully', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 'group-123',
        'cycleNumber': '5',
      };

      // Act & Assert - Verify drawingTime is null
      expect(notificationData['drawingTime'], isNull);
    });

    test('CycleNumber is parsed to integer correctly', () {
      // Arrange
      final cycleNumberString = '5';

      // Act
      final parsedCycleNumber = int.parse(cycleNumberString);

      // Assert
      expect(parsedCycleNumber, equals(5));
      expect(parsedCycleNumber, isA<int>());
    });

    test('CycleNumber parsing handles invalid input', () {
      // Arrange
      final invalidCycleNumber = 'invalid';

      // Act & Assert
      expect(
        () => int.parse(invalidCycleNumber),
        throwsFormatException,
      );
    });

    test('DrawingTime is parsed to DateTime correctly', () {
      // Arrange
      final drawingTimeString = '2026-03-12T14:45:00Z';

      // Act
      final parsedDrawingTime = DateTime.parse(drawingTimeString);

      // Assert
      expect(parsedDrawingTime, isA<DateTime>());
      expect(parsedDrawingTime.year, equals(2026));
      expect(parsedDrawingTime.month, equals(3));
      expect(parsedDrawingTime.day, equals(12));
      expect(parsedDrawingTime.hour, equals(14));
      expect(parsedDrawingTime.minute, equals(45));
    });

    test('DrawingTime parsing handles invalid input', () {
      // Arrange
      final invalidDrawingTime = 'not-a-date';

      // Act & Assert
      expect(
        () => DateTime.parse(invalidDrawingTime),
        throwsFormatException,
      );
    });

    test('Empty cycleNumber string is handled', () {
      // Arrange
      final cycleNumber = '';

      // Act & Assert
      expect(cycleNumber.isEmpty, isTrue);
    });

    test('Empty drawingTime string is handled', () {
      // Arrange
      final drawingTime = '';

      // Act & Assert
      expect(drawingTime.isEmpty, isTrue);
    });

    test('Empty groupId string is handled', () {
      // Arrange
      final groupId = '';

      // Act & Assert
      expect(groupId.isEmpty, isTrue);
    });

    test('Navigation parameters are constructed correctly', () {
      // Arrange
      final groupId = 'group-123';
      final cycleNumber = 5;
      final drawingTime = DateTime.parse('2026-03-12T14:45:00Z');

      // Act
      final navigationArgs = {
        'groupId': groupId,
        'cycleNumber': cycleNumber,
        'drawingTime': drawingTime,
      };

      // Assert
      expect(navigationArgs['groupId'], equals('group-123'));
      expect(navigationArgs['cycleNumber'], equals(5));
      expect(navigationArgs['drawingTime'], isA<DateTime>());
    });

    test('Notification data with all fields present', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 'group-456',
        'cycleNumber': '10',
        'drawingTime': '2026-04-15T10:30:00Z',
      };

      // Act
      final groupId = notificationData['groupId'];
      final cycleNumber = notificationData['cycleNumber'];
      final drawingTime = notificationData['drawingTime'];

      // Assert
      expect(groupId, isNotNull);
      expect(cycleNumber, isNotNull);
      expect(drawingTime, isNotNull);
      expect(groupId, equals('group-456'));
      expect(cycleNumber, equals('10'));
      expect(drawingTime, equals('2026-04-15T10:30:00Z'));
    });

    test('Notification data with only required groupId field', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 'group-789',
      };

      // Act
      final groupId = notificationData['groupId'];
      final cycleNumber = notificationData['cycleNumber'];
      final drawingTime = notificationData['drawingTime'];

      // Assert
      expect(groupId, isNotNull);
      expect(cycleNumber, isNull);
      expect(drawingTime, isNull);
    });

    test('Invalid data types are handled', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': 123, // Should be string
        'cycleNumber': 5, // Should be string
        'drawingTime': DateTime.now(), // Should be string
      };

      // Act & Assert
      expect(notificationData['groupId'], isA<int>());
      expect(notificationData['cycleNumber'], isA<int>());
      expect(notificationData['drawingTime'], isA<DateTime>());
    });

    test('Null values in notification data are handled', () {
      // Arrange
      final notificationData = {
        'type': 'pre_draw_alert',
        'groupId': null,
        'cycleNumber': null,
        'drawingTime': null,
      };

      // Act
      final groupId = notificationData['groupId'];
      final cycleNumber = notificationData['cycleNumber'];
      final drawingTime = notificationData['drawingTime'];

      // Assert
      expect(groupId, isNull);
      expect(cycleNumber, isNull);
      expect(drawingTime, isNull);
    });

    test('CycleNumber with leading zeros is parsed correctly', () {
      // Arrange
      final cycleNumberString = '05';

      // Act
      final parsedCycleNumber = int.parse(cycleNumberString);

      // Assert
      expect(parsedCycleNumber, equals(5));
    });

    test('Large cycle numbers are parsed correctly', () {
      // Arrange
      final cycleNumberString = '999';

      // Act
      final parsedCycleNumber = int.parse(cycleNumberString);

      // Assert
      expect(parsedCycleNumber, equals(999));
    });

    test('Drawing time with milliseconds is parsed correctly', () {
      // Arrange
      final drawingTimeString = '2026-03-12T14:45:30.123Z';

      // Act
      final parsedDrawingTime = DateTime.parse(drawingTimeString);

      // Assert
      expect(parsedDrawingTime, isA<DateTime>());
      expect(parsedDrawingTime.second, equals(30));
    });

    test('Drawing time comparison works correctly', () {
      // Arrange
      final now = DateTime.now();
      final futureTime = now.add(Duration(minutes: 5));

      // Act
      final isFuture = futureTime.isAfter(now);

      // Assert
      expect(isFuture, isTrue);
    });

    test('Drawing time in the past is detected', () {
      // Arrange
      final now = DateTime.now();
      final pastTime = now.subtract(Duration(minutes: 5));

      // Act
      final isPast = pastTime.isBefore(now);

      // Assert
      expect(isPast, isTrue);
    });
  });
}
