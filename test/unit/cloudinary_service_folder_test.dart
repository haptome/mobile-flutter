// Purpose: Test CloudinaryService folder path generation functionality
// Tests generateKycFolder, generateLivenessPhotoFolder, generateLivenessVideoFolder methods

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/core/services/cloudinary_service.dart';
import 'package:et_digital_equb/config/cloudinary_config.dart';
import 'package:et_digital_equb/core/services/upload_queue.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CloudinaryService cloudinaryService;

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
  });

  group('generateKycFolder', () {
    test('generates correct folder path format', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'passport');

      // Should match pattern: kyc/{userId}/{docType}/{timestamp}
      expect(folder, startsWith('kyc/user123/passport/'));
      
      // Extract timestamp part
      final parts = folder.split('/');
      expect(parts.length, equals(4));
      expect(parts[0], equals('kyc'));
      expect(parts[1], equals('user123'));
      expect(parts[2], equals('passport'));
      
      // Verify timestamp is ISO 8601 format
      final timestamp = parts[3];
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });

    test('sanitizes userId with special characters', () {
      final folder = cloudinaryService.generateKycFolder('user@123!', 'passport');

      // Special characters should be replaced with underscores
      expect(folder, contains('kyc/user_123_/passport/'));
    });

    test('sanitizes docType with special characters', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'id card');

      // Space should be replaced with underscore
      expect(folder, contains('kyc/user123/id_card/'));
    });

    test('preserves hyphens and underscores in userId', () {
      final folder = cloudinaryService.generateKycFolder('user-name_123', 'passport');

      // Hyphens and underscores should be preserved
      expect(folder, contains('kyc/user-name_123/passport/'));
    });

    test('preserves hyphens and underscores in docType', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'drivers-license_v2');

      // Hyphens and underscores should be preserved
      expect(folder, contains('kyc/user123/drivers-license_v2/'));
    });

    test('handles userId with multiple special characters', () {
      final folder = cloudinaryService.generateKycFolder('user@#\$%123', 'passport');

      // All special characters should be replaced
      expect(folder, contains('kyc/user____123/passport/'));
    });

    test('handles docType with multiple special characters', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'id!@#card');

      // All special characters should be replaced
      expect(folder, contains('kyc/user123/id___card/'));
    });

    test('handles empty userId', () {
      final folder = cloudinaryService.generateKycFolder('', 'passport');

      // Should still generate valid path with empty userId
      expect(folder, startsWith('kyc//passport/'));
    });

    test('handles empty docType', () {
      final folder = cloudinaryService.generateKycFolder('user123', '');

      // Should still generate valid path with empty docType
      expect(folder, startsWith('kyc/user123//'));
    });

    test('generates unique timestamps for consecutive calls', () async {
      final folder1 = cloudinaryService.generateKycFolder('user123', 'passport');
      
      // Small delay to ensure different timestamps
      await Future.delayed(Duration(milliseconds: 10));
      
      final folder2 = cloudinaryService.generateKycFolder('user123', 'passport');

      // Folders should be different due to different timestamps
      expect(folder1, isNot(equals(folder2)));
    });

    test('handles userId with dots', () {
      final folder = cloudinaryService.generateKycFolder('user.123.test', 'passport');

      // Dots should be replaced with underscores
      expect(folder, contains('kyc/user_123_test/passport/'));
    });

    test('handles docType with slashes', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'id/card');

      // Slashes should be replaced with underscores
      expect(folder, contains('kyc/user123/id_card/'));
    });
  });

  group('generateLivenessPhotoFolder', () {
    test('generates correct folder path format', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user123');

      // Should match pattern: liveness/{userId}/photo/{timestamp}
      expect(folder, startsWith('liveness/user123/photo/'));
      
      // Extract timestamp part
      final parts = folder.split('/');
      expect(parts.length, equals(4));
      expect(parts[0], equals('liveness'));
      expect(parts[1], equals('user123'));
      expect(parts[2], equals('photo'));
      
      // Verify timestamp is ISO 8601 format
      final timestamp = parts[3];
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });

    test('sanitizes userId with special characters', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user@123!');

      // Special characters should be replaced with underscores
      expect(folder, contains('liveness/user_123_/photo/'));
    });

    test('preserves hyphens and underscores in userId', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user-name_123');

      // Hyphens and underscores should be preserved
      expect(folder, contains('liveness/user-name_123/photo/'));
    });

    test('handles userId with multiple special characters', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user@#\$%123');

      // All special characters should be replaced
      expect(folder, contains('liveness/user____123/photo/'));
    });

    test('handles empty userId', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('');

      // Should still generate valid path with empty userId
      expect(folder, startsWith('liveness//photo/'));
    });

    test('generates unique timestamps for consecutive calls', () async {
      final folder1 = cloudinaryService.generateLivenessPhotoFolder('user123');
      
      // Small delay to ensure different timestamps
      await Future.delayed(Duration(milliseconds: 10));
      
      final folder2 = cloudinaryService.generateLivenessPhotoFolder('user123');

      // Folders should be different due to different timestamps
      expect(folder1, isNot(equals(folder2)));
    });

    test('handles userId with dots', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user.123.test');

      // Dots should be replaced with underscores
      expect(folder, contains('liveness/user_123_test/photo/'));
    });
  });

  group('generateLivenessVideoFolder', () {
    test('generates correct folder path format', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user123');

      // Should match pattern: liveness/{userId}/video/{timestamp}
      expect(folder, startsWith('liveness/user123/video/'));
      
      // Extract timestamp part
      final parts = folder.split('/');
      expect(parts.length, equals(4));
      expect(parts[0], equals('liveness'));
      expect(parts[1], equals('user123'));
      expect(parts[2], equals('video'));
      
      // Verify timestamp is ISO 8601 format
      final timestamp = parts[3];
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });

    test('sanitizes userId with special characters', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user@123!');

      // Special characters should be replaced with underscores
      expect(folder, contains('liveness/user_123_/video/'));
    });

    test('preserves hyphens and underscores in userId', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user-name_123');

      // Hyphens and underscores should be preserved
      expect(folder, contains('liveness/user-name_123/video/'));
    });

    test('handles userId with multiple special characters', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user@#\$%123');

      // All special characters should be replaced
      expect(folder, contains('liveness/user____123/video/'));
    });

    test('handles empty userId', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('');

      // Should still generate valid path with empty userId
      expect(folder, startsWith('liveness//video/'));
    });

    test('generates unique timestamps for consecutive calls', () async {
      final folder1 = cloudinaryService.generateLivenessVideoFolder('user123');
      
      // Small delay to ensure different timestamps
      await Future.delayed(Duration(milliseconds: 10));
      
      final folder2 = cloudinaryService.generateLivenessVideoFolder('user123');

      // Folders should be different due to different timestamps
      expect(folder1, isNot(equals(folder2)));
    });

    test('handles userId with dots', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user.123.test');

      // Dots should be replaced with underscores
      expect(folder, contains('liveness/user_123_test/video/'));
    });
  });

  group('Folder path sanitization edge cases', () {
    test('handles Unicode characters in userId', () {
      final folder = cloudinaryService.generateKycFolder('user123é', 'passport');

      // Unicode characters should be replaced
      expect(folder, contains('kyc/user123_/passport/'));
    });

    test('handles emoji in userId', () {
      final folder = cloudinaryService.generateKycFolder('user😀123', 'passport');

      // Emoji should be replaced
      expect(folder, contains('kyc/user'));
      expect(folder, contains('123/passport/'));
    });

    test('handles very long userId', () {
      final longUserId = 'user' * 100; // 400 characters
      final folder = cloudinaryService.generateKycFolder(longUserId, 'passport');

      // Should still generate valid path
      expect(folder, startsWith('kyc/$longUserId/passport/'));
    });

    test('handles userId with only special characters', () {
      final folder = cloudinaryService.generateKycFolder('@#\$%', 'passport');

      // All characters should be replaced
      expect(folder, contains('kyc/____/passport/'));
    });

    test('handles docType with only special characters', () {
      final folder = cloudinaryService.generateKycFolder('user123', '@#\$%');

      // All characters should be replaced
      expect(folder, contains('kyc/user123/____/'));
    });

    test('handles userId with spaces', () {
      final folder = cloudinaryService.generateKycFolder('user 123 test', 'passport');

      // Spaces should be replaced with underscores
      expect(folder, contains('kyc/user_123_test/passport/'));
    });

    test('handles docType with tabs and newlines', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'id\tcard\n');

      // Tabs and newlines should be replaced
      expect(folder, contains('kyc/user123/id_card_/'));
    });
  });

  group('Timestamp format validation', () {
    test('timestamp is valid ISO 8601 format in KYC folder', () {
      final folder = cloudinaryService.generateKycFolder('user123', 'passport');
      final timestamp = folder.split('/').last;

      // Should be parseable as DateTime
      final dateTime = DateTime.parse(timestamp);
      expect(dateTime, isNotNull);
      
      // Should be recent (within last minute)
      final now = DateTime.now();
      final difference = now.difference(dateTime).inSeconds.abs();
      expect(difference, lessThan(60));
    });

    test('timestamp is valid ISO 8601 format in liveness photo folder', () {
      final folder = cloudinaryService.generateLivenessPhotoFolder('user123');
      final timestamp = folder.split('/').last;

      // Should be parseable as DateTime
      final dateTime = DateTime.parse(timestamp);
      expect(dateTime, isNotNull);
      
      // Should be recent (within last minute)
      final now = DateTime.now();
      final difference = now.difference(dateTime).inSeconds.abs();
      expect(difference, lessThan(60));
    });

    test('timestamp is valid ISO 8601 format in liveness video folder', () {
      final folder = cloudinaryService.generateLivenessVideoFolder('user123');
      final timestamp = folder.split('/').last;

      // Should be parseable as DateTime
      final dateTime = DateTime.parse(timestamp);
      expect(dateTime, isNotNull);
      
      // Should be recent (within last minute)
      final now = DateTime.now();
      final difference = now.difference(dateTime).inSeconds.abs();
      expect(difference, lessThan(60));
    });
  });
}
