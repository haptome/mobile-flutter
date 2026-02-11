// Purpose: Quality check result model for image validation
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

/// Model representing the results of image quality checks
/// 
/// This model contains the results of various quality validation checks
/// performed on a captured image, including blur detection, glare detection,
/// and lighting validation. All checks must pass for the image to be accepted.
class QualityCheckResult {
  /// Whether the image is sharp enough (not blurry)
  final bool isSharp;

  /// Whether the image has no glare (overexposed areas)
  final bool hasNoGlare;

  /// Whether the image has good lighting (not too dark or bright)
  final bool hasGoodLighting;

  /// The blur score (Laplacian variance)
  /// Higher values indicate sharper images
  /// Threshold: > 100 for acceptable sharpness
  final double blurScore;

  /// The percentage of pixels that are overexposed (glare)
  /// Lower values are better
  /// Threshold: < 15% for acceptable quality
  final double glarePercentage;

  /// The mean brightness of the image
  /// Should be in acceptable range (60-200)
  final double brightness;

  const QualityCheckResult({
    required this.isSharp,
    required this.hasNoGlare,
    required this.hasGoodLighting,
    required this.blurScore,
    required this.glarePercentage,
    required this.brightness,
  });

  /// Check if all quality checks passed
  bool get passed => isSharp && hasNoGlare && hasGoodLighting;

  /// Get a list of failed checks for user feedback
  List<String> get failedChecks {
    final failed = <String>[];
    if (!isSharp) failed.add('Image is too blurry');
    if (!hasNoGlare) failed.add('Image has too much glare');
    if (!hasGoodLighting) failed.add('Image has poor lighting');
    return failed;
  }

  /// Get a user-friendly message about the quality check result
  String get message {
    if (passed) {
      return 'Image quality is good';
    } else {
      return failedChecks.join(', ');
    }
  }

  /// Create a copy of this result with updated values
  QualityCheckResult copyWith({
    bool? isSharp,
    bool? hasNoGlare,
    bool? hasGoodLighting,
    double? blurScore,
    double? glarePercentage,
    double? brightness,
  }) {
    return QualityCheckResult(
      isSharp: isSharp ?? this.isSharp,
      hasNoGlare: hasNoGlare ?? this.hasNoGlare,
      hasGoodLighting: hasGoodLighting ?? this.hasGoodLighting,
      blurScore: blurScore ?? this.blurScore,
      glarePercentage: glarePercentage ?? this.glarePercentage,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  String toString() {
    return 'QualityCheckResult(passed: $passed, isSharp: $isSharp, '
        'hasNoGlare: $hasNoGlare, hasGoodLighting: $hasGoodLighting, '
        'blurScore: $blurScore, glarePercentage: $glarePercentage, '
        'brightness: $brightness)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QualityCheckResult &&
        other.isSharp == isSharp &&
        other.hasNoGlare == hasNoGlare &&
        other.hasGoodLighting == hasGoodLighting &&
        other.blurScore == blurScore &&
        other.glarePercentage == glarePercentage &&
        other.brightness == brightness;
  }

  @override
  int get hashCode {
    return Object.hash(
      isSharp,
      hasNoGlare,
      hasGoodLighting,
      blurScore,
      glarePercentage,
      brightness,
    );
  }
}
