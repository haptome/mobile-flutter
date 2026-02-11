// Purpose: Detection result models for edge and face detection
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'dart:ui';

/// Model representing the result of edge detection on an ID document
/// 
/// This model contains information about detected document edges,
/// including corner positions, confidence level, alignment status,
/// and overlap percentage with the target frame.
class EdgeDetectionResult {
  /// The four corners of the detected document
  /// Ordered as: top-left, top-right, bottom-right, bottom-left
  final List<Offset> corners;

  /// Confidence level of the detection (0.0 to 1.0)
  /// Higher values indicate more confident detection
  final double confidence;

  /// Whether the detected document is properly aligned within the target frame
  final bool isAligned;

  /// Percentage of the detected document that overlaps with the target frame
  /// Value between 0.0 and 1.0, where 1.0 means perfect overlap
  final double overlapPercentage;

  const EdgeDetectionResult({
    required this.corners,
    required this.confidence,
    required this.isAligned,
    required this.overlapPercentage,
  });

  /// Check if the detection has valid corners (exactly 4 corners)
  bool get hasValidCorners => corners.length == 4;

  /// Get the center point of the detected document
  Offset get center {
    if (!hasValidCorners) return Offset.zero;
    
    final sumX = corners.fold<double>(0, (sum, corner) => sum + corner.dx);
    final sumY = corners.fold<double>(0, (sum, corner) => sum + corner.dy);
    
    return Offset(sumX / corners.length, sumY / corners.length);
  }

  /// Calculate the approximate width of the detected document
  double get width {
    if (!hasValidCorners) return 0;
    
    // Average of top and bottom edge lengths
    final topWidth = (corners[1] - corners[0]).distance;
    final bottomWidth = (corners[2] - corners[3]).distance;
    
    return (topWidth + bottomWidth) / 2;
  }

  /// Calculate the approximate height of the detected document
  double get height {
    if (!hasValidCorners) return 0;
    
    // Average of left and right edge lengths
    final leftHeight = (corners[3] - corners[0]).distance;
    final rightHeight = (corners[2] - corners[1]).distance;
    
    return (leftHeight + rightHeight) / 2;
  }

  /// Calculate the aspect ratio of the detected document
  double get aspectRatio {
    if (height == 0) return 0;
    return width / height;
  }

  /// Check if the detection is good enough for capture
  /// Requires high confidence, proper alignment, and good overlap
  bool get isGoodForCapture {
    return confidence > 0.7 && isAligned && overlapPercentage >= 0.85;
  }

  /// Create a copy of this result with updated values
  EdgeDetectionResult copyWith({
    List<Offset>? corners,
    double? confidence,
    bool? isAligned,
    double? overlapPercentage,
  }) {
    return EdgeDetectionResult(
      corners: corners ?? this.corners,
      confidence: confidence ?? this.confidence,
      isAligned: isAligned ?? this.isAligned,
      overlapPercentage: overlapPercentage ?? this.overlapPercentage,
    );
  }

  @override
  String toString() {
    return 'EdgeDetectionResult(corners: ${corners.length}, '
        'confidence: ${confidence.toStringAsFixed(2)}, '
        'isAligned: $isAligned, '
        'overlapPercentage: ${(overlapPercentage * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EdgeDetectionResult &&
        _listEquals(other.corners, corners) &&
        other.confidence == confidence &&
        other.isAligned == isAligned &&
        other.overlapPercentage == overlapPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(corners),
      confidence,
      isAligned,
      overlapPercentage,
    );
  }

  /// Helper method to compare lists of Offsets
  static bool _listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Model representing the result of face detection
/// 
/// This model contains information about a detected face, including
/// facial bounds, eye open probabilities, head orientation angles,
/// and whether the face is in a frontal position.
class FaceDetectionResult {
  /// The bounding rectangle of the detected face
  final Rect faceBounds;

  /// Probability that the left eye is open (0.0 to 1.0)
  /// Values > 0.7 indicate open eye, < 0.3 indicate closed eye
  final double leftEyeOpenProbability;

  /// Probability that the right eye is open (0.0 to 1.0)
  /// Values > 0.7 indicate open eye, < 0.3 indicate closed eye
  final double rightEyeOpenProbability;

  /// Head rotation angle around Y-axis (yaw) in degrees
  /// Negative values: head turned left
  /// Positive values: head turned right
  /// Range: approximately -90 to +90 degrees
  final double headEulerAngleY;

