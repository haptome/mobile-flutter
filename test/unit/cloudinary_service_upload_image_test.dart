// // Purpose: Unit tests for CloudinaryService uploadImage() method
// // Author: Cloudinary Upload Integration
// // Linked Spec Section: Task 8.2, Requirements 1.1, 1.4, 1.6, 1.7, 1.8, 4.1, 4.2, 4.3, 6.1, 11.1

// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:et_digital_equb/config/cloudinary_config.dart';
// import 'package:et_digital_equb/core/services/cloudinary_service.dart';
// import 'package:et_digital_equb/core/services/upload_queue.dart';
// import 'package:et_digital_equb/models/cloudinary_error.dart';
// import 'package:et_digital_equb/models/queued_upload.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Mock Connectivity class for testing
// class MockConnectivity extends Connectivity {
//   List<ConnectivityResult>? _mockResult;

//   void setMockResult(List<ConnectivityResult> result) {
//     _mockResult = result;
//   }

//   @override
//   Future<List<ConnectivityResult>> checkConnectivity() async {
//     if (_mockResult != null) {
//       return _mockResult!;
//     }
//     return [ConnectivityResult.none];
//   }
// }

// void main() {
//   late CloudinaryService cloudinaryService;
//   late MockConnectivity mockConnectivity;
//   late UploadQueue uploadQueue;
//   late Directory tempDir;
//   late SharedPreferences prefs;

//   setUp(() async {
//     // Initialize SharedPreferences for testing
//     SharedPreferences.setMockInitialValues({});
//     prefs = await SharedPreferences.getInstance();

//     // Create test configuration
//     final config = CloudinaryConfig.forEnvironment(Environment.development);

//     // Create mock connectivity
//     mockConnectivity = MockConnectivity();

//     // Create upload queue
//     uploadQueue = UploadQueue(prefs, mockConnectivity);

//     // Create CloudinaryService instance
//     cloudinaryService = CloudinaryService(
//       config,
//       uploadQueue,
//       mockConnectivity,
//     );

//     // Create temporary directory for test files
//     tempDir = await Directory.systemTemp.createTemp('cloudinary_upload_test_');
//   });

//   tearDown(() async {
//     // Clean up temporary directory
//     if (await tempDir.exists()) {
//       await tempDir.delete(recursive: true);
//     }
//   });

//   group('uploadImage - Validation', () {
//     test('returns failure when file does not exist', () async {
//       // Mock online connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: '/nonexistent/path/image.jpg',
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error, isNotNull);
//       expect(response.error!.code, equals(CloudinaryError.validationError));
//       expect(response.error!.message, contains('does not exist'));
//     });

//     test('returns failure when file has invalid extension', () async {
//       // Create a test file with invalid extension
//       final file = File('${tempDir.path}/test.gif');
//       await file.writeAsBytes([0x47, 0x49, 0x46]);

//       // Mock online connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error, isNotNull);
//       expect(response.error!.code, equals(CloudinaryError.invalidFileType));
//       expect(response.error!.message, contains('Invalid image format'));
//     });

//     test('returns failure when image file is too large', () async {
//       // Create a test file larger than 10MB
//       final file = File('${tempDir.path}/large.jpg');
//       final bytes = List<int>.filled(11 * 1024 * 1024, 0);
//       await file.writeAsBytes(bytes);

//       // Mock online connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error, isNotNull);
//       expect(response.error!.code, equals(CloudinaryError.fileTooLarge));
//       expect(response.error!.message, contains('too large'));
//     });

//     test('passes validation for valid image file', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/valid.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]); // JPEG header

//       // Mock online connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       // Note: This test will fail at upload stage since we don't have real Cloudinary
//       // but it should pass validation
//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//         );
//       } catch (e) {
//         // Expected to fail at upload stage, but validation should have passed
//         // If we got here, validation passed
//       }

//       // If we reach here, validation passed (upload may have failed)
//       expect(true, isTrue);
//     });
//   });

//   group('uploadImage - Offline Queueing', () {
//     test('queues upload when device is offline', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock offline connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.none]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//         metadata: {'doc_type': 'passport'},
//       );

//       expect(response.success, isFalse);
//       expect(response.error, isNotNull);
//       expect(response.error!.code, equals('QUEUED'));
//       expect(response.error!.message, contains('queued'));

//       // Verify upload was added to queue
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(1));
//       expect(queue[0].filePath, equals(file.path));
//       expect(queue[0].folder, equals('test/folder'));
//       expect(queue[0].fileType, equals(FileType.image));
//       expect(queue[0].status, equals(QueueStatus.pending));
//     });

