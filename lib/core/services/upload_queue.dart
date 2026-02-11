import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/queued_upload.dart';

/// Manages offline upload queue with persistence and automatic retry
///
/// This service handles queuing uploads when the device is offline,
/// persisting the queue to local storage, and automatically processing
/// queued uploads when connectivity is restored.
class UploadQueue {
  /// SharedPreferences instance for queue persistence
  final SharedPreferences _prefs;

  /// Connectivity instance for monitoring network status
  final Connectivity _connectivity;

  /// Key for storing the queue in SharedPreferences
  static const String _queueKey = 'cloudinary_upload_queue';

  /// Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Track the last known connectivity state
  bool _wasOffline = false;

  /// Constructor accepting SharedPreferences and Connectivity instances
  ///
  /// [_prefs] - SharedPreferences instance for persisting queue data
  /// [_connectivity] - Connectivity instance for monitoring network status
  UploadQueue(this._prefs, this._connectivity);

  /// Add upload to queue and persist to SharedPreferences
  ///
  /// [upload] - The QueuedUpload to add to the queue
  ///
  /// This method adds the upload to the queue and immediately persists
  /// the updated queue to SharedPreferences for durability.
  Future<void> enqueue(QueuedUpload upload) async {
    final queue = await getAll();
    queue.add(upload);
    await _saveQueue(queue);
  }

  /// Remove upload from queue by ID and update SharedPreferences
  ///
  /// [uploadId] - The unique ID of the upload to remove
  ///
  /// This method removes the upload with the specified ID from the queue
  /// and persists the updated queue to SharedPreferences.
  Future<void> dequeue(String uploadId) async {
    final queue = await getAll();
    queue.removeWhere((upload) => upload.id == uploadId);
    await _saveQueue(queue);
  }

  /// Retrieve all queued uploads from SharedPreferences
  ///
  /// Returns a list of all QueuedUpload items in the queue.
  /// Returns an empty list if no uploads are queued.
  Future<List<QueuedUpload>> getAll() async {
    final jsonString = _prefs.getString(_queueKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      // Parse the JSON string as a list
      final List<dynamic> jsonList = 
          (jsonDecode(jsonString) as List<dynamic>);
      
      return jsonList
          .map((json) => QueuedUpload.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list and clear corrupted data
      await _prefs.remove(_queueKey);
      return [];
    }
  }

  /// Get uploads with pending status
  ///
  /// Returns a list of QueuedUpload items that have status == pending.
  /// These are uploads waiting to be processed.
  Future<List<QueuedUpload>> getPending() async {
    final queue = await getAll();
    return queue.where((upload) => upload.status == QueueStatus.pending).toList();
  }

  /// Get uploads with failed status
  ///
  /// Returns a list of QueuedUpload items that have status == failed.
  /// These are uploads that failed after all retry attempts.
  Future<List<QueuedUpload>> getFailed() async {
    final queue = await getAll();
    return queue.where((upload) => upload.status == QueueStatus.failed).toList();
  }

  /// Mark upload as uploading
  ///
  /// [uploadId] - The unique ID of the upload to mark as uploading
  ///
  /// This method updates the status of the specified upload to uploading
  /// and persists the change to SharedPreferences.
  Future<void> markUploading(String uploadId) async {
    final queue = await getAll();
    final index = queue.indexWhere((upload) => upload.id == uploadId);
    
    if (index != -1) {
      queue[index] = queue[index].copyWith(status: QueueStatus.uploading);
      await _saveQueue(queue);
    }
  }

  /// Mark upload as completed
  ///
  /// [uploadId] - The unique ID of the upload to mark as completed
  ///
  /// This method updates the status of the specified upload to completed,
  /// sets the uploadedAt timestamp to the current time, and persists
  /// the changes to SharedPreferences.
  Future<void> markCompleted(String uploadId) async {
    final queue = await getAll();
    final index = queue.indexWhere((upload) => upload.id == uploadId);
    
    if (index != -1) {
      queue[index] = queue[index].copyWith(
        status: QueueStatus.completed,
        uploadedAt: DateTime.now(),
      );
      await _saveQueue(queue);
    }
  }

  /// Mark upload as failed
  ///
  /// [uploadId] - The unique ID of the upload to mark as failed
  /// [error] - The error message describing why the upload failed
  ///
  /// This method updates the status of the specified upload to failed,
  /// stores the error message, and persists the changes to SharedPreferences.
  Future<void> markFailed(String uploadId, String error) async {
    final queue = await getAll();
    final index = queue.indexWhere((upload) => upload.id == uploadId);
    
    if (index != -1) {
      queue[index] = queue[index].copyWith(
        status: QueueStatus.failed,
        errorMessage: error,
      );
      await _saveQueue(queue);
    }
  }

  /// Save queue to SharedPreferences as JSON array
  ///
  /// [queue] - The list of QueuedUpload items to persist
  ///
  /// This internal method serializes the queue to a JSON array string
  /// and saves it to SharedPreferences.
  Future<void> _saveQueue(List<QueuedUpload> queue) async {
    final jsonList = queue.map((upload) => upload.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_queueKey, jsonString);
  }

  /// Start monitoring connectivity and auto-process queue
  ///
  /// This method listens to the Connectivity stream and automatically
  /// calls processQueue() when connectivity changes from offline to online.
  ///
  /// The monitoring continues until stopMonitoring() is called.
  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        // Check if we have any online connectivity
        final isOnline = results.any((result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn);

        // If we were offline and now we're online, process the queue
        if (_wasOffline && isOnline) {
          await processQueue();
        }

        // Update the offline state
        _wasOffline = !isOnline;
      },
    );
  }

  /// Stop monitoring connectivity
  ///
  /// This method cancels the connectivity subscription and stops
  /// automatic queue processing.
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Process pending uploads in FIFO order
  ///
  /// This method retrieves all pending uploads from the queue and
  /// attempts to upload each one in first-in-first-out order.
  ///
  /// Note: This method is a placeholder that will be completed when
  /// CloudinaryService is integrated. Currently it only retrieves
  /// pending uploads but doesn't perform actual uploads.
  Future<void> processQueue() async {
    final pending = await getPending();

    // Process uploads in FIFO order (first-in-first-out)
    for (final upload in pending) {
      // Mark as uploading
      await markUploading(upload.id);

      // TODO: Integrate with CloudinaryService to perform actual upload
      // For now, this is a placeholder that will be implemented when
      // CloudinaryService is available and can be injected as a dependency
      
      // Example of what will be implemented:
      // try {
      //   final response = await _cloudinaryService.upload(upload);
      //   if (response.success) {
      //     await markCompleted(upload.id);
      //     await dequeue(upload.id);
      //   } else {
      //     await markFailed(upload.id, response.error?.message ?? 'Upload failed');
      //   }
      // } catch (e) {
      //   await markFailed(upload.id, e.toString());
      // }
    }
  }
}
