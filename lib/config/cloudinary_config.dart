/// Environment enum for different deployment environments
enum Environment {
  development,
  staging,
  production,
}

/// Configuration class for Cloudinary service
///
/// Manages environment-specific Cloudinary credentials and settings.
/// Use [forEnvironment] factory method to create configuration for a specific environment.
class CloudinaryConfig {
  /// Cloudinary cloud name
  final String cloudName;

  /// Upload preset name (unsigned preset configured in Cloudinary dashboard)
  final String uploadPreset;

  /// Cloudinary API key
  final String apiKey;

  /// Current environment
  final Environment environment;

  /// Creates a CloudinaryConfig instance
  CloudinaryConfig({
    required this.cloudName,
    required this.uploadPreset,
    required this.apiKey,
    required this.environment,
  });

  /// Factory method to create configuration for a specific environment
  ///
  /// Returns a [CloudinaryConfig] instance with environment-specific settings.
  /// All environments use the same cloudName and apiKey, but different upload presets.
  ///
  /// Example:
  /// ```dart
  /// final config = CloudinaryConfig.forEnvironment(Environment.development);
  /// ```
  factory CloudinaryConfig.forEnvironment(Environment env) {
    switch (env) {
      case Environment.development:
        return CloudinaryConfig(
          cloudName: 'dglbocbnt',
          uploadPreset: 'unsigned_dev_preset',
          apiKey: '676919573513538',
          environment: Environment.development,
        );
      case Environment.staging:
        return CloudinaryConfig(
          cloudName: 'dglbocbnt',
          uploadPreset: 'unsigned_staging_preset',
          apiKey: '676919573513538',
          environment: Environment.staging,
        );
      case Environment.production:
        return CloudinaryConfig(
          cloudName: 'dglbocbnt',
          uploadPreset: 'unsigned_prod_preset',
          apiKey: '676919573513538',
          environment: Environment.production,
        );
    }
  }

  /// Validates that all required configuration fields are present
  ///
  /// Returns true if cloudName and uploadPreset are not empty, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final config = CloudinaryConfig.forEnvironment(Environment.development);
  /// if (!config.validate()) {
  ///   throw Exception('Invalid Cloudinary configuration');
  /// }
  /// ```
  bool validate() {
    return cloudName.isNotEmpty && uploadPreset.isNotEmpty;
  }
}
