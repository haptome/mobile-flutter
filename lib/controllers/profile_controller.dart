// Purpose: Controller for profile page
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;

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
    // TODO: Navigate to edit profile page
    Get.snackbar(
      'edit_profile'.tr,
      'edit_profile_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
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

  void onSetPasswordTap() {
    // TODO: Navigate to set password page
    Get.snackbar(
      'set_password'.tr,
      'set_password_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onTermsConditionsTap() {
    Get.toNamed('/terms-conditions');
  }

  void onFaqTap() {
    Get.toNamed('/faq');
  }

  void onLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
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
