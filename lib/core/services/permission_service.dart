// Purpose: Permission service for handling device permissions
// Author: Generated
// Description: Handles camera, storage, and other device permissions for both Android and iOS

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enum to define different permission types for various app features
enum PermissionType { kyc, camera, storage, location, microphone }

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Request storage permission with platform-specific handling
  Future<bool> requestStoragePermission() async {
    late Permission permission;

    if (GetPlatform.isIOS) {
      permission = Permission.photos;
    } else {
      // For Android, use storage permission
      permission = Permission.storage;
    }

    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission (important for video recordings)
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Request multiple permissions at once based on the feature type
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    PermissionType type,
  ) async {
    List<Permission> permissions = [];

    switch (type) {
      case PermissionType.kyc:
        permissions = _getKycPermissions();
        break;
      case PermissionType.camera:
        permissions = [Permission.camera];
        break;
      case PermissionType.storage:
        permissions = [Permission.storage, Permission.photos];
        break;
      case PermissionType.location:
        permissions = [Permission.location];
        break;
      case PermissionType.microphone:
        permissions = [Permission.microphone];
        break;
    }

    return await permissions.request();
  }

  /// Get the list of permissions required for KYC operations
  List<Permission> _getKycPermissions() {
    if (GetPlatform.isIOS) {
      return [Permission.camera, Permission.photos, Permission.microphone];
    } else {
      // For Android, we use the general approach with fallback
      return [Permission.camera, Permission.storage, Permission.microphone];
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    late Permission permission;

    if (GetPlatform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    final status = await permission.status;
    return status == PermissionStatus.granted;
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Open app settings to allow user to manually grant permissions
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Show rationale dialog for permissions (Android)
  Future<bool> showPermissionRationale(Permission permission) async {
    if (GetPlatform.isAndroid) {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    }
    return false;
  }

  /// Check if all required permissions are granted for KYC document upload
  Future<bool> hasRequiredKycPermissions() async {
    final cameraGranted = await isCameraPermissionGranted();
    final storageGranted = await isStoragePermissionGranted();
    final micGranted = await isMicrophonePermissionGranted();

    return cameraGranted && storageGranted && micGranted;
  }

  /// Request permissions required for KYC document upload
  Future<bool> requestKycPermissions() async {
    final statuses = await requestPermissions(PermissionType.kyc);

    // Check if all required permissions were granted
    bool allGranted = true;
    for (final status in statuses.values) {
      if (status != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }

    return allGranted;
  }

  /// Get detailed status of all permissions needed for KYC
  Future<Map<Permission, PermissionStatus>> getKycPermissionStatus() async {
    final permissions = _getKycPermissions();
    final statusMap = <Permission, PermissionStatus>{};

    for (final permission in permissions) {
      statusMap[permission] = await permission.status;
    }

    return statusMap;
  }

  /// Check if any permission is permanently denied
  bool hasAnyPermanentlyDenied(Map<Permission, PermissionStatus> statusMap) {
    return statusMap.values.any(
      (status) => status == PermissionStatus.permanentlyDenied,
    );
  }

  /// Get list of permissions that need to be requested
  List<Permission> getMissingPermissions(
    Map<Permission, PermissionStatus> statusMap,
  ) {
    return statusMap.entries
        .where((entry) => entry.value != PermissionStatus.granted)
        .map((entry) => entry.key)
        .toList();
  }
}
