// Purpose: Unit tests for EdgeDetectionResult and FaceDetectionResult models
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/detection_result.dart';

void main() {
  group('EdgeDetectionResult', () {
    test('should create instance with all required properties', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(10, 10),
          Offset(110, 10),
          Offset(110, 60),
          Offset(10, 60),
        ],
        confidence: 0.85,
        isAligned: true,
        overlapPercentage: 0.92,
      );

      expect(result.corners.length, 4);
      expect(result.confidence, 0.85);
      expect(result.isAligned, true);
      expect(result.overlapPercentage, 0.92);
    });

    test('should validate corners correctly', () {
      final validResult = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final invalidResult = EdgeDetectionResult(
        corners: const [Offset(0, 0), Offset(100, 0)],
        confidence: 0.8,
        isAligned: false,
        overlapPercentage: 0.5,
      );

      expect(validResult.hasValidCorners, true);
      expect(invalidResult.hasValidCorners, false);
    });

    test('should calculate center point correctly', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      expect(result.center, const Offset(50, 50));
    });

    test('should return zero center for invalid corners', () {
      final result = EdgeDetectionResult(
        corners: const [],
        confidence: 0.0,
        isAligned: false,
        overlapPercentage: 0.0,
      );

      expect(result.center, Offset.zero);
    });

    test('should calculate width correctly', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 50),
          Offset(0, 50),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      expect(result.width, 100.0);
    });

    test('should calculate height correctly', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 50),
          Offset(0, 50),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      expect(result.height, 50.0);
    });

    test('should calculate aspect ratio correctly', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(160, 0),
          Offset(160, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      expect(result.aspectRatio, 1.6);
    });

    test('should return zero aspect ratio when height is zero', () {
      final result = EdgeDetectionResult(
        corners: const [],
        confidence: 0.0,
        isAligned: false,
        overlapPercentage: 0.0,
      );

      expect(result.aspectRatio, 0.0);
    });

    test('should determine if good for capture', () {
      final goodResult = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final lowConfidence = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.5,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final notAligned = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: false,
        overlapPercentage: 0.9,
      );

      final lowOverlap = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.7,
      );

      expect(goodResult.isGoodForCapture, true);
      expect(lowConfidence.isGoodForCapture, false);
      expect(notAligned.isGoodForCapture, false);
      expect(lowOverlap.isGoodForCapture, false);
    });

    test('should create copy with updated values', () {
      final original = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final copy = original.copyWith(
        confidence: 0.95,
        isAligned: false,
      );

      expect(copy.corners, original.corners);
      expect(copy.confidence, 0.95);
      expect(copy.isAligned, false);
      expect(copy.overlapPercentage, original.overlapPercentage);
    });

    test('should implement equality correctly', () {
      final result1 = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final result2 = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.8,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      final result3 = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.7,
        isAligned: true,
        overlapPercentage: 0.9,
      );

      expect(result1, result2);
      expect(result1, isNot(result3));
      expect(result1.hashCode, result2.hashCode);
    });

    test('should have meaningful toString', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.85,
        isAligned: true,
        overlapPercentage: 0.92,
      );

      final str = result.toString();
      expect(str, contains('EdgeDetectionResult'));
      expect(str, contains('4'));
      expect(str, contains('0.85'));
      expect(str, contains('true'));
      expect(str, contains('92.0%'));
    });
  });

  group('FaceDetectionResult', () {
    test('should create instance with all required properties', () {
      final result = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(50, 100, 200, 250),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      expect(result.faceBounds, const Rect.fromLTWH(50, 100, 200, 250));
      expect(result.leftEyeOpenProbability, 0.9);
      expect(result.rightEyeOpenProbability, 0.85);
      expect(result.headEulerAngleY, 5.0);
      expect(result.headEulerAngleZ, -3.0);
      expect(result.isFrontal, true);
    });

    test('should provide correct dimension getters', () {
      final result = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(50, 100, 200, 250),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(result.center, const Offset(150, 225));
      expect(result.width, 200);
      expect(result.height, 250);
    });

    test('should detect both eyes open', () {
      final bothOpen = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      final leftClosed = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.2,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(bothOpen.bothEyesOpen, true);
      expect(leftClosed.bothEyesOpen, false);
    });

    test('should detect both eyes closed', () {
      final bothClosed = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.2,
        rightEyeOpenProbability: 0.25,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      final rightOpen = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.2,
        rightEyeOpenProbability: 0.8,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(bothClosed.bothEyesClosed, true);
      expect(rightOpen.bothEyesClosed, false);
    });

    test('should detect neutral pose', () {
      final neutral = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      final notNeutral = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 35.0,
        headEulerAngleZ: 0.0,
        isFrontal: false,
      );

      expect(neutral.isNeutralPose, true);
      expect(notNeutral.isNeutralPose, false);
    });

    test('should detect head turned left', () {
      final turnedLeft = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: -35.0,
        headEulerAngleZ: 0.0,
        isFrontal: false,
      );

      final notTurnedLeft = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: -20.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(turnedLeft.isTurnedLeft, true);
      expect(notTurnedLeft.isTurnedLeft, false);
    });

    test('should detect head turned right', () {
      final turnedRight = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 35.0,
        headEulerAngleZ: 0.0,
        isFrontal: false,
      );

      final notTurnedRight = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 20.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(turnedRight.isTurnedRight, true);
      expect(notTurnedRight.isTurnedRight, false);
    });

    test('should detect looking up', () {
      final lookingUp = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: -25.0,
        isFrontal: false,
      );

      final notLookingUp = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: -10.0,
        isFrontal: true,
      );

      expect(lookingUp.isLookingUp, true);
      expect(notLookingUp.isLookingUp, false);
    });

    test('should detect looking down', () {
      final lookingDown = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 25.0,
        isFrontal: false,
      );

      final notLookingDown = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 10.0,
        isFrontal: true,
      );

      expect(lookingDown.isLookingDown, true);
      expect(notLookingDown.isLookingDown, false);
    });

    test('should calculate average eye open probability', () {
      final result = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.8,
        rightEyeOpenProbability: 0.6,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(result.averageEyeOpenProbability, 0.7);
    });

    test('should determine if suitable for liveness', () {
      final suitable = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      final tooSmall = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 0, 0),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(suitable.isSuitableForLiveness, true);
      expect(tooSmall.isSuitableForLiveness, false);
    });

    test('should create copy with updated values', () {
      final original = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      final copy = original.copyWith(
        leftEyeOpenProbability: 0.2,
        rightEyeOpenProbability: 0.25,
        isFrontal: false,
      );

      expect(copy.faceBounds, original.faceBounds);
      expect(copy.leftEyeOpenProbability, 0.2);
      expect(copy.rightEyeOpenProbability, 0.25);
      expect(copy.headEulerAngleY, original.headEulerAngleY);
      expect(copy.headEulerAngleZ, original.headEulerAngleZ);
      expect(copy.isFrontal, false);
    });

    test('should implement equality correctly', () {
      final result1 = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      final result2 = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      final result3 = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.8,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      expect(result1, result2);
      expect(result1, isNot(result3));
      expect(result1.hashCode, result2.hashCode);
    });

    test('should have meaningful toString', () {
      final result = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(50, 100, 200, 250),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 5.0,
        headEulerAngleZ: -3.0,
        isFrontal: true,
      );

      final str = result.toString();
      expect(str, contains('FaceDetectionResult'));
      expect(str, contains('0.90'));
      expect(str, contains('0.85'));
      expect(str, contains('5.0'));
      expect(str, contains('-3.0'));
      expect(str, contains('true'));
    });
  });

  group('EdgeDetectionResult edge cases', () {
    test('should handle empty corners list', () {
      final result = EdgeDetectionResult(
        corners: const [],
        confidence: 0.0,
        isAligned: false,
        overlapPercentage: 0.0,
      );

      expect(result.hasValidCorners, false);
      expect(result.center, Offset.zero);
      expect(result.width, 0.0);
      expect(result.height, 0.0);
      expect(result.aspectRatio, 0.0);
    });

    test('should handle non-rectangular shapes', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 20),
          Offset(90, 100),
          Offset(10, 80),
        ],
        confidence: 0.6,
        isAligned: false,
        overlapPercentage: 0.7,
      );

      expect(result.hasValidCorners, true);
      expect(result.width, greaterThan(0));
      expect(result.height, greaterThan(0));
    });

    test('should handle very low confidence', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.1,
        isAligned: true,
        overlapPercentage: 0.95,
      );

      expect(result.isGoodForCapture, false);
    });

    test('should handle perfect overlap', () {
      final result = EdgeDetectionResult(
        corners: const [
          Offset(0, 0),
          Offset(100, 0),
          Offset(100, 100),
          Offset(0, 100),
        ],
        confidence: 0.95,
        isAligned: true,
        overlapPercentage: 1.0,
      );

      expect(result.isGoodForCapture, true);
    });
  });

  group('FaceDetectionResult edge cases', () {
    test('should handle extreme head angles', () {
      final extremeYaw = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 85.0,
        headEulerAngleZ: 0.0,
        isFrontal: false,
      );

      final extremePitch = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: -85.0,
        isFrontal: false,
      );

      expect(extremeYaw.isTurnedRight, true);
      expect(extremePitch.isLookingUp, true);
    });

    test('should handle boundary eye probabilities', () {
      final exactlyOpen = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.7,
        rightEyeOpenProbability: 0.7,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      final exactlyClosed = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.3,
        rightEyeOpenProbability: 0.3,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(exactlyOpen.bothEyesOpen, false);
      expect(exactlyClosed.bothEyesClosed, false);
    });

    test('should handle zero-sized face bounds', () {
      final result = FaceDetectionResult(
        faceBounds: Rect.zero,
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 0.0,
        headEulerAngleZ: 0.0,
        isFrontal: true,
      );

      expect(result.width, 0);
      expect(result.height, 0);
      expect(result.isSuitableForLiveness, false);
    });

    test('should handle boundary neutral pose angles', () {
      final exactlyNeutral = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 10.0,
        headEulerAngleZ: -10.0,
        isFrontal: true,
      );

      final justOutsideNeutral = FaceDetectionResult(
        faceBounds: const Rect.fromLTWH(0, 0, 100, 100),
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.85,
        headEulerAngleY: 10.1,
        headEulerAngleZ: 0.0,
        isFrontal: false,
      );

      expect(exactlyNeutral.isNeutralPose, true);
      expect(justOutsideNeutral.isNeutralPose, false);
    });
  });
}
