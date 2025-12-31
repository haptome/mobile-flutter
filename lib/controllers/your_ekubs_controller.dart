// Purpose: Controller for Your Ekubs page
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:flutter/foundation.dart';

class YourEkubsController extends GetxController {
  final AuthService _authService = AuthService.to;
  final GroupService _groupService = GroupService.to;

  // Combined list of cash and in-kind groups
  final RxList<Map<String, dynamic>> ekubs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserGroups();
  }

  Future<void> loadUserGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final user = _authService.currentUser.value;
      if (user?.id == null) {
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      // Fetch both cash groups and in-kind groups
      final cashGroupsResponse = await _groupService.getUserGroups(
        userId: user!.id,
        limit: 50,
      );
      
      final inKindGroupsResponse = await _groupService.getUserInKindGroups();

      final List<Map<String, dynamic>> allGroups = [];

      // Add cash groups
      if (cashGroupsResponse.success && cashGroupsResponse.data != null) {
        for (var group in cashGroupsResponse.data!) {
          allGroups.add(_groupToEkubMap(group));
        }
      }

      // Add in-kind groups
      if (inKindGroupsResponse.success && inKindGroupsResponse.data != null) {
        for (var group in inKindGroupsResponse.data!) {
          allGroups.add(_inKindGroupToEkubMap(group));
        }
      }

      ekubs.value = allGroups;
      
      if (allGroups.isEmpty) {
        errorMessage.value = 'You are not a member of any groups yet';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user groups: $e');
      }
      errorMessage.value = 'Failed to load your groups. Please try again.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _groupToEkubMap(Group group) {
    // Calculate completed rounds (simplified - in real app, this would come from rotation service)
    final totalRounds = group.targetMembers;
    final completedRounds = (group.currentMembers * 0.3).round(); // Placeholder calculation
    
    return {
      'id': group.id,
      'title': group.name,
      'frequency': group.frequency,
      'amount': '${group.contributionAmount.toStringAsFixed(0)} ETB',
      'completedRounds': completedRounds,
      'totalRounds': totalRounds,
      'type': 'cash',
      'group': group, // Store the full group object for navigation
    };
  }

  Map<String, dynamic> _inKindGroupToEkubMap(InKindGroup group) {
    final totalRounds = group.targetMembers;
    // InKindGroup doesn't have currentMembers, use targetMembers as placeholder
    final completedRounds = (group.targetMembers * 0.3).round();
    
    return {
      'id': group.id,
      'title': group.name,
      'frequency': group.frequency,
      'amount': '${group.contributionAmount.toStringAsFixed(0)} ETB',
      'completedRounds': completedRounds,
      'totalRounds': totalRounds,
      'type': 'in_kind',
      'group': group,
    };
  }

  Future<void> onRefresh() async {
    try {
      isRefreshing.value = true;
      await loadUserGroups();
      Get.snackbar(
        'Success',
        'Your groups have been refreshed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh groups',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  void onEkubTap(String ekubId) {
    // Find the group in the list
    final ekub = ekubs.firstWhereOrNull((e) => e['id'] == ekubId);
    if (ekub != null) {
      final group = ekub['group'];
      if (group is Group) {
        Get.toNamed('/group-detail', arguments: group);
      } else if (group is InKindGroup) {
        // TODO: Navigate to in-kind group detail when implemented
        Get.snackbar(
          'In-Kind Group',
          'In-kind group details coming soon',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void onActionTap(String action) {
    switch (action) {
      case 'payment':
        Get.toNamed(AppRoutes.selectPaymentMethod);
        break;
      case 'upcoming':
        Get.toNamed(AppRoutes.upcomingPayments);
        break;
      case 'lottery':
        Get.toNamed(AppRoutes.lottery);
        break;
      case 'current_ekub':
        // TODO: Navigate to current ekub
        Get.snackbar('current_ekub'.tr, 'current_ekub_page'.tr);
        break;
      case 'completed':
        Get.toNamed(AppRoutes.completedEkubs);
        break;
      case 'help':
        Get.toNamed(AppRoutes.faq);
        break;
      default:
        Get.snackbar(
          action,
          'action_tapped'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        // Already on Your Ekubs page
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}

