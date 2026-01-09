// Purpose: Controller for account setting page
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      location.value = '';
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
    // TODO: Implement image picker
    Get.snackbar(
      'select_photo'.tr,
      'select_photo_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onLocationTap() {
    _showLocationDialog();
  }

  void onOccupationTap() {
    _showOccupationDialog();
  }

  void _showLocationDialog() {
    final locations = [
      'Ethiopia, Addis Ababa',
      'Ethiopia, Dire Dawa',
      'Ethiopia, Hawassa',
      'Ethiopia, Bahir Dar',
      'Ethiopia, Mekelle',
      'Ethiopia, Adama',
      'Ethiopia, Jimma',
      'Ethiopia, Dessie',
      'Ethiopia, Axum',
      'Ethiopia, Gondar',
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
