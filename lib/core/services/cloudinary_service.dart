// Purpose: Core service for direct uploads to Cloudinary
// Author: Cloudinary Upload Integration
// Linked Spec Section: Requirements 1.1, 1.2, 6.1, 6.3

import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_sdk/cloudinary_sdk.dart' as cloudinary_sdk;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../../config/cloudinary_config.dart';
import '../../config/file_validation.dart';
import '../../models/cloudinary_error.dart';
import '../../models/cloudinary_response.dart' as app_models;
import '../../models/queued_upload.dart';
import '../../models/validation_result.dart';
import 'upload_queue.dart';

/// Core service for handling direct uploads to Cloudinary
///
/// This service manages file uploads to Cloudinary with features including:
/// - Direct client-to-Cloudinary uploads
/// - Progress tracking with callbacks
/// - Automatic retry logic with exponential backoff
/// - File validation (type and size)
/// - Offline upload queuing
/// - Folder path generation for organized storage
///
/// Example usage:
/// ```dart
/// final response = await CloudinaryService.to.uploadImage(
///   filePath: '/path/to/image.jpg',
///   folder: 'kyc/user123/id_card/2024-01-15',
///   onProgress: (sent, total) {
///     print('Progress: ${(sent / total * 100).toStringAsFixed(1)}%');
///   },
/// );
///
/// if (response.success) {
///   print('Uploaded: ${response.secureUrl}');
/// } else {
///   print('Error: ${response.error?.userMessage}');
/// }
/// ```
class CloudinaryService extends GetxService {
  /// GetX service locator for accessing CloudinaryService instance
  static CloudinaryService get to => Get.find();

  /// Cloudinary configuration with credentials and settings
  final CloudinaryConfig _config;

  /// Upload queue for managing offline uploads
  final UploadQueue _uploadQueue;

  /// Connectivity instance for checking network status
  final Connectivity _connectivity;

  /// Cloudinary SDK instance for performing uploads
  cloudinary_sdk.Cloudinary? _cloudinary;

  /// Constructor accepting dependencies
  ///
  /// [_config] - Cloudinary configuration with cloud name and upload preset
  /// [_uploadQueue] - Queue for managing offline uploads
  /// [_connectivity] - Connectivity instance for network status monitoring
  ///
  /// Initializes the Cloudinary SDK with the provided configuration.
  CloudinaryService(
    this._config,
    this._uploadQueue,
    this._connectivity,
  ) {
    // Initialize Cloudinary SDK with basic configuration for client-side uploads
    // Using .basic() constructor which is recommended for client-side apps
    // where API secret must not be exposed
    _cloudinary = cloudinary_sdk.Cloudinary.basic(
      cloudName: _config.cloudName,
    );
  }

  /// Get Cloudinary SDK instance
  cloudinary_sdk.Cloudinary get cloudinary => _cloudinary!;

