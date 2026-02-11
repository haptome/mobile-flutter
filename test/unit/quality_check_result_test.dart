// Purpose: Unit tests for QualityCheckResult model
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/quality_check_result.dart';

void main() {
  group('QualityCheckResult', () {
    test('creates instance with all required fields', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.isSharp, true);
      expect(result.hasNoGlare, true);
      expect(result.hasGoodLighting, true);
      expect(result.blurScore, 150.0);
      expect(result.glarePercentage, 5.0);
      expect(result.brightness, 120.0);
    });

    test('passed returns true when all checks pass', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.passed, true);
    });

    test('passed returns false when isSharp fails', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.passed, false);
    });

    test('passed returns false when hasNoGlare fails', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: false,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 20.0,
        brightness: 120.0,
      );

      expect(result.passed, false);
    });

    test('passed returns false when hasGoodLighting fails', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: false,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 30.0,
      );

      expect(result.passed, false);
    });

    test('passed returns false when multiple checks fail', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: false,
        hasGoodLighting: false,
        blurScore: 50.0,
        glarePercentage: 20.0,
        brightness: 30.0,
      );

      expect(result.passed, false);
    });

    test('failedChecks returns empty list when all checks pass', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.failedChecks, isEmpty);
    });

    test('failedChecks returns blur message when isSharp fails', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.failedChecks, contains('Image is too blurry'));
      expect(result.failedChecks.length, 1);
    });

    test('failedChecks returns glare message when hasNoGlare fails', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: false,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 20.0,
        brightness: 120.0,
      );

      expect(result.failedChecks, contains('Image has too much glare'));
      expect(result.failedChecks.length, 1);
    });

    test('failedChecks returns lighting message when hasGoodLighting fails', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: false,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 30.0,
      );

      expect(result.failedChecks, contains('Image has poor lighting'));
      expect(result.failedChecks.length, 1);
    });

    test('failedChecks returns all messages when all checks fail', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: false,
        hasGoodLighting: false,
        blurScore: 50.0,
        glarePercentage: 20.0,
        brightness: 30.0,
      );

      expect(result.failedChecks.length, 3);
      expect(result.failedChecks, contains('Image is too blurry'));
      expect(result.failedChecks, contains('Image has too much glare'));
      expect(result.failedChecks, contains('Image has poor lighting'));
    });

    test('message returns success message when all checks pass', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.message, 'Image quality is good');
    });

    test('message returns failed checks when checks fail', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result.message, 'Image is too blurry');
    });

    test('message returns multiple failed checks joined by comma', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: false,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 20.0,
        brightness: 120.0,
      );

      expect(result.message, contains('Image is too blurry'));
      expect(result.message, contains('Image has too much glare'));
      expect(result.message, contains(', '));
    });

    test('copyWith creates new instance with updated values', () {
      const original = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      final copied = original.copyWith(
        isSharp: false,
        blurScore: 50.0,
      );

      expect(copied.isSharp, false);
      expect(copied.hasNoGlare, true);
      expect(copied.hasGoodLighting, true);
      expect(copied.blurScore, 50.0);
      expect(copied.glarePercentage, 5.0);
      expect(copied.brightness, 120.0);
    });

    test('copyWith preserves original values when not specified', () {
      const original = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      final copied = original.copyWith();

      expect(copied.isSharp, original.isSharp);
      expect(copied.hasNoGlare, original.hasNoGlare);
      expect(copied.hasGoodLighting, original.hasGoodLighting);
      expect(copied.blurScore, original.blurScore);
      expect(copied.glarePercentage, original.glarePercentage);
      expect(copied.brightness, original.brightness);
    });

    test('toString returns formatted string', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      final str = result.toString();
      expect(str, contains('QualityCheckResult'));
      expect(str, contains('passed: true'));
      expect(str, contains('isSharp: true'));
      expect(str, contains('hasNoGlare: true'));
      expect(str, contains('hasGoodLighting: true'));
      expect(str, contains('blurScore: 150.0'));
      expect(str, contains('glarePercentage: 5.0'));
      expect(str, contains('brightness: 120.0'));
    });

    test('equality works correctly for identical instances', () {
      const result1 = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      const result2 = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('equality works correctly for different instances', () {
      const result1 = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      const result2 = QualityCheckResult(
        isSharp: false,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('handles edge case values correctly', () {
      const result = QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 100.0, // Threshold value
        glarePercentage: 15.0, // Threshold value
        brightness: 60.0, // Lower threshold
      );

      expect(result.blurScore, 100.0);
      expect(result.glarePercentage, 15.0);
      expect(result.brightness, 60.0);
    });

    test('handles extreme values correctly', () {
      const result = QualityCheckResult(
        isSharp: false,
        hasNoGlare: false,
        hasGoodLighting: false,
        blurScore: 0.0,
        glarePercentage: 100.0,
        brightness: 0.0,
      );

      expect(result.passed, false);
      expect(result.blurScore, 0.0);
      expect(result.glarePercentage, 100.0);
      expect(result.brightness, 0.0);
    });
  });
}
