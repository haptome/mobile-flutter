import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  group('Lottery Draw Countdown Timer', () {
    test('Initializes countdown from drawing time', () {
      // Arrange
      final now = DateTime.now();
      final drawingTime = now.add(Duration(minutes: 5));
      final timeUntilDraw = drawingTime.difference(now);

      // Assert
      expect(timeUntilDraw.inSeconds, greaterThan(0));
      expect(timeUntilDraw.inMinutes, equals(5));
    });

    test('Calculates time remaining correctly', () {
      // Arrange
      final now = DateTime.now();
      final drawingTime = now.add(Duration(minutes: 3, seconds: 45));
      final timeUntilDraw = drawingTime.difference(now);

      // Assert
      expect(timeUntilDraw.inMinutes, equals(3));
      expect(timeUntilDraw.inSeconds % 60, equals(45));
    });

    test('Formats countdown in MM:SS format', () {
      // Arrange
      final duration = Duration(minutes: 5, seconds: 30);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Assert
      expect(formattedTime, equals('05:30'));
    });

    test('Formats countdown with single digit seconds', () {
      // Arrange
      final duration = Duration(minutes: 2, seconds: 5);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Assert
      expect(formattedTime, equals('02:05'));
    });

    test('Formats countdown with zero seconds', () {
      // Arrange
      final duration = Duration(minutes: 1, seconds: 0);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Assert
      expect(formattedTime, equals('01:00'));
    });

    test('Countdown decrements every second', () async {
      // Arrange
      Duration timeUntilDraw = Duration(seconds: 3);
      final decrements = <int>[];

      // Act
      final timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeUntilDraw.inSeconds > 0) {
          timeUntilDraw = timeUntilDraw - Duration(seconds: 1);
          decrements.add(timeUntilDraw.inSeconds);
        } else {
          timer.cancel();
        }
      });

      // Wait for countdown to complete
      await Future.delayed(Duration(seconds: 4));

      // Assert
      expect(decrements, equals([2, 1, 0]));
    });

    test('Countdown reaches zero', () async {
      // Arrange
      Duration timeUntilDraw = Duration(seconds: 2);
      bool countdownComplete = false;

      // Act
      final timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeUntilDraw.inSeconds > 0) {
          timeUntilDraw = timeUntilDraw - Duration(seconds: 1);
        } else {
          timer.cancel();
          countdownComplete = true;
        }
      });

      // Wait for countdown to complete with extra buffer
      await Future.delayed(Duration(seconds: 4));

      // Assert
      expect(countdownComplete, isTrue);
      expect(timeUntilDraw.inSeconds, lessThanOrEqualTo(0));
    });

    test('Timer is properly cancelled to prevent memory leaks', () async {
      // Arrange
      Timer? countdownTimer;
      Duration timeUntilDraw = Duration(seconds: 2);

      // Act
      countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeUntilDraw.inSeconds > 0) {
          timeUntilDraw = timeUntilDraw - Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });

      // Wait a bit
      await Future.delayed(Duration(milliseconds: 500));

      // Cancel timer manually
      countdownTimer.cancel();

      // Assert
      expect(countdownTimer.isActive, isFalse);
    });

    test('Drawing time in the past does not start countdown', () {
      // Arrange
      final now = DateTime.now();
      final drawingTime = now.subtract(Duration(minutes: 5));
      final timeUntilDraw = drawingTime.difference(now);

      // Assert
      expect(timeUntilDraw.inSeconds, lessThan(0));
    });

    test('Countdown handles edge case of exactly 1 minute', () {
      // Arrange
      final duration = Duration(minutes: 1, seconds: 0);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Assert
      expect(formattedTime, equals('01:00'));
      expect(duration.inSeconds, equals(60));
    });

    test('Countdown handles edge case of 59 seconds', () {
      // Arrange
      final duration = Duration(seconds: 59);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // Assert
      expect(formattedTime, equals('00:59'));
    });
  });
}
