import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:et_digital_equb/core/services/upload_queue.dart';
import 'package:et_digital_equb/models/queued_upload.dart';

void main() {
  late UploadQueue uploadQueue;
  late SharedPreferences prefs;
  late Connectivity connectivity;

  setUp(() async {
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    connectivity = Connectivity();
    uploadQueue = UploadQueue(prefs, connectivity);
  });

  tearDown(() async {
    // Clear SharedPreferences after each test
    await prefs.clear();
  });

  group('UploadQueue - Persistence Methods', () {
    test('enqueue adds upload and persists to SharedPreferences', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );

      // Act
      await uploadQueue.enqueue(upload);

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].filePath, '/path/to/image.jpg');
      expect(queue[0].folder, 'kyc/user123/id_card/2024-01-15');
      expect(queue[0].fileType, FileType.image);
      expect(queue[0].status, QueueStatus.pending);

      // Verify persistence
      final jsonString = prefs.getString('cloudinary_upload_queue');
      expect(jsonString, isNotNull);
      final jsonList = jsonDecode(jsonString!) as List<dynamic>;
      expect(jsonList.length, 1);
    });

    test('dequeue removes upload and updates SharedPreferences', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);

      // Act
      await uploadQueue.dequeue('test-id-1');

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-2');

      // Verify persistence
      final jsonString = prefs.getString('cloudinary_upload_queue');
      expect(jsonString, isNotNull);
      final jsonList = jsonDecode(jsonString!) as List<dynamic>;
      expect(jsonList.length, 1);
    });

    test('getAll retrieves all uploads from SharedPreferences', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/video.mp4',
        folder: 'liveness/user123/video/2024-01-15',
        fileType: FileType.video,
        status: QueueStatus.failed,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
        errorMessage: 'Network error',
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);

      // Act
      final queue = await uploadQueue.getAll();

      // Assert
      expect(queue.length, 2);
      expect(queue[0].id, 'test-id-1');
      expect(queue[1].id, 'test-id-2');
    });

    test('getAll returns empty list when no uploads are queued', () async {
      // Act
      final queue = await uploadQueue.getAll();

      // Assert
      expect(queue, isEmpty);
    });

    test('getAll handles corrupted data gracefully', () async {
      // Arrange - Set invalid JSON in SharedPreferences
      await prefs.setString('cloudinary_upload_queue', 'invalid json {[}');

      // Act
      final queue = await uploadQueue.getAll();

      // Assert
      expect(queue, isEmpty);
      // Verify corrupted data was cleared
      expect(prefs.getString('cloudinary_upload_queue'), isNull);
    });

    test('getPending filters for pending status', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );
      final upload3 = QueuedUpload(
        id: 'test-id-3',
        filePath: '/path/to/image3.jpg',
        folder: 'kyc/user123/license/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 32),
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);
      await uploadQueue.enqueue(upload3);

      // Act
      final pending = await uploadQueue.getPending();

      // Assert
      expect(pending.length, 2);
      expect(pending[0].id, 'test-id-1');
      expect(pending[1].id, 'test-id-3');
      expect(pending.every((u) => u.status == QueueStatus.pending), isTrue);
    });

    test('getFailed filters for failed status', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.failed,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
        errorMessage: 'Network error',
      );
      final upload3 = QueuedUpload(
        id: 'test-id-3',
        filePath: '/path/to/image3.jpg',
        folder: 'kyc/user123/license/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.failed,
        queuedAt: DateTime(2024, 1, 15, 10, 32),
        errorMessage: 'Timeout',
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);
      await uploadQueue.enqueue(upload3);

      // Act
      final failed = await uploadQueue.getFailed();

      // Assert
      expect(failed.length, 2);
      expect(failed[0].id, 'test-id-2');
      expect(failed[1].id, 'test-id-3');
      expect(failed.every((u) => u.status == QueueStatus.failed), isTrue);
    });

    test('queue survives simulated app restart', () async {
      // Arrange - Add uploads to queue
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/video.mp4',
        folder: 'liveness/user123/video/2024-01-15',
        fileType: FileType.video,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);

      // Act - Simulate app restart by creating new UploadQueue instance
      final newUploadQueue = UploadQueue(prefs, connectivity);
      final queue = await newUploadQueue.getAll();

      // Assert
      expect(queue.length, 2);
      expect(queue[0].id, 'test-id-1');
      expect(queue[1].id, 'test-id-2');
    });

    test('enqueue handles metadata correctly', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        metadata: {
          'doc_type': 'id_card',
          'user_id': 'user123',
          'custom_field': 'custom_value',
        },
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );

      // Act
      await uploadQueue.enqueue(upload);

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue[0].metadata, isNotNull);
      expect(queue[0].metadata!['doc_type'], 'id_card');
      expect(queue[0].metadata!['user_id'], 'user123');
      expect(queue[0].metadata!['custom_field'], 'custom_value');
    });

    test('dequeue handles non-existent ID gracefully', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );

      await uploadQueue.enqueue(upload);

      // Act - Try to dequeue non-existent ID
      await uploadQueue.dequeue('non-existent-id');

      // Assert - Original upload should still be there
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
    });

    test('multiple enqueue operations maintain order', () async {
      // Arrange & Act
      for (int i = 1; i <= 5; i++) {
        final upload = QueuedUpload(
          id: 'test-id-$i',
          filePath: '/path/to/image$i.jpg',
          folder: 'kyc/user123/doc$i/2024-01-15',
          fileType: FileType.image,
          status: QueueStatus.pending,
          queuedAt: DateTime(2024, 1, 15, 10, 30 + i),
        );
        await uploadQueue.enqueue(upload);
      }

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(queue[i].id, 'test-id-${i + 1}');
      }
    });
  });

  group('UploadQueue - Status Management', () {
    test('markUploading updates status correctly', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      await uploadQueue.markUploading('test-id-1');

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].status, QueueStatus.uploading);
      expect(queue[0].id, 'test-id-1');

      // Verify persistence
      final jsonString = prefs.getString('cloudinary_upload_queue');
      expect(jsonString, isNotNull);
      final jsonList = jsonDecode(jsonString!) as List<dynamic>;
      expect(jsonList[0]['status'], 'QueueStatus.uploading');
    });

    test('markCompleted sets status and timestamp', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      final beforeComplete = DateTime.now();
      await uploadQueue.markCompleted('test-id-1');
      final afterComplete = DateTime.now();

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].status, QueueStatus.completed);
      expect(queue[0].uploadedAt, isNotNull);
      
      // Verify timestamp is within reasonable range
      expect(
        queue[0].uploadedAt!.isAfter(beforeComplete.subtract(Duration(seconds: 1))),
        isTrue,
      );
      expect(
        queue[0].uploadedAt!.isBefore(afterComplete.add(Duration(seconds: 1))),
        isTrue,
      );

      // Verify persistence
      final jsonString = prefs.getString('cloudinary_upload_queue');
      expect(jsonString, isNotNull);
      final jsonList = jsonDecode(jsonString!) as List<dynamic>;
      expect(jsonList[0]['status'], 'QueueStatus.completed');
      expect(jsonList[0]['uploaded_at'], isNotNull);
    });

    test('markFailed sets status and error message', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      await uploadQueue.markFailed('test-id-1', 'Network connection failed');

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].status, QueueStatus.failed);
      expect(queue[0].errorMessage, 'Network connection failed');

      // Verify persistence
      final jsonString = prefs.getString('cloudinary_upload_queue');
      expect(jsonString, isNotNull);
      final jsonList = jsonDecode(jsonString!) as List<dynamic>;
      expect(jsonList[0]['status'], 'QueueStatus.failed');
      expect(jsonList[0]['error_message'], 'Network connection failed');
    });

    test('markUploading handles non-existent ID gracefully', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      await uploadQueue.markUploading('non-existent-id');

      // Assert - Original upload should remain unchanged
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].status, QueueStatus.pending);
    });

    test('markCompleted handles non-existent ID gracefully', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      await uploadQueue.markCompleted('non-existent-id');

      // Assert - Original upload should remain unchanged
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].status, QueueStatus.uploading);
      expect(queue[0].uploadedAt, isNull);
    });

    test('markFailed handles non-existent ID gracefully', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);

      // Act
      await uploadQueue.markFailed('non-existent-id', 'Some error');

      // Assert - Original upload should remain unchanged
      final queue = await uploadQueue.getAll();
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].status, QueueStatus.uploading);
      expect(queue[0].errorMessage, isNull);
    });

    test('status updates work with multiple uploads in queue', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );
      final upload3 = QueuedUpload(
        id: 'test-id-3',
        filePath: '/path/to/image3.jpg',
        folder: 'kyc/user123/license/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 32),
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);
      await uploadQueue.enqueue(upload3);

      // Act - Update different uploads to different statuses
      await uploadQueue.markUploading('test-id-1');
      await uploadQueue.markCompleted('test-id-2');
      await uploadQueue.markFailed('test-id-3', 'Upload failed');

      // Assert
      final queue = await uploadQueue.getAll();
      expect(queue.length, 3);
      
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].status, QueueStatus.uploading);
      
      expect(queue[1].id, 'test-id-2');
      expect(queue[1].status, QueueStatus.completed);
      expect(queue[1].uploadedAt, isNotNull);
      
      expect(queue[2].id, 'test-id-3');
      expect(queue[2].status, QueueStatus.failed);
      expect(queue[2].errorMessage, 'Upload failed');
    });

    test('status transitions persist across app restart', () async {
      // Arrange
      final upload = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      await uploadQueue.enqueue(upload);
      await uploadQueue.markUploading('test-id-1');

      // Act - Simulate app restart
      final newUploadQueue = UploadQueue(prefs, connectivity);
      final queue = await newUploadQueue.getAll();

      // Assert
      expect(queue.length, 1);
      expect(queue[0].id, 'test-id-1');
      expect(queue[0].status, QueueStatus.uploading);
    });
  });

  group('UploadQueue - Connectivity Monitoring', () {
    test('startMonitoring initializes connectivity subscription', () async {
      // Skip this test as it requires platform channels
      // The functionality will be tested in integration tests
    }, skip: 'Requires platform channels - tested in integration tests');

    test('stopMonitoring cancels connectivity subscription', () async {
      // Skip this test as it requires platform channels
      // The functionality will be tested in integration tests
    }, skip: 'Requires platform channels - tested in integration tests');

    test('processQueue retrieves pending uploads', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );
      final upload3 = QueuedUpload(
        id: 'test-id-3',
        filePath: '/path/to/image3.jpg',
        folder: 'kyc/user123/license/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.completed,
        queuedAt: DateTime(2024, 1, 15, 10, 32),
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);
      await uploadQueue.enqueue(upload3);

      // Act
      await uploadQueue.processQueue();

      // Assert - Verify pending uploads were marked as uploading
      final queue = await uploadQueue.getAll();
      
      // Find the uploads by ID
      final processedUpload1 = queue.firstWhere((u) => u.id == 'test-id-1');
      final processedUpload2 = queue.firstWhere((u) => u.id == 'test-id-2');
      final processedUpload3 = queue.firstWhere((u) => u.id == 'test-id-3');

      // Pending uploads should be marked as uploading
      expect(processedUpload1.status, QueueStatus.uploading);
      expect(processedUpload2.status, QueueStatus.uploading);
      
      // Completed upload should remain completed
      expect(processedUpload3.status, QueueStatus.completed);
    });

    test('processQueue processes uploads in FIFO order', () async {
      // Arrange
      final uploadIds = <String>[];
      
      for (int i = 1; i <= 5; i++) {
        final upload = QueuedUpload(
          id: 'test-id-$i',
          filePath: '/path/to/image$i.jpg',
          folder: 'kyc/user123/doc$i/2024-01-15',
          fileType: FileType.image,
          status: QueueStatus.pending,
          queuedAt: DateTime(2024, 1, 15, 10, 30 + i),
        );
        await uploadQueue.enqueue(upload);
        uploadIds.add(upload.id);
      }

      // Act
      await uploadQueue.processQueue();

      // Assert - Verify all uploads were marked as uploading in order
      final queue = await uploadQueue.getAll();
      expect(queue.length, 5);
      
      for (int i = 0; i < 5; i++) {
        expect(queue[i].id, 'test-id-${i + 1}');
        expect(queue[i].status, QueueStatus.uploading);
      }
    });

    test('processQueue handles empty queue gracefully', () async {
      // Act & Assert - Should not throw
      await uploadQueue.processQueue();

      // Verify queue is still empty
      final queue = await uploadQueue.getAll();
      expect(queue, isEmpty);
    });

    test('processQueue only processes pending uploads', () async {
      // Arrange
      final upload1 = QueuedUpload(
        id: 'test-id-1',
        filePath: '/path/to/image1.jpg',
        folder: 'kyc/user123/id_card/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.pending,
        queuedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final upload2 = QueuedUpload(
        id: 'test-id-2',
        filePath: '/path/to/image2.jpg',
        folder: 'kyc/user123/passport/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.uploading,
        queuedAt: DateTime(2024, 1, 15, 10, 31),
      );
      final upload3 = QueuedUpload(
        id: 'test-id-3',
        filePath: '/path/to/image3.jpg',
        folder: 'kyc/user123/license/2024-01-15',
        fileType: FileType.image,
        status: QueueStatus.failed,
        queuedAt: DateTime(2024, 1, 15, 10, 32),
        errorMessage: 'Previous error',
      );

      await uploadQueue.enqueue(upload1);
      await uploadQueue.enqueue(upload2);
      await uploadQueue.enqueue(upload3);

      // Act
      await uploadQueue.processQueue();

      // Assert
      final queue = await uploadQueue.getAll();
      
      // Only pending upload should be marked as uploading
      final processedUpload1 = queue.firstWhere((u) => u.id == 'test-id-1');
      expect(processedUpload1.status, QueueStatus.uploading);
      
      // Already uploading should remain uploading
      final processedUpload2 = queue.firstWhere((u) => u.id == 'test-id-2');
      expect(processedUpload2.status, QueueStatus.uploading);
      
      // Failed should remain failed
      final processedUpload3 = queue.firstWhere((u) => u.id == 'test-id-3');
      expect(processedUpload3.status, QueueStatus.failed);
      expect(processedUpload3.errorMessage, 'Previous error');
    });

    test('multiple startMonitoring calls do not cause issues', () async {
      // Skip this test as it requires platform channels
      // The functionality will be tested in integration tests
    }, skip: 'Requires platform channels - tested in integration tests');

    test('stopMonitoring can be called without startMonitoring', () async {
      // Skip this test as it requires platform channels
      // The functionality will be tested in integration tests
    }, skip: 'Requires platform channels - tested in integration tests');
  });
}
