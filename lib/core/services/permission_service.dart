// Purpose: Permission service for handling device permissions
// Author: Generated
// Description: Handles camera, storage, and other device permissions for both Android and iOS

import 'package:get/get.dart';

/// Enum to define different permission types for various app features
enum PermissionType { kyc, camera, storage, location, microphone }

/// Minimal no-op PermissionService: returns allowed (true) for all checks.
/// This effectively removes runtime permission handling while keeping the
/// API surface so callers compile.
class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  Future<bool> ensureCameraPhotoPermission() async => true;
  Future<bool> ensureGalleryPermission() async => true;
  Future<bool> ensureVideoRecordingPermission() async => true;
  Future<bool> ensureDocumentPickerPermission() async => true;

  Future<bool> isCameraPermissionGranted() async => true;
  Future<bool> isStoragePermissionGranted() async => true;
  Future<bool> isMicrophonePermissionGranted() async => true;
  Future<bool> hasRequiredKycPermissions() async => true;

  Future<Map<dynamic, dynamic>> getKycPermissionStatus() async => {};

  // Compatibility wrappers
  Future<bool> requestKycPermissions() async => true;
  Future<bool> requestMicrophonePermission() async => true;
  Future<bool> requestStoragePermission() async => true;
  Future<Map<dynamic, dynamic>> requestPermissions(PermissionType type) async =>
      {};
  Future<bool> requestPermissionsGranted(PermissionType type) async => true;

  Future<void> openAppSettings() async {}
}