  /// Head rotation angle around X-axis (pitch) in degrees
  /// Negative values: head tilted up
  /// Positive values: head tilted down
  /// Range: approximately -90 to +90 degrees
  final double headEulerAngleZ;

  /// Whether the face is in a frontal position (looking at camera)
  /// True when both yaw and pitch are within ±10 degrees of neutral
  final bool isFrontal;

  const FaceDetectionResult({
    required this.faceBounds,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.isFrontal,
  });

  /// Get the center point of the detected face
  Offset get center => faceBounds.center;

  /// Get the width of the face bounding box
  double get width => faceBounds.width;

  /// Get the height of the face bounding box
  double get height => faceBounds.height;

  /// Check if both eyes are open
  /// Eyes are considered open when probability > 0.7
  bool get bothEyesOpen {
    return leftEyeOpenProbability > 0.7 && rightEyeOpenProbability > 0.7;
  }

  /// Check if both eyes are closed
  /// Eyes are considered closed when probability < 0.3
  bool get bothEyesClosed {
    return leftEyeOpenProbability < 0.3 && rightEyeOpenProbability < 0.3;
  }

  /// Check if the face is in neutral position (±10 degrees)
  bool get isNeutralPose {
    return headEulerAngleY.abs() <= 10 && headEulerAngleZ.abs() <= 10;
  }

  /// Check if the head is turned left (yaw < -30 degrees)
  bool get isTurnedLeft {
    return headEulerAngleY < -30;
  }

  /// Check if the head is turned right (yaw > 30 degrees)
  bool get isTurnedRight {
    return headEulerAngleY > 30;
  }

  /// Check if the head is looking up (pitch < -20 degrees)
  bool get isLookingUp {
    return headEulerAngleZ < -20;
  }

  /// Check if the head is looking down (pitch > 20 degrees)
  bool get isLookingDown {
    return headEulerAngleZ > 20;
  }

  /// Get the average eye open probability
  double get averageEyeOpenProbability {
    return (leftEyeOpenProbability + rightEyeOpenProbability) / 2;
  }

  /// Check if the face is suitable for liveness detection
  /// Requires face to be reasonably sized and in frame
  bool get isSuitableForLiveness {
    // Face should occupy at least 20% of the frame width
    // and be in a reasonable position
    return width > 0 && height > 0;
  }

  /// Create a copy of this result with updated values
  FaceDetectionResult copyWith({
    Rect? faceBounds,
    double? leftEyeOpenProbability,
    double? rightEyeOpenProbability,
    double? headEulerAngleY,
    double? headEulerAngleZ,
    bool? isFrontal,
  }) {
    return FaceDetectionResult(
      faceBounds: faceBounds ?? this.faceBounds,
      leftEyeOpenProbability:
          leftEyeOpenProbability ?? this.leftEyeOpenProbability,
      rightEyeOpenProbability:
          rightEyeOpenProbability ?? this.rightEyeOpenProbability,
      headEulerAngleY: headEulerAngleY ?? this.headEulerAngleY,
      headEulerAngleZ: headEulerAngleZ ?? this.headEulerAngleZ,
      isFrontal: isFrontal ?? this.isFrontal,
    );
  }

  @override
  String toString() {
    return 'FaceDetectionResult('
        'bounds: $faceBounds, '
        'leftEye: ${leftEyeOpenProbability.toStringAsFixed(2)}, '
        'rightEye: ${rightEyeOpenProbability.toStringAsFixed(2)}, '
        'yaw: ${headEulerAngleY.toStringAsFixed(1)}°, '
        'pitch: ${headEulerAngleZ.toStringAsFixed(1)}°, '
        'isFrontal: $isFrontal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FaceDetectionResult &&
        other.faceBounds == faceBounds &&
        other.leftEyeOpenProbability == leftEyeOpenProbability &&
        other.rightEyeOpenProbability == rightEyeOpenProbability &&
        other.headEulerAngleY == headEulerAngleY &&
        other.headEulerAngleZ == headEulerAngleZ &&
        other.isFrontal == isFrontal;
  }

  @override
  int get hashCode {
    return Object.hash(
      faceBounds,
      leftEyeOpenProbability,
      rightEyeOpenProbability,
      headEulerAngleY,
      headEulerAngleZ,
      isFrontal,
    );
  }
}