  /// Upload an image to Cloudinary
  ///
  /// [filePath] - Local file path to upload
  /// [folder] - Cloudinary folder path (e.g., "kyc/user123/id_card/2024-01-15")
  /// [metadata] - Optional metadata tags
  /// [onProgress] - Progress callback (sent bytes, total bytes)
  /// [fileBytes] - Optional pre-loaded file bytes (for web compatibility)
  ///
  /// Returns [CloudinaryResponse] with secure_url and public_id on success,
  /// or error information on failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await CloudinaryService.to.uploadImage(
  ///   filePath: '/path/to/photo.jpg',
  ///   folder: 'kyc/user123/passport/2024-01-15',
  ///   metadata: {'doc_type': 'passport'},
  ///   onProgress: (sent, total) {
  ///     print('Upload progress: ${(sent / total * 100).toInt()}%');
  ///   },
  /// );
  /// ```
  Future<app_models.CloudinaryResponse> uploadImage({
    required String filePath,
    required String folder,
    Map<String, dynamic>? metadata,
    void Function(int sent, int total)? onProgress,
    Uint8List? fileBytes,
  }) async {
    // Step 1: Validate file (skip file existence check if bytes provided)
    if (fileBytes == null) {
      final validation = validateFile(filePath, FileType.image);
      if (!validation.isValid) {
        // Validation failed, return failure response with validation error
        return app_models.CloudinaryResponse.failure(
          error: CloudinaryError(
            code: validation.errorCode!,
            message: validation.errorMessage!,
          ),
        );
      }
    }

    // Step 2: Check network connectivity
    final isOnline = await _isOnline();
    
    if (!isOnline) {
      // Device is offline, queue the upload for later
      final queuedUpload = QueuedUpload(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: filePath,
        folder: folder,
        fileType: FileType.image,
        metadata: metadata,
        status: QueueStatus.pending,
        queuedAt: DateTime.now(),
      );
      
      await _uploadQueue.enqueue(queuedUpload);
      
      // Return failure response with QUEUED code
      return app_models.CloudinaryResponse.failure(
        error: CloudinaryError(
          code: 'QUEUED',
          message: 'Upload queued for when connectivity is restored',
        ),
      );
    }

    // Step 3: Device is online, perform upload with retry logic
    return await _uploadWithRetry(
      filePath: filePath,
      folder: folder,
      fileType: FileType.image,
      onProgress: onProgress,
      fileBytes: fileBytes,
    );
  }

