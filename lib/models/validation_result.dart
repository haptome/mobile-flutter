// Purpose: Result model for file validation before upload
// Author: Cloudinary Upload Integration
// Linked Spec Section: Requirements 2.5, 2.6

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
  });

  /// Factory constructor for valid files
  factory ValidationResult.valid() {
    return ValidationResult(isValid: true);
  }

  /// Factory constructor for invalid files with error details
  factory ValidationResult.invalid({
    required String message,
    required String code,
  }) {
    return ValidationResult(
      isValid: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}
