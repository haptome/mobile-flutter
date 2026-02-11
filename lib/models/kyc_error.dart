// Purpose: KYC error types for error handling
// Author: Auto-generated
// Linked Spec Section: KYC ID & Liveness Flow - Error Handling

/// Enum representing different types of errors that can occur during KYC flow
enum KYCError {
  /// Camera permission was denied by the user
  cameraPermissionDenied,

  /// Failed to initialize camera
  cameraInitializationFailed,

  /// Edge detection failed or document not detected
  edgeDetectionFailed,

  /// Image quality check failed (blur, glare, or lighting)
  qualityCheckFailed,

  /// No face detected during liveness check
  faceNotDetected,

  /// Liveness challenge failed or timed out
  challengeFailed,

  /// Failed to upload images to cloud storage
  uploadFailed,

  /// Network error during API calls
  networkError,

  /// Session timed out
  timeout,
}

/// Extension to provide user-friendly error messages
extension KYCErrorExtension on KYCError {
  /// Get user-friendly error message
  String get message {
    switch (this) {
      case KYCError.cameraPermissionDenied:
        return 'Camera permission is required to capture your ID and verify your identity';
      case KYCError.cameraInitializationFailed:
        return 'Failed to initialize camera. Please try again';
      case KYCError.edgeDetectionFailed:
        return 'Could not detect document edges. Please ensure your ID is clearly visible';
      case KYCError.qualityCheckFailed:
        return 'Image quality is too low. Please ensure good lighting and avoid glare';
      case KYCError.faceNotDetected:
        return 'Could not detect your face. Please position your face in the frame';
      case KYCError.challengeFailed:
        return 'Liveness check failed. Please follow the instructions carefully';
      case KYCError.uploadFailed:
        return 'Failed to upload images. Please check your internet connection';
      case KYCError.networkError:
        return 'Network error. Please check your internet connection and try again';
      case KYCError.timeout:
        return 'Session timed out. Please try again';
    }
  }

  /// Get error code for logging/analytics
  String get code {
    switch (this) {
      case KYCError.cameraPermissionDenied:
        return 'CAMERA_PERMISSION_DENIED';
      case KYCError.cameraInitializationFailed:
        return 'CAMERA_INIT_FAILED';
      case KYCError.edgeDetectionFailed:
        return 'EDGE_DETECTION_FAILED';
      case KYCError.qualityCheckFailed:
        return 'QUALITY_CHECK_FAILED';
      case KYCError.faceNotDetected:
        return 'FACE_NOT_DETECTED';
      case KYCError.challengeFailed:
        return 'CHALLENGE_FAILED';
      case KYCError.uploadFailed:
        return 'UPLOAD_FAILED';
      case KYCError.networkError:
        return 'NETWORK_ERROR';
      case KYCError.timeout:
        return 'TIMEOUT';
    }
  }

  /// Check if error is recoverable (user can retry)
  bool get isRecoverable {
    switch (this) {
      case KYCError.cameraPermissionDenied:
        return false; // Need to go to settings
      case KYCError.cameraInitializationFailed:
      case KYCError.edgeDetectionFailed:
      case KYCError.qualityCheckFailed:
      case KYCError.faceNotDetected:
      case KYCError.challengeFailed:
      case KYCError.uploadFailed:
      case KYCError.networkError:
      case KYCError.timeout:
        return true;
    }
  }
}
