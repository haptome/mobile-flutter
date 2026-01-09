// Purpose: Controller for Category Detail page
// Author: Auto-generated

import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/models/group_model.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import '../core/routes/app_routes.dart';
import 'package:flutter/material.dart';

/// Controller enhancements: support joining a group from category list

class CategoryDetailController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final Rx<category_models.Category> category;
  final RxList<Group> groups = <Group>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  CategoryDetailController({required category_models.Category category})
    : category = category.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _groupService.getGroups(
        categoryId: category.value.id,
        status: 'active', // Only show active groups
      );

      if (response.success && response.data != null) {
        groups.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to load groups';
      }
    } catch (e) {
      errorMessage.value = 'Error loading groups: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onGroupTap(Group group) {
    Get.toNamed(AppRoutes.groupDetail, arguments: group);
  }

  Future<void> onJoinTap(Group group) async {
    // Basic validation: ensure user is verified
    final auth = AuthService.to;
    final kyc = auth.currentUser.value?.kycStatus;
    if (kyc != 'verified') {
      // Prompt user to verify account
      Get.defaultDialog(
        title: 'Verify Account',
        middleText: 'You need to verify your account before joining an ekub. Verify now?',
        textConfirm: 'Verify',
        textCancel: 'Later',
        onConfirm: () {
          Get.back();
          Get.toNamed(AppRoutes.verification);
        },
      );
      return;
    }

    // Confirm join action
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Join Ekub'),
        content: Text('Are you sure you want to join "${group.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Join')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      final resp = await _groupService.joinGroup(group.id, acceptTerms: true);
      if (resp.success) {
        Get.snackbar('Joined', resp.message ?? 'Successfully joined group');
        // Navigate to group detail on success
        Get.toNamed(AppRoutes.groupDetail, arguments: group);
      } else {
        Get.snackbar('Join failed', resp.message ?? 'Failed to join group');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join group: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
