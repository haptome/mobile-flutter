// Purpose: Controller for profile page
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'dart:io';
import 'package:et_digital_equb/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/cloudinary_service.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import '../features/profile/set_password_view.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();
  final ImagePicker _imagePicker = ImagePicker();
  
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  final RxBool isUploadingPhoto = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    // Load user data from auth service
    final currentUser = _authService.currentUser.value;
    if (currentUser != null) {
      user.value = {
        'name': currentUser.fullName ?? 'user_name'.tr,
        'phone': currentUser.phone,
        'idNumber': '1234-5678-9012', // Not in UserModel, would come from API
        'location': 'Addis Ababa', // Not in UserModel, would come from API
        'level': '1',
        'profileImageUrl': currentUser.profilePicUrl,
      };
    } else {
      // Default user data for demo
      user.value = {
        'name': 'Nibertu Birhanu',
        'phone': '+251 9 00 00 0000',
        'idNumber': '1234-5678-9012',
        'location': 'Addis Ababa',
        'level': '1',
        'profileImageUrl': null,
      };
    }
  }

  void onEditProfile() {
    _showPhotoUploadBottomSheet();
  }

  void _showPhotoUploadBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.25,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'set new profile photo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickImageFromGallery,
                ),
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: _pickImageFromCamera,
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFBBBB32).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: const Color(0xFFBBBB32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      Get.back(); // Close bottom sheet
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadProfilePhoto(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      Get.back(); // Close bottom sheet
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
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadProfilePhoto(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image from camera',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    try {
      isUploadingPhoto.value = true;

      // Read file bytes for web compatibility
      final fileBytes = await imageFile.readAsBytes();

      // Upload with pre-loaded bytes for web compatibility
      final uploadResult = await _cloudinaryService.uploadImage(
        filePath: imageFile.path,
        folder: 'profile_photos',
        fileBytes: fileBytes,
      );

      if (uploadResult.success) {
        final imageUrl = uploadResult.secureUrl;

        // Update user profile with new photo URL
        final updateResult = await _authService.updateProfile(
          profilePicUrl: imageUrl,
        );

        if (updateResult.success) {
          // Update local user data
          user['profileImageUrl'] = imageUrl ?? '';
          user.refresh();

          Get.snackbar(
            'Success',
            'Profile photo updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            updateResult.message ?? 'Failed to update profile',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // Get detailed error message
        final errorMessage = uploadResult.error?.userMessage ?? 
                           uploadResult.error?.message ?? 
                           'Failed to upload image';
        
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // Log the error for debugging
        print('[ProfileController] Upload failed: ${uploadResult.error?.code} - ${uploadResult.error?.message}');
        if (uploadResult.error?.details != null) {
          print('[ProfileController] Error details: ${uploadResult.error?.details}');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload profile photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  void onWalletTap() {
    // TODO: Navigate to wallet page
    Get.snackbar(
      'wallet'.tr,
      'wallet_page_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onAccountSettingTap() {
    Get.toNamed('/account-setting');
  }

  void onVerificationTap() {
    Get.toNamed('/verification');
  }

  void onSetPasswordTap() async {
    // Show set password as bottom sheet, checking if user actually has a password set
    // We can check the hasPassword field directly from the current user model
    final hasPassword = _authService.currentUser.value?.hasPassword ?? false;

    SetPasswordBottomSheet.show(
      context: Get.context!,
      hasExistingPassword: hasPassword,
    );
  }

  void onSetFirstTimePassword() {
    // Show set password as bottom sheet for first-time password setup
    SetPasswordBottomSheet.show(
      context: Get.context!,
      hasExistingPassword: false,
    );
  }

  void onTermsConditionsTap() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  void onPrivacyPolicyTap() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void onFaqTap() {
    Get.toNamed(AppRoutes.faq);
  }

  void onAboutTap() {
    Get.toNamed(AppRoutes.about);
  }

  void onLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _authService.logout();
            },
            child: Text(
              'logout'.tr,
              style: const TextStyle(color: Color(0xFFF44336)),
            ),
          ),
        ],
      ),
    );
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        // Already on Profile page
        break;
    }
  }
}
