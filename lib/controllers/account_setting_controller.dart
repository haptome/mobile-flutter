// Purpose: Controller for account setting page
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'dart:io';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/permission_service.dart';

class AccountSettingController extends GetxController {
  final AuthService _authService = AuthService.to;

  final RxString profileImageUrl = ''.obs;
  final RxString fullName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString location = ''.obs;
  final RxString workStatus = ''.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser.value;
    if (user != null) {
      profileImageUrl.value = user.profilePicUrl ?? '';
      fullName.value = user.fullName ?? '';
      phoneNumber.value = user.phone;
      location.value = user.location ?? '';
      workStatus.value = user.workStatus ?? '';
    } else {
      // Default values for demo
      fullName.value = '';
      phoneNumber.value = '';
      location.value = '';
      workStatus.value = '';
    }
  }

  void onSelectPhoto() {
    _showImageOptionsDialog();
  }

  void _showImageOptionsDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions before picking image
      final permissionService = Get.find<PermissionService>();
      final permissionsGranted = await permissionService
          .requestKycPermissions();

      if (!permissionsGranted) {
        Get.snackbar(
          'Permission Error',
          'Camera and storage permissions are required to select a photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80, // Reduce image quality to optimize upload
        maxHeight: 800,
        maxWidth: 800,
      );

      if (image != null) {
        // Update the profile image URL with the local path temporarily
        profileImageUrl.value = image.path;

        // Now upload the image to the server
        await _uploadProfileImage(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: \$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadProfileImage(String imagePath) async {
    try {
      isSaving.value = true;

      final File imageFile = File(imagePath);

      // Upload the image to the server via the auth service
      final response = await _authService.uploadProfileImage(imageFile);

      if (response.success && response.data != null) {
        // Update the profile image URL with the server URL
        final imageUrl = response.data!["imageUrl"] as String? ?? "";
        profileImageUrl.value = imageUrl;

        Get.snackbar(
          'Success',
          'Profile image updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Failed',
          response.error?.message ??
              response.message ??
              'Failed to upload profile image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload profile image: \$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void onLocationTap() {
    _showLocationDialog();
  }

  void onOccupationTap() {
    _showOccupationDialog();
  }

  void _showLocationDialog() {
    final locations = [
      'Addis Ababa',
      'Dire Dawa',
      'Hawassa',
      'Bahir Dar',
      'Mekelle',
      'Adama',
      'Jimma',
      'Dessie',
      'Axum',
      'Gondar',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return ListTile(
                    title: Text(loc),
                    onTap: () {
                      location.value = loc;
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOccupationDialog() {
    final occupations = [
      'Employed',
      'Self Employed',
      'Student',
      'Unemployed',
      'Retired',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: occupations.length,
                itemBuilder: (context, index) {
                  final occ = occupations[index];
                  return ListTile(
                    title: Text(occ),
                    onTap: () {
                      workStatus.value = occ;
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _convertToSnakeCase(String input) {
    // Convert human-readable work status to snake_case for backend
    switch (input.toLowerCase()) {
      case 'employed':
        return 'employed';
      case 'self employed':
        return 'self_employed';
      case 'student':
        return 'student';
      case 'unemployed':
        return 'unemployed';
      case 'retired':
        return 'retired';
      default:
        return input.toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<void> onSaveChanges() async {
    if (fullName.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'full_name_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;

    try {
      // Call the update profile API
      // Convert work status to snake_case format for backend
      String? workStatusForBackend;
      if (workStatus.value.isNotEmpty) {
        workStatusForBackend = _convertToSnakeCase(workStatus.value);
      }

      final response = await _authService.updateProfile(
        fullName: fullName.value.isEmpty ? null : fullName.value,
        workStatus: workStatusForBackend,
        location: location.value.isEmpty ? null : location.value,
        profilePicUrl: profileImageUrl.value.isEmpty
            ? null
            : profileImageUrl.value,
      );

      if (response.success) {
        Get.snackbar(
          'success'.tr,
          response.message ?? 'account_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Refresh user data in auth service
        await _authService.getProfile();

        Future.delayed(Duration(seconds: 2), () {
          Get.back();
        });
        Get.back();
      } else {
        Get.snackbar(
          'error'.tr,
          response.error?.message ?? 'update_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
