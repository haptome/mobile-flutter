// Purpose: Response model for Cloudinary upload operations
// Author: Cloudinary Upload Integration
// Linked Spec Section: Requirements 1.8, 13.2-13.8

import 'cloudinary_error.dart';

class CloudinaryResponse {
  final bool success;
  final String? secureUrl;
  final String? publicId;
  final String? resourceType; // 'image' or 'video'
  final String? format; // 'jpg', 'png', 'mp4', etc.
  final int? bytes;
  final CloudinaryError? error;

  CloudinaryResponse({
    required this.success,
    this.secureUrl,
    this.publicId,
    this.resourceType,
    this.format,
    this.bytes,
    this.error,
  });

  /// Factory constructor for successful uploads
  factory CloudinaryResponse.success({
    required String secureUrl,
    required String publicId,
    required String resourceType,
    required String format,
    required int bytes,
  }) {
    return CloudinaryResponse(
      success: true,
      secureUrl: secureUrl,
      publicId: publicId,
      resourceType: resourceType,
      format: format,
      bytes: bytes,
    );
  }

  /// Factory constructor for failed uploads
  factory CloudinaryResponse.failure({
    required CloudinaryError error,
  }) {
    return CloudinaryResponse(
      success: false,
      error: error,
    );
  }

  /// Factory constructor to parse Cloudinary SDK response
  factory CloudinaryResponse.fromCloudinarySDK(Map<String, dynamic> response) {
    return CloudinaryResponse(
      success: true,
      secureUrl: response['secure_url'] as String,
      publicId: response['public_id'] as String,
      resourceType: response['resource_type'] as String,
      format: response['format'] as String,
      bytes: response['bytes'] as int,
    );
  }
}