  /// Upload a video to Cloudinary
  ///
  /// [filePath] - Local file path to upload
  /// [folder] - Cloudinary folder path
  /// [onProgress] - Progress callback (sent bytes, total bytes)
  ///
  /// Returns [CloudinaryResponse] with secure_url and public_id on success,
  /// or error information on failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await CloudinaryService.to.uploadVideo(
  ///   filePath: '/path/to/video.mp4',
  ///   folder: 'liveness/user123/video/2024-01-15',
  ///   onProgress: (sent, total) {
  ///     print('Upload progress: ${(sent / total * 100).toInt()}%');
  ///   },
  /// );
  /// ```
  Future<app_models.CloudinaryResponse> uploadVideo({
    required String filePath,
    required String folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    // Validate file
    final validation = validateFile(filePath, FileType.video);
    if (!validation.isValid) {
      return app_models.CloudinaryResponse.failure(
        error: CloudinaryError(
          code: validation.errorCode!,
          message: validation.errorMessage!,
        ),
      );
    }

    // Check connectivity
    final isOnline = await _isOnline();
    if (!isOnline) {
      // Queue upload for later
      final queuedUpload = QueuedUpload(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: filePath,
        folder: folder,
        fileType: FileType.video,
        status: QueueStatus.pending,
        queuedAt: DateTime.now(),
      );
      await _uploadQueue.enqueue(queuedUpload);
      
      return app_models.CloudinaryResponse.failure(
        error: CloudinaryError(
          code: 'QUEUED',
          message: 'Upload queued for when connectivity is restored',
        ),
      );
    }

    // Upload with retry
    return await _uploadWithRetry(
      filePath: filePath,
      folder: folder,
      fileType: FileType.video,
      onProgress: onProgress,
    );
  }

  /// Validate file before upload
  ///
  /// Checks:
  /// - File exists at the specified path
  /// - File extension is valid for the file type
  /// - File size is within limits (10MB for images, 50MB for videos)
  ///
  /// Returns [ValidationResult] with success flag and error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// final result = CloudinaryService.to.validateFile(
  ///   '/path/to/image.jpg',
  ///   FileType.image,
  /// );
  ///
  /// if (!result.isValid) {
  ///   print('Validation failed: ${result.errorMessage}');
  /// }
  /// ```
  ValidationResult validateFile(String filePath, FileType fileType) {
    // Check if file exists at filePath
    final file = File(filePath);
    if (!file.existsSync()) {
      return ValidationResult.invalid(
        message: 'File does not exist at path: $filePath',
        code: CloudinaryError.validationError,
      );
    }

    // Extract file extension and convert to lowercase
    final fileName = filePath.split('/').last;
    final extensionIndex = fileName.lastIndexOf('.');
    
    if (extensionIndex == -1 || extensionIndex == fileName.length - 1) {
      return ValidationResult.invalid(
        message: 'File has no extension',
        code: CloudinaryError.invalidFileType,
      );
    }
    
    final extension = fileName.substring(extensionIndex + 1).toLowerCase();

    // Validate file format based on file type
    if (fileType == FileType.image) {
      if (!FileValidation.supportedImageFormats.contains(extension)) {
        return ValidationResult.invalid(
          message:
              'Invalid image format. Supported formats: ${FileValidation.supportedImageFormats.join(", ")}',
          code: CloudinaryError.invalidFileType,
        );
      }
    } else if (fileType == FileType.video) {
      if (!FileValidation.supportedVideoFormats.contains(extension)) {
        return ValidationResult.invalid(
          message:
              'Invalid video format. Supported formats: ${FileValidation.supportedVideoFormats.join(", ")}',
          code: CloudinaryError.invalidFileType,
        );
      }
    }

    // Check file size
    final fileSize = file.lengthSync();
    
    if (fileType == FileType.image) {
      if (fileSize > FileValidation.maxImageSizeBytes) {
        return ValidationResult.invalid(
          message:
              'Image file is too large. Maximum size is ${FileValidation.maxImageSizeBytes ~/ (1024 * 1024)}MB',
          code: CloudinaryError.fileTooLarge,
        );
      }
    } else if (fileType == FileType.video) {
      if (fileSize > FileValidation.maxVideoSizeBytes) {
        return ValidationResult.invalid(
          message:
              'Video file is too large. Maximum size is ${FileValidation.maxVideoSizeBytes ~/ (1024 * 1024)}MB',
          code: CloudinaryError.fileTooLarge,
        );
      }
    }

    // All checks passed
    return ValidationResult.valid();
  }

  /// Generate folder path for KYC document
  ///
  /// Format: "kyc/{userId}/{docType}/{timestamp}"
  ///
  /// [userId] - User's unique identifier
  /// [docType] - Document type (e.g., 'passport', 'id_card', 'drivers_license')
  ///
  /// Returns sanitized folder path with ISO 8601 timestamp.
  ///
  /// Example:
  /// ```dart
  /// final folder = CloudinaryService.to.generateKycFolder(
  ///   'user_123',
  ///   'passport',
  /// );
  /// // Returns: "kyc/user_123/passport/2024-01-15T10:30:00.000Z"
  /// ```
  String generateKycFolder(String userId, String docType) {
    final sanitizedUserId = _sanitizeFolderName(userId);
    final sanitizedDocType = _sanitizeFolderName(docType);
    final timestamp = DateTime.now().toIso8601String();
    return 'kyc/$sanitizedUserId/$sanitizedDocType/$timestamp';
  }

  /// Generate folder path for liveness photo
  ///
  /// Format: "liveness/{userId}/photo/{timestamp}"
  ///
  /// [userId] - User's unique identifier
  ///
  /// Returns sanitized folder path with ISO 8601 timestamp.
  ///
  /// Example:
  /// ```dart
  /// final folder = CloudinaryService.to.generateLivenessPhotoFolder('user_123');
  /// // Returns: "liveness/user_123/photo/2024-01-15T10:30:00.000Z"
  /// ```
  String generateLivenessPhotoFolder(String userId) {
    final sanitizedUserId = _sanitizeFolderName(userId);
    final timestamp = DateTime.now().toIso8601String();
    return 'liveness/$sanitizedUserId/photo/$timestamp';
  }

  /// Generate folder path for liveness video
  ///
  /// Format: "liveness/{userId}/video/{timestamp}"
  ///
  /// [userId] - User's unique identifier
  ///
  /// Returns sanitized folder path with ISO 8601 timestamp.
  ///
  /// Example:
  /// ```dart
  /// final folder = CloudinaryService.to.generateLivenessVideoFolder('user_123');
  /// // Returns: "liveness/user_123/video/2024-01-15T10:30:00.000Z"
  /// ```
  String generateLivenessVideoFolder(String userId) {
    final sanitizedUserId = _sanitizeFolderName(userId);
    final timestamp = DateTime.now().toIso8601String();
    return 'liveness/$sanitizedUserId/video/$timestamp';
  }

  /// Sanitize folder name by replacing non-alphanumeric characters
  /// (except hyphen and underscore) with underscore
  ///
  /// [name] - The folder name component to sanitize
  ///
  /// Returns sanitized string containing only alphanumeric characters,
  /// hyphens, and underscores.
  ///
  /// Example:
  /// ```dart
  /// _sanitizeFolderName('user@123!'); // Returns: 'user_123_'
  /// _sanitizeFolderName('user-name_123'); // Returns: 'user-name_123'
  /// ```
  String _sanitizeFolderName(String name) {
    // Replace all non-alphanumeric characters (except hyphen and underscore) with underscore
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '_');
  }

