// Purpose: Controller for account setting page
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AccountSettingController extends GetxController {
  final AuthService _authService = AuthService.to;

  final RxString profileImageUrl = ''.obs;
  final RxString fullName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString registeredId = ''.obs;
  final RxString location = ''.obs;
  final RxString occupation = ''.obs;
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
      fullName.value = user.fullName ?? 'Nibertu Birhanu';
      phoneNumber.value = user.phone;
      registeredId.value =
          '1234-5678-9012'; // Not in UserModel, would come from API
      location.value =
          'Ethiopia, Addis Abeba'; // Not in UserModel, would come from API
      occupation.value = user.workStatus ?? 'UI/UX Designer';
    } else {
      // Default values for demo
      fullName.value = 'Nibertu Birhanu';
      phoneNumber.value = '94 825 228 5';
      registeredId.value = '1234-5678-9012';
      location.value = 'Ethiopia, Addis Abeba';
      occupation.value = 'UI/UX Designer';
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
    // TODO: Show location picker dialog
    _showLocationDialog();
  }

  void onOccupationTap() {
    // TODO: Show occupation picker dialog
    _showOccupationDialog();
  }

  void _showLocationDialog() {
    final locations = [
      'Ethiopia, Addis Abeba',
      'Ethiopia, Dire Dawa',
      'Ethiopia, Hawassa',
      'Ethiopia, Bahir Dar',
      'Ethiopia, Mekelle',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
            ListView.builder(
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
          ],
        ),
      ),
    );
  }

  void _showOccupationDialog() {
    final occupations = [
      'UI/UX Designer',
      'Software Developer',
      'Business Analyst',
      'Project Manager',
      'Marketing Manager',
      'Accountant',
      'Teacher',
      'Doctor',
      'Engineer',
      'Other',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: occupations.length,
              itemBuilder: (context, index) {
                final occ = occupations[index];
                return ListTile(
                  title: Text(occ),
                  onTap: () {
                    occupation.value = occ;
                    Get.back();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
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
      // TODO: Save to API
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'success'.tr,
        'account_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Update auth service user data
      // await _authService.updateProfile(...);

      Get.back();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