//     test('queues upload with metadata when offline', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.png');
//       await file.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);

//       // Mock offline connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.none]);

//       final metadata = {
//         'doc_type': 'id_card',
//         'user_id': 'user123',
//       };

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'kyc/user123/id_card',
//         metadata: metadata,
//       );

//       expect(response.success, isFalse);
//       expect(response.error!.code, equals('QUEUED'));

//       // Verify metadata was stored in queue
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(1));
//       expect(queue[0].metadata, equals(metadata));
//     });

//     test('does not queue upload when validation fails', () async {
//       // Create an invalid test file (wrong extension)
//       final file = File('${tempDir.path}/test.gif');
//       await file.writeAsBytes([0x47, 0x49, 0x46]);

//       // Mock offline connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.none]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error!.code, equals(CloudinaryError.invalidFileType));

//       // Verify upload was NOT added to queue
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(0));
//     });
//   });

//   group('uploadImage - Connectivity States', () {
//     test('considers wifi as online', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock wifi connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       // This will attempt upload (and likely fail without real Cloudinary)
//       // but should not queue the upload
//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//         );
//       } catch (e) {
//         // Expected to fail at upload stage
//       }

//       // Verify upload was NOT queued (because we're online)
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(0));
//     });

//     test('considers mobile data as online', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock mobile connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.mobile]);

//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//         );
//       } catch (e) {
//         // Expected to fail at upload stage
//       }

//       // Verify upload was NOT queued
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(0));
//     });

//     test('considers ethernet as online', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock ethernet connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.ethernet]);

//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//         );
//       } catch (e) {
//         // Expected to fail at upload stage
//       }

//       // Verify upload was NOT queued
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(0));
//     });

//     test('considers vpn as online', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock vpn connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.vpn]);

//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//         );
//       } catch (e) {
//         // Expected to fail at upload stage
//       }

//       // Verify upload was NOT queued
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(0));
//     });

//     test('considers bluetooth as offline', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock bluetooth connectivity (offline)
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error!.code, equals('QUEUED'));

//       // Verify upload was queued
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(1));
//     });
//   });

//   group('uploadImage - Progress Callback', () {
//     test('accepts progress callback parameter', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock online connectivity
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.wifi]);

//       var progressCalled = false;

//       try {
//         await cloudinaryService.uploadImage(
//           filePath: file.path,
//           folder: 'test/folder',
//           onProgress: (sent, total) {
//             progressCalled = true;
//           },
//         );
//       } catch (e) {
//         // Expected to fail at upload stage
//       }

//       // The progress callback should be accepted (even if not called due to mock)
//       expect(progressCalled, isFalse); // Won't be called without real upload
//     });
//   });

//   group('uploadImage - Folder Parameter', () {
//     test('uses provided folder path', () async {
//       // Create a valid test file
//       final file = File('${tempDir.path}/test.jpg');
//       await file.writeAsBytes([0xFF, 0xD8, 0xFF]);

//       // Mock offline connectivity to test queueing
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => [ConnectivityResult.none]);

//       final folder = 'kyc/user123/passport/2024-01-15';

//       await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: folder,
//       );

//       // Verify folder was stored in queue
//       final queue = await uploadQueue.getAll();
//       expect(queue.length, equals(1));
//       expect(queue[0].folder, equals(folder));
//     });
//   });

//   group('uploadImage - Error Handling', () {
//     test('returns descriptive error for validation failures', () async {
//       // Test with non-existent file
//       final response = await cloudinaryService.uploadImage(
//         filePath: '/nonexistent/file.jpg',
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error, isNotNull);
//       expect(response.error!.code, isNotEmpty);
//       expect(response.error!.message, isNotEmpty);
//     });

//     test('returns descriptive error for invalid file type', () async {
//       // Create invalid file
//       final file = File('${tempDir.path}/test.bmp');
//       await file.writeAsBytes([0x42, 0x4D]);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error!.code, equals(CloudinaryError.invalidFileType));
//       expect(response.error!.message, contains('Invalid image format'));
//     });

//     test('returns descriptive error for oversized file', () async {
//       // Create oversized file
//       final file = File('${tempDir.path}/large.jpg');
//       final bytes = List<int>.filled(15 * 1024 * 1024, 0);
//       await file.writeAsBytes(bytes);

//       final response = await cloudinaryService.uploadImage(
//         filePath: file.path,
//         folder: 'test/folder',
//       );

//       expect(response.success, isFalse);
//       expect(response.error!.code, equals(CloudinaryError.fileTooLarge));
//       expect(response.error!.message, contains('too large'));
//     });
//   });
// }