  /// Get current upload queue status
  ///
  /// Returns a list of all queued uploads (pending, uploading, completed, failed).
  ///
  /// Example:
  /// ```dart
  /// final queue = await CloudinaryService.to.getQueueStatus();
  /// print('Pending uploads: ${queue.where((u) => u.status == QueueStatus.pending).length}');
  /// ```
  Future<List<QueuedUpload>> getQueueStatus() async {
    return await _uploadQueue.getAll();
  }

  /// Manually retry failed uploads
  ///
  /// Retrieves all failed uploads from the queue and attempts to upload them again.
  ///
  /// Example:
  /// ```dart
  /// await CloudinaryService.to.retryFailedUploads();
  /// ```
  Future<void> retryFailedUploads() async {
    final failed = await _uploadQueue.getFailed();
    
    for (final upload in failed) {
      // Mark as uploading
      await _uploadQueue.markUploading(upload.id);
      
      try {
        // Attempt upload
        final response = await _uploadWithRetry(
          filePath: upload.filePath,
          folder: upload.folder,
          fileType: upload.fileType,
        );
        
        if (response.success) {
          // Upload succeeded, mark as completed and remove from queue
          await _uploadQueue.markCompleted(upload.id);
          await _uploadQueue.dequeue(upload.id);
        } else {
          // Upload failed, mark as failed with error
          await _uploadQueue.markFailed(
            upload.id,
            response.error?.message ?? 'Upload failed',
          );
        }
      } catch (e) {
        // Exception occurred, mark as failed
        await _uploadQueue.markFailed(upload.id, e.toString());
      }
    }
  }

  /// Check if an error is transient and should be retried
  ///
  /// Transient errors are temporary issues that may resolve on retry:
  /// - NETWORK_ERROR: Network connectivity issues
  /// - TIMEOUT_ERROR: Request timeout
  ///
  /// Non-transient errors should not be retried:
  /// - AUTH_ERROR: Authentication/authorization failures
  /// - VALIDATION_ERROR: Invalid file or parameters
  /// - FILE_TOO_LARGE: File exceeds size limits
  /// - INVALID_FILE_TYPE: Unsupported file format
  /// - QUOTA_EXCEEDED: Cloudinary quota exceeded
  ///
  /// [error] - The CloudinaryError to check
  ///
  /// Returns true if the error is transient and should be retried,
  /// false otherwise.
  bool _isTransientError(CloudinaryError error) {
    return error.code == CloudinaryError.networkError ||
        error.code == CloudinaryError.timeoutError;
  }

