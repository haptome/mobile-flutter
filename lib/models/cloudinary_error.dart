// Purpose: Error model for Cloudinary upload operations
// Author: Cloudinary Upload Integration
// Linked Spec Section: Requirements 1.5, 9.1-9.7

class CloudinaryError {
  final String code;
  final String message;
  final String? details;

  CloudinaryError({
    required this.code,
    required this.message,
    this.details,
  });

  // Predefined error codes
  static const String networkError = 'NETWORK_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String fileTooLarge = 'FILE_TOO_LARGE';
  static const String invalidFileType = 'INVALID_FILE_TYPE';
  static const String quotaExceeded = 'QUOTA_EXCEEDED';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  // User-friendly error messages
  String get userMessage {
    switch (code) {
      case networkError:
        return 'Network connection failed. Please check your internet connection.';
      case authError:
        return 'Upload authentication failed. Please try again.';
      case fileTooLarge:
        return 'File is too large. Maximum size is 10MB for images and 50MB for videos.';
      case invalidFileType:
        return 'Invalid file type. Please select a valid image or video file.';
      case quotaExceeded:
        return 'Upload quota exceeded. Please try again later.';
      case timeoutError:
        return 'Upload timed out. Please try again.';
      case validationError:
        return message;
      default:
        return 'Upload failed. Please try again.';
    }
  }
}
