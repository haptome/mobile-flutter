/// Represents the type of file being uploaded
enum FileType {
  image,
  video,
}

/// Represents the status of a queued upload
enum QueueStatus {
  pending,
  uploading,
  completed,
  failed,
}

/// Represents an upload in the offline queue
///
/// This model is used to persist pending uploads to local storage
/// and track their status through the upload lifecycle.
class QueuedUpload {
  /// Unique identifier for this upload (UUID)
  final String id;

  /// Local file path to upload
  final String filePath;

  /// Cloudinary folder path for the upload
  final String folder;

  /// Type of file (image or video)
  final FileType fileType;

  /// Optional metadata tags for the upload
  final Map<String, dynamic>? metadata;

  /// Current status of the upload
  final QueueStatus status;

  /// Timestamp when the upload was queued
  final DateTime queuedAt;

  /// Timestamp when the upload completed (null if not completed)
  final DateTime? uploadedAt;

  /// Error message if upload failed (null if not failed)
  final String? errorMessage;

  /// Number of retry attempts made
  final int retryCount;

  QueuedUpload({
    required this.id,
    required this.filePath,
    required this.folder,
    required this.fileType,
    this.metadata,
    required this.status,
    required this.queuedAt,
    this.uploadedAt,
    this.errorMessage,
    this.retryCount = 0,
  });

  /// Convert to JSON for persistence to SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'folder': folder,
      'file_type': fileType.toString(),
      'metadata': metadata,
      'status': status.toString(),
      'queued_at': queuedAt.toIso8601String(),
      'uploaded_at': uploadedAt?.toIso8601String(),
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }

  /// Create from JSON when loading from SharedPreferences
  factory QueuedUpload.fromJson(Map<String, dynamic> json) {
    return QueuedUpload(
      id: json['id'] as String,
      filePath: json['file_path'] as String,
      folder: json['folder'] as String,
      fileType: FileType.values.firstWhere(
        (e) => e.toString() == json['file_type'],
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: QueueStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      queuedAt: DateTime.parse(json['queued_at'] as String),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  /// Create a copy with updated fields
  ///
  /// This is useful for updating the status of an upload
  /// while keeping other fields unchanged.
  QueuedUpload copyWith({
    QueueStatus? status,
    DateTime? uploadedAt,
    String? errorMessage,
    int? retryCount,
  }) {
    return QueuedUpload(
      id: id,
      filePath: filePath,
      folder: folder,
      fileType: fileType,
      metadata: metadata,
      status: status ?? this.status,
      queuedAt: queuedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
