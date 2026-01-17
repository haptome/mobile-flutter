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
  final RxList<Map<String, dynamic>> completedEkubs =
      <Map<String, dynamic>>[].obs;
  final RxBool showCompletedEkubs = true.obs;
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

      // Also fetch completed groups
      final completedCashGroupsResponse = await _groupService.getGroups(
        status: 'completed',
        limit: 50,
      );

      final List<Map<String, dynamic>> allGroups = [];

      // Separate completed groups
      final List<Map<String, dynamic>> activeGroups = [];
      final List<Map<String, dynamic>> completedGroups = [];

      // Add cash groups
      if (cashGroupsResponse.success && cashGroupsResponse.data != null) {
        for (var group in cashGroupsResponse.data!) {
          activeGroups.add(_groupToEkubMap(group));
        }
      }

      // Add in-kind groups
      if (inKindGroupsResponse.success && inKindGroupsResponse.data != null) {
        for (var group in inKindGroupsResponse.data!) {
          activeGroups.add(_inKindGroupToEkubMap(group));
        }
      }

      // Add completed cash groups
      if (completedCashGroupsResponse.success &&
          completedCashGroupsResponse.data != null) {
        for (var group in completedCashGroupsResponse.data!) {
          completedGroups.add(_groupToCompletedEkubMap(group));
        }
      }

      ekubs.value = activeGroups;
      completedEkubs.value = completedGroups;

      if (activeGroups.isEmpty && completedGroups.isEmpty) {
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
    final completedRounds = (group.currentMembers * 0.3)
        .round(); // Placeholder calculation

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

  Map<String, dynamic> _groupToCompletedEkubMap(Group group) {
    // For completed groups, all rounds are completed
    final totalRounds = group.targetMembers;
    final completedRounds = totalRounds; // All rounds completed
    final totalAmount = group.contributionAmount * totalRounds;

    return {
      'id': group.id,
      'title': group.name,
      'frequency': group.frequency,
      'amount': '${group.contributionAmount.toStringAsFixed(0)} ETB',
      'completedRounds': completedRounds,
      'totalRounds': totalRounds,
      'totalAmount': '${totalAmount.toStringAsFixed(0)} ETB',
      'type': 'cash_completed',
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
    // Find the group in the active ekubs list
    var ekub = ekubs.firstWhereOrNull((e) => e['id'] == ekubId);

    // If not found in active ekubs, search in completed ekubs
    if (ekub == null) {
      ekub = completedEkubs.firstWhereOrNull((e) => e['id'] == ekubId);
    }

    if (ekub != null) {
      final group = ekub['group'];
      final type = ekub['type'];

      if (type == 'cash_completed') {
        // For completed ekubs, navigate to a completed group detail page
        Get.toNamed(
          '/group-detail',
          arguments: group,
        ); // Using same route but could have different handling
      } else if (group is Group) {
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

  void toggleCompletedEkubs() {
    showCompletedEkubs.value = !showCompletedEkubs.value;
  }

  void onCreateEkub() {
    // Navigate to Ekub creation page
    Get.toNamed(AppRoutes.createGroup);
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
