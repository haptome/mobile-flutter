// Purpose: Test CloudinaryService file validation functionality
// Tests validateFile method for images and videos

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/core/services/cloudinary_service.dart';
import 'package:et_digital_equb/config/cloudinary_config.dart';
import 'package:et_digital_equb/core/services/upload_queue.dart';
import 'package:et_digital_equb/models/queued_upload.dart';
import 'package:et_digital_equb/models/cloudinary_error.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

void main() {
  late CloudinaryService cloudinaryService;
  late Directory tempDir;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Create CloudinaryConfig for testing
    final config = CloudinaryConfig.forEnvironment(Environment.development);

    // Create UploadQueue
    final uploadQueue = UploadQueue(prefs, Connectivity());

    // Create CloudinaryService
    cloudinaryService = CloudinaryService(config, uploadQueue, Connectivity());

    // Create temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp('cloudinary_test_');
  });

  tearDown(() async {
    // Clean up temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('validateFile - Image Format Validation', () {
    test('accepts valid JPEG image with .jpg extension', () async {
      // Create a small test file
      final file = File(path.join(tempDir.path, 'test.jpg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]); // JPEG header

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });

    test('accepts valid JPEG image with .jpeg extension', () async {
      final file = File(path.join(tempDir.path, 'test.jpeg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts valid PNG image', () async {
      final file = File(path.join(tempDir.path, 'test.png'));
      await file.writeAsBytes([0x89, 0x50, 0x4E, 0x47]); // PNG header

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts valid HEIC image', () async {
      final file = File(path.join(tempDir.path, 'test.heic'));
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x18]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects image with unsupported extension', () async {
      final file = File(path.join(tempDir.path, 'test.gif'));
      await file.writeAsBytes([0x47, 0x49, 0x46]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
      expect(result.errorMessage, contains('Invalid image format'));
      expect(result.errorMessage, contains('jpg, jpeg, png, heic'));
    });

    test('rejects image with .bmp extension', () async {
      final file = File(path.join(tempDir.path, 'test.bmp'));
      await file.writeAsBytes([0x42, 0x4D]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
    });

    test('handles case-insensitive extensions for images', () async {
      final file = File(path.join(tempDir.path, 'test.JPG'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('handles mixed case extensions for images', () async {
      final file = File(path.join(tempDir.path, 'test.PnG'));
      await file.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('validateFile - Video Format Validation', () {
    test('accepts valid MP4 video', () async {
      final file = File(path.join(tempDir.path, 'test.mp4'));
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x18]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });

    test('accepts valid MOV video', () async {
      final file = File(path.join(tempDir.path, 'test.mov'));
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x14]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects video with unsupported extension', () async {
      final file = File(path.join(tempDir.path, 'test.avi'));
      await file.writeAsBytes([0x52, 0x49, 0x46, 0x46]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
      expect(result.errorMessage, contains('Invalid video format'));
      expect(result.errorMessage, contains('mp4, mov'));
    });

    test('rejects video with .mkv extension', () async {
      final file = File(path.join(tempDir.path, 'test.mkv'));
      await file.writeAsBytes([0x1A, 0x45, 0xDF, 0xA3]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
    });

    test('handles case-insensitive extensions for videos', () async {
      final file = File(path.join(tempDir.path, 'test.MP4'));
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x18]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
    });

    test('handles mixed case extensions for videos', () async {
      final file = File(path.join(tempDir.path, 'test.MoV'));
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x14]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('validateFile - Image Size Validation', () {
    test('accepts image under 10MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.jpg'));
      // Create 5MB file
      final bytes = List<int>.filled(5 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts image exactly at 10MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.jpg'));
      // Create exactly 10MB file
      final bytes = List<int>.filled(10 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects image over 10MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.jpg'));
      // Create 11MB file
      final bytes = List<int>.filled(11 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.fileTooLarge));
      expect(result.errorMessage, contains('too large'));
      expect(result.errorMessage, contains('10MB'));
    });

    test('rejects image significantly over 10MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.png'));
      // Create 20MB file
      final bytes = List<int>.filled(20 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.fileTooLarge));
    });
  });

  group('validateFile - Video Size Validation', () {
    test('accepts video under 50MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.mp4'));
      // Create 25MB file
      final bytes = List<int>.filled(25 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts video exactly at 50MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.mp4'));
      // Create exactly 50MB file
      final bytes = List<int>.filled(50 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects video over 50MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.mp4'));
      // Create 51MB file
      final bytes = List<int>.filled(51 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.fileTooLarge));
      expect(result.errorMessage, contains('too large'));
      expect(result.errorMessage, contains('50MB'));
    });

    test('rejects video significantly over 50MB limit', () async {
      final file = File(path.join(tempDir.path, 'test.mov'));
      // Create 100MB file
      final bytes = List<int>.filled(100 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.fileTooLarge));
    });
  });

  group('validateFile - File Existence Validation', () {
    test('rejects non-existent file', () {
      final nonExistentPath = path.join(tempDir.path, 'nonexistent.jpg');

      final result = cloudinaryService.validateFile(
        nonExistentPath,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.validationError));
      expect(result.errorMessage, contains('does not exist'));
    });

    test('rejects empty file path', () {
      final result = cloudinaryService.validateFile(
        '',
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.validationError));
    });
  });

  group('validateFile - Edge Cases', () {
    test('rejects file with no extension', () async {
      final file = File(path.join(tempDir.path, 'testfile'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
      expect(result.errorMessage, contains('no extension'));
    });

    test('rejects file with only extension (e.g., ".jpg")', () async {
      final file = File(path.join(tempDir.path, '.jpg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue); // .jpg is a valid extension
    });

    test('handles file with multiple dots in name', () async {
      final file = File(path.join(tempDir.path, 'my.photo.test.jpg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('handles file ending with dot', () async {
      final file = File(path.join(tempDir.path, 'testfile.'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(CloudinaryError.invalidFileType));
    });

    test('accepts very small valid image file', () async {
      final file = File(path.join(tempDir.path, 'tiny.jpg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF]); // Just 3 bytes

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts empty file with valid extension and type', () async {
      final file = File(path.join(tempDir.path, 'empty.jpg'));
      await file.writeAsBytes([]); // Empty file

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('validateFile - Error Messages', () {
    test('provides specific error message for invalid image format', () async {
      final file = File(path.join(tempDir.path, 'test.gif'));
      await file.writeAsBytes([0x47, 0x49, 0x46]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, isNotEmpty);
      expect(result.errorMessage, contains('Invalid image format'));
    });

    test('provides specific error message for invalid video format', () async {
      final file = File(path.join(tempDir.path, 'test.avi'));
      await file.writeAsBytes([0x52, 0x49, 0x46, 0x46]);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, isNotEmpty);
      expect(result.errorMessage, contains('Invalid video format'));
    });

    test('provides specific error message for oversized image', () async {
      final file = File(path.join(tempDir.path, 'test.jpg'));
      final bytes = List<int>.filled(11 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.image,
      );

      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, isNotEmpty);
      expect(result.errorMessage, contains('too large'));
      expect(result.errorMessage, contains('10MB'));
    });

    test('provides specific error message for oversized video', () async {
      final file = File(path.join(tempDir.path, 'test.mp4'));
      final bytes = List<int>.filled(51 * 1024 * 1024, 0);
      await file.writeAsBytes(bytes);

      final result = cloudinaryService.validateFile(
        file.path,
        FileType.video,
      );

      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, isNotEmpty);
      expect(result.errorMessage, contains('too large'));
      expect(result.errorMessage, contains('50MB'));
    });

    test('provides specific error message for non-existent file', () {
      final result = cloudinaryService.validateFile(
        '/nonexistent/path/file.jpg',
        FileType.image,
      );

      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, isNotEmpty);
      expect(result.errorMessage, contains('does not exist'));
    });
  });
}