  /// Check if device has network connectivity
  ///
  /// Uses Connectivity plugin to check current connectivity status.
  /// Returns true for active network connections (wifi, mobile, ethernet, vpn).
  /// Returns false for no connection (none) or bluetooth-only connections.
  ///
  /// Connectivity types considered online:
  /// - wifi: WiFi connection
  /// - mobile: Mobile data connection
  /// - ethernet: Wired ethernet connection
  /// - vpn: VPN connection
  ///
  /// Connectivity types considered offline:
  /// - none: No network connection
  /// - bluetooth: Bluetooth connection (not suitable for internet)
  ///
  /// Returns true if device has an active internet connection, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (await _isOnline()) {
  ///   // Proceed with upload
  /// } else {
  ///   // Queue upload for later
  /// }
  /// ```
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    // Check if connectivity status indicates an active internet connection
    // Return true for wifi, mobile, ethernet, or vpn
    // Return false for none or bluetooth
    // Note: checkConnectivity() returns List<ConnectivityResult> in newer versions
    return connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.vpn);
  }

  /// Upload with automatic retry logic and exponential backoff
  ///
  /// Attempts to upload a file with automatic retries for transient errors.
  /// Uses exponential backoff delays: 1s, 2s, 4s between retry attempts.
  ///
  /// Retry behavior:
  /// - Transient errors (network, timeout): Retry up to maxRetries times
  /// - Non-transient errors (auth, validation): Return immediately without retry
  /// - Successful upload: Return immediately without further attempts
  ///
  /// [filePath] - Local file path to upload
  /// [folder] - Cloudinary folder path
  /// [fileType] - Type of file (image or video)
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  /// [onProgress] - Optional progress callback (sent bytes, total bytes)
  ///
  /// Returns [CloudinaryResponse] with upload result or final error after
  /// all retry attempts are exhausted.
  ///
  /// Example:
  /// ```dart
  /// final response = await _uploadWithRetry(
  ///   filePath: '/path/to/image.jpg',
  ///   folder: 'kyc/user123/passport/2024-01-15',
  ///   fileType: FileType.image,
  ///   maxRetries: 3,
  ///   onProgress: (sent, total) => print('Progress: $sent/$total'),
  /// );
  /// ```
  Future<app_models.CloudinaryResponse> _uploadWithRetry({
    required String filePath,
    required String folder,
    required FileType fileType,
    int maxRetries = 3,
    void Function(int, int)? onProgress,
    Uint8List? fileBytes,
  }) async {
    int attempt = 0;
    CloudinaryError? lastError;

    while (attempt < maxRetries) {
      try {
        // Attempt upload using _performUpload() helper
        final response = await _performUpload(
          filePath: filePath,
          folder: folder,
          fileType: fileType,
          onProgress: onProgress,
          fileBytes: fileBytes,
        );

        // Upload succeeded, return immediately
        return response;
      } catch (e) {
        // Map exception to CloudinaryError
        lastError = _mapError(e);

        // Check if error is transient
        if (!_isTransientError(lastError)) {
          // Non-transient error, return failure immediately (no retry)
          return app_models.CloudinaryResponse.failure(error: lastError);
        }

        // Increment attempt counter
        attempt++;

        // If not last attempt, wait before retry using exponential backoff
        if (attempt < maxRetries) {
          final delayMs = FileValidation.retryDelaysMs[attempt - 1];
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    // All retry attempts exhausted, return failure with last error
    return app_models.CloudinaryResponse.failure(error: lastError!);
  }

  /// Perform the actual upload to Cloudinary
  ///
  /// This is a helper method that handles the actual Cloudinary SDK upload
  /// with progress tracking and transformation parameters.
  ///
  /// [filePath] - Local file path to upload
  /// [folder] - Cloudinary folder path
  /// [fileType] - Type of file (image or video)
  /// [onProgress] - Optional progress callback (sent bytes, total bytes)
  /// [fileBytes] - Optional pre-loaded file bytes (for web compatibility)
  ///
  /// Returns [CloudinaryResponse] with upload result.
  /// Throws exceptions that will be caught and mapped by _uploadWithRetry().
  Future<app_models.CloudinaryResponse> _performUpload({
    required String filePath,
    required String folder,
    required FileType fileType,
    void Function(int, int)? onProgress,
    Uint8List? fileBytes,
  }) async {
    // Prepare transformation string based on file type
    String? transformation;
    
    if (fileType == FileType.image) {
      // For images: auto quality, auto format, max dimensions 2048x2048, limit crop mode
      transformation = 'q_auto,f_auto,w_${FileValidation.maxImageWidth},h_${FileValidation.maxImageHeight},c_limit';
    } else if (fileType == FileType.video) {
      // For videos: auto quality, auto format for video compression
      transformation = 'q_auto,f_auto';
    }

    // Create optional parameters map
    final optParams = <String, dynamic>{
      'use_filename': false,
      'unique_filename': true,
    };

    // Add transformation if specified
    if (transformation != null) {
      optParams['transformation'] = transformation;
    }

    // Read file bytes if not provided
    late final Uint8List bytes;
    
    if (fileBytes != null) {
      // Use provided bytes (for web compatibility)
      bytes = fileBytes;
    } else if (kIsWeb) {
      // On web without pre-loaded bytes, we can't proceed
      throw UnsupportedError(
        'File upload on web requires pre-loaded bytes. Please use XFile.readAsBytes() before calling uploadImage.'
      );
    } else {
      // On mobile platforms, use File to read bytes
      final file = File(filePath);
      bytes = await file.readAsBytes();
    }

    // Create the upload resource
    final uploadResource = cloudinary_sdk.CloudinaryUploadResource(
      uploadPreset: _config.uploadPreset,
      filePath: filePath,
      fileBytes: bytes,
      resourceType: fileType == FileType.image 
          ? cloudinary_sdk.CloudinaryResourceType.image 
          : cloudinary_sdk.CloudinaryResourceType.video,
      folder: folder,
      fileName: filePath.split('/').last,
      progressCallback: onProgress,
      optParams: optParams,
    );

    // Perform the unsigned upload using Cloudinary SDK
    final response = await _cloudinary!.unsignedUploadResource(uploadResource);

    // Check if upload was successful
    if (response.isSuccessful && response.secureUrl != null) {
      // Parse the successful response
      return app_models.CloudinaryResponse.success(
        secureUrl: response.secureUrl!,
        publicId: response.publicId ?? '',
        resourceType: fileType == FileType.image ? 'image' : 'video',
        format: response.format ?? '',
        bytes: response.bytes ?? 0,
      );
    } else {
      // Upload failed, throw an exception that will be caught by _uploadWithRetry
      throw Exception(response.error ?? 'Upload failed');
    }
  }
}

/// Map exceptions to CloudinaryError
///
/// Converts various exception types (especially DioException) to standardized
/// CloudinaryError objects with appropriate error codes and messages.
///
/// Error code mapping:
/// - DioExceptionType.connectionTimeout/sendTimeout/receiveTimeout → TIMEOUT_ERROR
/// - DioExceptionType.connectionError → NETWORK_ERROR
/// - DioExceptionType.badResponse (401/403) → AUTH_ERROR
/// - DioExceptionType.badResponse (429) → QUOTA_EXCEEDED
/// - Other DioException types → UNKNOWN_ERROR
/// - Non-DioException errors → UNKNOWN_ERROR
///
/// [error] - The exception to map
///
/// Returns a [CloudinaryError] with appropriate code and message.
CloudinaryError _mapError(dynamic error) {
  // Check if error is DioException
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CloudinaryError(
          code: CloudinaryError.timeoutError,
          message: 'Upload timed out',
          details: error.message,
        );

      case DioExceptionType.connectionError:
        return CloudinaryError(
          code: CloudinaryError.networkError,
          message: 'Network connection failed',
          details: error.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return CloudinaryError(
            code: CloudinaryError.authError,
            message: 'Authentication failed',
            details: error.message,
          );
        } else if (statusCode == 429) {
          return CloudinaryError(
            code: CloudinaryError.quotaExceeded,
            message: 'Upload quota exceeded',
            details: error.message,
          );
        }
        return CloudinaryError(
          code: CloudinaryError.unknownError,
          message: 'Upload failed',
          details: error.message,
        );

      default:
        return CloudinaryError(
          code: CloudinaryError.unknownError,
          message: 'Upload failed',
          details: error.message,
        );
    }
  }

  // For non-DioException errors
  return CloudinaryError(
    code: CloudinaryError.unknownError,
    message: error.toString(),
  );
}

