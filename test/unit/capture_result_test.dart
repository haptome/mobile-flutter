// Purpose: Unit tests for CaptureResult model
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:et_digital_equb/models/capture_result.dart';
import 'package:et_digital_equb/models/id_type.dart';
import 'package:et_digital_equb/models/quality_check_result.dart';

void main() {
  group('CaptureResult', () {
    late XFile mockImageFile;
    late QualityCheckResult mockQualityCheck;
    late DateTime mockTimestamp;

    setUp(() {
      mockImageFile = XFile('/path/to/image.jpg');
      mockQualityCheck = const QualityCheckResult(
        isSharp: true,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 150.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );
      mockTimestamp = DateTime(2024, 1, 15, 10, 30);
    });

    test('creates instance with all required fields', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.imageFile, mockImageFile);
      expect(result.idType, IDType.nationalId);
      expect(result.isFrontSide, true);
      expect(result.qualityCheck, mockQualityCheck);
      expect(result.timestamp, mockTimestamp);
    });

    test('path getter returns image file path', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.path, '/path/to/image.jpg');
    });

    test('name getter returns image file name', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.name, 'image.jpg');
    });

    test('isValid returns true when quality check passed', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.isValid, true);
    });

    test('isValid returns false when quality check failed', () {
      final failedQualityCheck = const QualityCheckResult(
        isSharp: false,
        hasNoGlare: true,
        hasGoodLighting: true,
        blurScore: 50.0,
        glarePercentage: 5.0,
        brightness: 120.0,
      );

      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: failedQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.isValid, false);
    });

    test('label returns correct format for front side', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.label, 'National ID - Front');
    });

    test('label returns correct format for back side', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.driverLicense,
        isFrontSide: false,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.label, 'Driver License - Back');
    });

    test('label works correctly for passport', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.passport,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result.label, 'Passport - Front');
    });

    test('copyWith creates new instance with updated values', () {
      final original = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      final newTimestamp = DateTime(2024, 1, 16, 10, 30);
      final copied = original.copyWith(
        isFrontSide: false,
        timestamp: newTimestamp,
      );

      expect(copied.imageFile, original.imageFile);
      expect(copied.idType, original.idType);
      expect(copied.isFrontSide, false);
      expect(copied.qualityCheck, original.qualityCheck);
      expect(copied.timestamp, newTimestamp);
    });

    test('copyWith preserves original values when not specified', () {
      final original = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      final copied = original.copyWith();

      expect(copied.imageFile, original.imageFile);
      expect(copied.idType, original.idType);
      expect(copied.isFrontSide, original.isFrontSide);
      expect(copied.qualityCheck, original.qualityCheck);
      expect(copied.timestamp, original.timestamp);
    });

    test('toString returns formatted string', () {
      final result = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      final str = result.toString();
      expect(str, contains('CaptureResult'));
      expect(str, contains('/path/to/image.jpg'));
      expect(str, contains('IDType.nationalId'));
      expect(str, contains('true'));
    });

    test('equality works correctly for identical instances', () {
      final result1 = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      final result2 = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('equality works correctly for different instances', () {
      final result1 = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.nationalId,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      final result2 = CaptureResult(
        imageFile: mockImageFile,
        idType: IDType.passport,
        isFrontSide: true,
        qualityCheck: mockQualityCheck,
        timestamp: mockTimestamp,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('handles different ID types correctly', () {
      for (final idType in IDType.values) {
        final result = CaptureResult(
          imageFile: mockImageFile,
          idType: idType,
          isFrontSide: true,
          qualityCheck: mockQualityCheck,
          timestamp: mockTimestamp,
        );

        expect(result.idType, idType);
        expect(result.label, contains(IDTypeInfo.forType(idType).displayName));
      }
    });
  });
}
