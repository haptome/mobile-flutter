// Purpose: Test FileValidation constants
// Verifies that file validation constants are correctly defined

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/config/file_validation.dart';

void main() {
  group('FileValidation Constants Tests', () {
    test('maximum file sizes are correctly defined', () {
      expect(FileValidation.maxImageSizeBytes, equals(10 * 1024 * 1024)); // 10MB
      expect(FileValidation.maxVideoSizeBytes, equals(50 * 1024 * 1024)); // 50MB
    });

    test('supported image formats are correctly defined', () {
      expect(FileValidation.supportedImageFormats, contains('jpg'));
      expect(FileValidation.supportedImageFormats, contains('jpeg'));
      expect(FileValidation.supportedImageFormats, contains('png'));
      expect(FileValidation.supportedImageFormats, contains('heic'));
      expect(FileValidation.supportedImageFormats.length, equals(4));
    });

    test('supported video formats are correctly defined', () {
      expect(FileValidation.supportedVideoFormats, contains('mp4'));
      expect(FileValidation.supportedVideoFormats, contains('mov'));
      expect(FileValidation.supportedVideoFormats.length, equals(2));
    });

    test('image transformation settings are correctly defined', () {
      expect(FileValidation.maxImageWidth, equals(2048));
      expect(FileValidation.maxImageHeight, equals(2048));
      expect(FileValidation.imageQuality, equals('auto'));
      expect(FileValidation.imageFormat, equals('auto'));
    });

    test('retry settings are correctly defined', () {
      expect(FileValidation.maxRetries, equals(3));
      expect(FileValidation.retryDelaysMs, equals([1000, 2000, 4000]));
      expect(FileValidation.retryDelaysMs.length, equals(3));
    });

    test('progress update threshold is correctly defined', () {
      expect(FileValidation.progressUpdateBytes, equals(100 * 1024)); // 100KB
    });
  });
}
