// Purpose: Capture result model for ID document capture
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:camera/camera.dart';
import 'id_type.dart';
import 'quality_check_result.dart';

/// Model representing the result of capturing an ID document
/// 
/// This model encapsulates all information about a captured ID image,
/// including the image file itself, metadata about the ID type and side,
/// quality check results, and timestamp information.
class CaptureResult {
  /// The captured image file
  final XFile imageFile;

  /// The type of ID document that was captured
  final IDType idType;

  /// Whether this is the front side of the document
  /// For passports, this is always true since they don't have a back side
  final bool isFrontSide;

  /// Results of quality checks performed on the captured image
  final QualityCheckResult qualityCheck;

  /// Timestamp when the image was captured
  final DateTime timestamp;

  const CaptureResult({
    required this.imageFile,
    required this.idType,
    required this.isFrontSide,
    required this.qualityCheck,
    required this.timestamp,
  });

  /// Get the file path of the captured image
  String get path => imageFile.path;

  /// Get the file name of the captured image
  String get name => imageFile.name;

  /// Check if this capture passed all quality checks
  bool get isValid => qualityCheck.passed;

  /// Get a descriptive label for this capture (e.g., "National ID - Front")
  String get label {
    final idTypeInfo = IDTypeInfo.forType(idType);
    final side = isFrontSide ? 'Front' : 'Back';
    return '${idTypeInfo.displayName} - $side';
  }

  /// Create a copy of this result with updated values
  CaptureResult copyWith({
    XFile? imageFile,
    IDType? idType,
    bool? isFrontSide,
    QualityCheckResult? qualityCheck,
    DateTime? timestamp,
  }) {
    return CaptureResult(
      imageFile: imageFile ?? this.imageFile,
      idType: idType ?? this.idType,
      isFrontSide: isFrontSide ?? this.isFrontSide,
      qualityCheck: qualityCheck ?? this.qualityCheck,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'CaptureResult(path: ${imageFile.path}, idType: $idType, '
        'isFrontSide: $isFrontSide, qualityCheck: $qualityCheck, '
        'timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CaptureResult &&
        other.imageFile.path == imageFile.path &&
        other.idType == idType &&
        other.isFrontSide == isFrontSide &&
        other.qualityCheck == qualityCheck &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      imageFile.path,
      idType,
      isFrontSide,
      qualityCheck,
      timestamp,
    );
  }
}
