// Purpose: Test Cloudinary data models
// Tests CloudinaryResponse, CloudinaryError, ValidationResult, and QueuedUpload models

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/cloudinary_response.dart';
import 'package:et_digital_equb/models/cloudinary_error.dart';
import 'package:et_digital_equb/models/validation_result.dart';
import 'package:et_digital_equb/models/queued_upload.dart';

void main() {
  group('CloudinaryResponse Tests', () {
    test('success factory creates valid response', () {
      final response = CloudinaryResponse.success(
        secureUrl: 'https://cloudinary.com/image.jpg',
        publicId: 'test/image',
        resourceType: 'image',
        format: 'jpg',
        bytes: 1024,
      );

      expect(response.success, isTrue);
      expect(response.secureUrl, equals('https://cloudinary.com/image.jpg'));
      expect(response.publicId, equals('test/image'));
      expect(response.resourceType, equals('image'));
      expect(response.format, equals('jpg'));
      expect(response.bytes, equals(1024));
      expect(response.error, isNull);
    });

    test('failure factory creates error response', () {
      final error = CloudinaryError(
        code: CloudinaryError.networkError,
        message: 'Network failed',
      );
      final response = CloudinaryResponse.failure(error: error);

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
      expect(response.error!.code, equals(CloudinaryError.networkError));
      expect(response.secureUrl, isNull);
      expect(response.publicId, isNull);
    });

    test('fromCloudinarySDK parses SDK response correctly', () {
      final sdkResponse = {
        'secure_url': 'https://cloudinary.com/video.mp4',
        'public_id': 'test/video',
        'resource_type': 'video',
        'format': 'mp4',
        'bytes': 2048,
      };

      final response = CloudinaryResponse.fromCloudinarySDK(sdkResponse);

      expect(response.success, isTrue);
      expect(response.secureUrl, equals('https://cloudinary.com/video.mp4'));
      expect(response.publicId, equals('test/video'));
      expect(response.resourceType, equals('video'));
      expect(response.format, equals('mp4'));
      expect(response.bytes, equals(2048));
    });
  });

  group('CloudinaryError Tests', () {
    test('error codes are defined correctly', () {
      expect(CloudinaryError.networkError, equals('NETWORK_ERROR'));
      expect(CloudinaryError.authError, equals('AUTH_ERROR'));
      expect(CloudinaryError.fileTooLarge, equals('FILE_TOO_LARGE'));
      expect(CloudinaryError.invalidFileType, equals('INVALID_FILE_TYPE'));
      expect(CloudinaryError.quotaExceeded, equals('QUOTA_EXCEEDED'));
      expect(CloudinaryError.timeoutError, equals('TIMEOUT_ERROR'));
      expect(CloudinaryError.validationError, equals('VALIDATION_ERROR'));
      expect(CloudinaryError.unknownError, equals('UNKNOWN_ERROR'));
    });

    test('userMessage returns correct message for network error', () {
      final error = CloudinaryError(
        code: CloudinaryError.networkError,
        message: 'Connection failed',
      );

      expect(
        error.userMessage,
        equals('Network connection failed. Please check your internet connection.'),
      );
    });

    test('userMessage returns correct message for file too large', () {
      final error = CloudinaryError(
        code: CloudinaryError.fileTooLarge,
        message: 'File exceeds limit',
      );

      expect(
        error.userMessage,
        equals('File is too large. Maximum size is 10MB for images and 50MB for videos.'),
      );
    });

    test('userMessage returns custom message for validation error', () {
      final error = CloudinaryError(
        code: CloudinaryError.validationError,
        message: 'Custom validation message',
      );

      expect(error.userMessage, equals('Custom validation message'));
    });

    test('userMessage returns default message for unknown error', () {
      final error = CloudinaryError(
        code: 'CUSTOM_ERROR',
        message: 'Some error',
      );

      expect(error.userMessage, equals('Upload failed. Please try again.'));
    });

    test('error can include optional details', () {
      final error = CloudinaryError(
        code: CloudinaryError.authError,
        message: 'Auth failed',
        details: 'Invalid credentials provided',
      );

      expect(error.details, equals('Invalid credentials provided'));
    });
  });

  group('ValidationResult Tests', () {
    test('valid factory creates valid result', () {
      final result = ValidationResult.valid();

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });

    test('invalid factory creates invalid result with error details', () {
      final result = ValidationResult.invalid(
        message: 'File too large',
        code: 'FILE_TOO_LARGE',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('File too large'));
      expect(result.errorCode, equals('FILE_TOO_LARGE'));
    });
  });

  group('QueuedUpload Tests', () {
    test('creates queued upload with required fields', () {
      final now = DateTime.now();
      final upload = QueuedUpload(
        id: 'test-id',
        filePath: '/path/to/file.jpg',
        folder: 'kyc/user123/id_card',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: now,
      );

      expect(upload.id, equals('test-id'));
      expect(upload.filePath, equals('/path/to/file.jpg'));
      expect(upload.folder, equals('kyc/user123/id_card'));
      expect(upload.fileType, equals(FileType.image));
      expect(upload.status, equals(QueueStatus.pending));
      expect(upload.queuedAt, equals(now));
      expect(upload.uploadedAt, isNull);
      expect(upload.errorMessage, isNull);
      expect(upload.retryCount, equals(0));
    });

    test('toJson serializes correctly', () {
      final now = DateTime.now();
      final upload = QueuedUpload(
        id: 'test-id',
        filePath: '/path/to/file.jpg',
        folder: 'kyc/user123/id_card',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: now,
        metadata: {'key': 'value'},
      );

      final json = upload.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['file_path'], equals('/path/to/file.jpg'));
      expect(json['folder'], equals('kyc/user123/id_card'));
      expect(json['file_type'], equals('FileType.image'));
      expect(json['status'], equals('QueueStatus.pending'));
      expect(json['queued_at'], equals(now.toIso8601String()));
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('fromJson deserializes correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'file_path': '/path/to/file.jpg',
        'folder': 'kyc/user123/id_card',
        'file_type': 'FileType.image',
        'status': 'QueueStatus.pending',
        'queued_at': now.toIso8601String(),
        'retry_count': 2,
      };

      final upload = QueuedUpload.fromJson(json);

      expect(upload.id, equals('test-id'));
      expect(upload.filePath, equals('/path/to/file.jpg'));
      expect(upload.folder, equals('kyc/user123/id_card'));
      expect(upload.fileType, equals(FileType.image));
      expect(upload.status, equals(QueueStatus.pending));
      expect(upload.retryCount, equals(2));
    });

    test('copyWith creates updated copy', () {
      final now = DateTime.now();
      final upload = QueuedUpload(
        id: 'test-id',
        filePath: '/path/to/file.jpg',
        folder: 'kyc/user123/id_card',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: now,
      );

      final updated = upload.copyWith(
        status: QueueStatus.completed,
        uploadedAt: now.add(Duration(seconds: 10)),
      );

      expect(updated.id, equals('test-id'));
      expect(updated.status, equals(QueueStatus.completed));
      expect(updated.uploadedAt, isNotNull);
      expect(updated.filePath, equals('/path/to/file.jpg'));
    });

    test('FileType enum has correct values', () {
      expect(FileType.image, isNotNull);
      expect(FileType.video, isNotNull);
    });

    test('QueueStatus enum has correct values', () {
      expect(QueueStatus.pending, isNotNull);
      expect(QueueStatus.uploading, isNotNull);
      expect(QueueStatus.completed, isNotNull);
      expect(QueueStatus.failed, isNotNull);
    });
  });
}
