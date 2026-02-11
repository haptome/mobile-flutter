/// File validation constants for Cloudinary uploads
///
/// This class contains static constants used for validating files before upload,
/// configuring image transformations, and managing retry logic.
class FileValidation {
  // Private constructor to prevent instantiation
  FileValidation._();

  // Maximum file sizes
  /// Maximum allowed size for image files (10MB)
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB

  /// Maximum allowed size for video files (50MB)
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB

  // Supported formats
  /// List of supported image file formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'heic',
  ];

  /// List of supported video file formats
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
  ];

  // Image transformation settings
  /// Maximum width for uploaded images (in pixels)
  static const int maxImageWidth = 2048;

  /// Maximum height for uploaded images (in pixels)
  static const int maxImageHeight = 2048;

  /// Image quality setting for Cloudinary transformations
  static const String imageQuality = 'auto';

  /// Image format setting for Cloudinary transformations
  static const String imageFormat = 'auto';

  // Retry settings
  /// Maximum number of retry attempts for failed uploads
  static const int maxRetries = 3;

  /// Delay durations (in milliseconds) for exponential backoff retry logic
  static const List<int> retryDelaysMs = [1000, 2000, 4000]; // 1s, 2s, 4s

  // Progress update threshold
  /// Minimum bytes transferred before triggering a progress update (100KB)
  static const int progressUpdateBytes = 100 * 1024; // 100KB
}
