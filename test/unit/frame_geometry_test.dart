// Purpose: Unit tests for FrameGeometry model
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/frame_geometry.dart';
import 'package:et_digital_equb/models/id_type.dart';

void main() {
  group('FrameGeometry', () {
    test('should create instance with all required properties', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry.frameRect, const Rect.fromLTWH(50, 100, 300, 200));
      expect(geometry.aspectRatio, 1.5);
      expect(geometry.cornerRadius, 16.0);
      expect(geometry.screenSize, const Size(400, 800));
    });

    test('should calculate frame area correctly', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(0, 0, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry.frameArea, 60000.0); // 300 * 200
    });

    test('should return correct center point', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry.center, const Offset(200, 200)); // (50+150, 100+100)
    });

    test('should provide correct dimension getters', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry.width, 300);
      expect(geometry.height, 200);
      expect(geometry.left, 50);
      expect(geometry.top, 100);
      expect(geometry.right, 350); // 50 + 300
      expect(geometry.bottom, 300); // 100 + 200
    });

    test('should check if point is inside frame', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry.containsPoint(const Offset(200, 200)), true);
      expect(geometry.containsPoint(const Offset(50, 100)), true);
      expect(geometry.containsPoint(const Offset(349, 299)), true);
      expect(geometry.containsPoint(const Offset(25, 50)), false);
      expect(geometry.containsPoint(const Offset(400, 400)), false);
    });

    test('should calculate overlap percentage correctly', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(0, 0, 100, 100),
        aspectRatio: 1.0,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      // Perfect overlap
      final perfectOverlap = geometry.calculateOverlap(
        const Rect.fromLTWH(0, 0, 100, 100),
      );
      expect(perfectOverlap, 1.0);

      // 50% overlap
      final halfOverlap = geometry.calculateOverlap(
        const Rect.fromLTWH(50, 0, 100, 100),
      );
      expect(halfOverlap, 0.5);

      // No overlap
      final noOverlap = geometry.calculateOverlap(
        const Rect.fromLTWH(200, 200, 100, 100),
      );
      expect(noOverlap, 0.0);
    });

    test('should create copy with updated values', () {
      final original = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      final copy = original.copyWith(
        aspectRatio: 2.0,
        cornerRadius: 20.0,
      );

      expect(copy.frameRect, original.frameRect);
      expect(copy.aspectRatio, 2.0);
      expect(copy.cornerRadius, 20.0);
      expect(copy.screenSize, original.screenSize);
    });

    test('should implement equality correctly', () {
      final geometry1 = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      final geometry2 = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      final geometry3 = FrameGeometry(
        frameRect: const Rect.fromLTWH(60, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      expect(geometry1, geometry2);
      expect(geometry1, isNot(geometry3));
      expect(geometry1.hashCode, geometry2.hashCode);
    });

    test('should have meaningful toString', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 100, 300, 200),
        aspectRatio: 1.5,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      final str = geometry.toString();
      expect(str, contains('FrameGeometry'));
      expect(str, contains('1.5'));
      expect(str, contains('16.0'));
    });
  });

  group('FrameGeometry.forIDCapture', () {
    const screenSize = Size(400, 800);

    test('should create frame for National ID with correct aspect ratio', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      expect(geometry.aspectRatio, 1.6);
      expect(geometry.cornerRadius, 16.0);
      expect(geometry.screenSize, screenSize);
    });

    test('should create frame for Driver License with correct aspect ratio', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.driverLicense,
      );

      expect(geometry.aspectRatio, 1.6);
      expect(geometry.cornerRadius, 16.0);
    });

    test('should create frame for Passport with correct aspect ratio', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.passport,
      );

      expect(geometry.aspectRatio, 0.75);
      expect(geometry.cornerRadius, 16.0);
    });

    test('should center frame horizontally on screen', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      final leftMargin = geometry.left;
      final rightMargin = screenSize.width - geometry.right;
      
      expect((leftMargin - rightMargin).abs(), lessThan(0.01));
    });

    test('should center frame vertically on screen', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      final topMargin = geometry.top;
      final bottomMargin = screenSize.height - geometry.bottom;
      
      expect((topMargin - bottomMargin).abs(), lessThan(0.01));
    });

    test('should respect maximum width constraint (85% of screen)', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      expect(geometry.width, lessThanOrEqualTo(screenSize.width * 0.85));
    });

    test('should respect maximum height constraint (60% of screen)', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      expect(geometry.height, lessThanOrEqualTo(screenSize.height * 0.6));
    });

    test('should maintain aspect ratio for wide rectangles', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      final calculatedRatio = geometry.width / geometry.height;
      expect((calculatedRatio - 1.6).abs(), lessThan(0.01));
    });

    test('should maintain aspect ratio for tall rectangles', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.passport,
      );

      final calculatedRatio = geometry.width / geometry.height;
      expect((calculatedRatio - 0.75).abs(), lessThan(0.01));
    });

    test('should handle small screen sizes', () {
      final smallScreen = const Size(320, 568); // iPhone SE size
      final geometry = FrameGeometry.forIDCapture(
        screenSize: smallScreen,
        idType: IDType.nationalId,
      );

      expect(geometry.width, lessThanOrEqualTo(smallScreen.width * 0.85));
      expect(geometry.height, lessThanOrEqualTo(smallScreen.height * 0.6));
      expect(geometry.left, greaterThanOrEqualTo(0));
      expect(geometry.top, greaterThanOrEqualTo(0));
    });

    test('should handle large screen sizes', () {
      final largeScreen = const Size(1080, 2400); // Large Android phone
      final geometry = FrameGeometry.forIDCapture(
        screenSize: largeScreen,
        idType: IDType.nationalId,
      );

      expect(geometry.width, lessThanOrEqualTo(largeScreen.width * 0.85));
      expect(geometry.height, lessThanOrEqualTo(largeScreen.height * 0.6));
      expect(geometry.left, greaterThanOrEqualTo(0));
      expect(geometry.top, greaterThanOrEqualTo(0));
    });

    test('National ID and Driver License should have same dimensions', () {
      final nationalIdGeometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      final driverLicenseGeometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.driverLicense,
      );

      expect(nationalIdGeometry.width, driverLicenseGeometry.width);
      expect(nationalIdGeometry.height, driverLicenseGeometry.height);
      expect(nationalIdGeometry.aspectRatio, driverLicenseGeometry.aspectRatio);
    });

    test('Passport should have different dimensions than cards', () {
      final passportGeometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.passport,
      );

      final nationalIdGeometry = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: IDType.nationalId,
      );

      // Passport has different aspect ratio
      expect(passportGeometry.aspectRatio, isNot(nationalIdGeometry.aspectRatio));
      
      // Passport should be taller (since it has 3:4 aspect ratio vs 16:10)
      expect(passportGeometry.height, greaterThan(nationalIdGeometry.height));
    });
  });

  group('FrameGeometry.forFaceDetection', () {
    const screenSize = Size(400, 800);

    test('should create circular frame with 1:1 aspect ratio', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      expect(geometry.aspectRatio, 1.0);
      expect(geometry.width, geometry.height);
    });

    test('should have diameter equal to 70% of screen width', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      final expectedDiameter = screenSize.width * 0.7;
      expect(geometry.width, expectedDiameter);
      expect(geometry.height, expectedDiameter);
    });

    test('should have corner radius equal to half diameter (circular)', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      expect(geometry.cornerRadius, geometry.width / 2);
    });

    test('should center frame horizontally on screen', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      final leftMargin = geometry.left;
      final rightMargin = screenSize.width - geometry.right;
      
      expect((leftMargin - rightMargin).abs(), lessThan(0.01));
    });

    test('should center frame vertically on screen', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      final topMargin = geometry.top;
      final bottomMargin = screenSize.height - geometry.bottom;
      
      expect((topMargin - bottomMargin).abs(), lessThan(0.01));
    });

    test('should handle small screen sizes', () {
      final smallScreen = const Size(320, 568);
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: smallScreen,
      );

      expect(geometry.width, smallScreen.width * 0.7);
      expect(geometry.left, greaterThanOrEqualTo(0));
      expect(geometry.top, greaterThanOrEqualTo(0));
    });

    test('should handle large screen sizes', () {
      final largeScreen = const Size(1080, 2400);
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: largeScreen,
      );

      expect(geometry.width, largeScreen.width * 0.7);
      expect(geometry.left, greaterThanOrEqualTo(0));
      expect(geometry.top, greaterThanOrEqualTo(0));
    });

    test('should store correct screen size', () {
      final geometry = FrameGeometry.forFaceDetection(
        screenSize: screenSize,
      );

      expect(geometry.screenSize, screenSize);
    });
  });

  group('FrameGeometry edge cases', () {
    test('should handle zero-sized screen gracefully', () {
      final geometry = FrameGeometry.forIDCapture(
        screenSize: const Size(0, 0),
        idType: IDType.nationalId,
      );

      expect(geometry.width, 0);
      expect(geometry.height, 0);
    });

    test('should handle very narrow screen', () {
      final narrowScreen = const Size(100, 800);
      final geometry = FrameGeometry.forIDCapture(
        screenSize: narrowScreen,
        idType: IDType.nationalId,
      );

      expect(geometry.width, lessThanOrEqualTo(narrowScreen.width * 0.85));
      expect(geometry.left, greaterThanOrEqualTo(0));
    });

    test('should handle very short screen', () {
      final shortScreen = const Size(400, 200);
      final geometry = FrameGeometry.forIDCapture(
        screenSize: shortScreen,
        idType: IDType.nationalId,
      );

      expect(geometry.height, lessThanOrEqualTo(shortScreen.height * 0.6));
      expect(geometry.top, greaterThanOrEqualTo(0));
    });

    test('should calculate overlap with partially overlapping rectangles', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(0, 0, 100, 100),
        aspectRatio: 1.0,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      // 25% overlap (50x50 intersection out of 100x100 detected)
      final quarterOverlap = geometry.calculateOverlap(
        const Rect.fromLTWH(50, 50, 100, 100),
      );
      expect(quarterOverlap, closeTo(0.25, 0.01));
    });

    test('should handle overlap calculation with larger detected rectangle', () {
      final geometry = FrameGeometry(
        frameRect: const Rect.fromLTWH(50, 50, 100, 100),
        aspectRatio: 1.0,
        cornerRadius: 16.0,
        screenSize: const Size(400, 800),
      );

      // Detected rectangle is larger than frame
      final overlap = geometry.calculateOverlap(
        const Rect.fromLTWH(0, 0, 200, 200),
      );
      
      // Intersection is 100x100, detected is 200x200, so 25% overlap
      expect(overlap, closeTo(0.25, 0.01));
    });
  });
}
