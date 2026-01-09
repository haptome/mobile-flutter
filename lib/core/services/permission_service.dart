// Purpose: Permission service for handling device permissions
// Author: Generated
// Description: Handles camera, storage, and other device permissions for both Android and iOS

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Request storage permission (Android) or photos permission (iOS)
  Future<bool> requestStoragePermission() async {
    late Permission permission;

    if (GetPlatform.isIOS) {
      permission = Permission.photos;
    } else {
      // For Android 13+, we might need media library permission
      // For older Android versions, we need storage permission
      permission = Permission.storage;
    }

    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    final permissions = <Permission>[];

    if (GetPlatform.isIOS) {
      permissions.addAll([Permission.camera, Permission.photos]);
    } else {
      permissions.addAll([Permission.camera, Permission.storage]);
    }

    if (GetPlatform.isIOS) {
      return await [Permission.camera, Permission.photos].request();
    } else {
      return await [Permission.camera, Permission.storage].request();
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

    return cameraGranted && storageGranted;
  }

  /// Request permissions required for KYC document upload
  Future<bool> requestKycPermissions() async {
    Map<Permission, PermissionStatus> statuses;

    if (GetPlatform.isIOS) {
      statuses = await [Permission.camera, Permission.photos].request();
    } else {
      statuses = await [Permission.camera, Permission.storage].request();
    }

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
}
