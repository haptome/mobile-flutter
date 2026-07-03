// Purpose: Controller for Your Ekubs page
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/extensions/number_formatting.dart';
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
    
    // Listen to authentication state changes
    ever(_authService.isAuthenticated, (isAuth) {
      if (isAuth) {
        // User just logged in, load data
        loadUserGroups();
      } else {
        // User logged out, clear data
        ekubs.clear();
        completedEkubs.clear();
      }
    });
    
    // Also load data immediately if already authenticated
    if (_authService.isAuthenticated.value) {
      loadUserGroups();
    }
  }
 @override
  void onReady() {
    super.onReady();
    // Also try to load data when controller is ready
    // This handles the case where user logs in after controller initialization
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

      // Separate active vs completed from the user's own groups
      final List<Map<String, dynamic>> activeGroups = [];
      final List<Map<String, dynamic>> completedGroups = [];

      // Add cash groups — split by status
      if (cashGroupsResponse.success && cashGroupsResponse.data != null) {
        for (var group in cashGroupsResponse.data!) {
          if (group.status == 'completed') {
            completedGroups.add(_groupToCompletedEkubMap(group));
          } else {
            activeGroups.add(_groupToEkubMap(group));
          }
        }
      }

      // Add in-kind groups
      if (inKindGroupsResponse.success && inKindGroupsResponse.data != null) {
        for (var group in inKindGroupsResponse.data!) {
          activeGroups.add(_inKindGroupToEkubMap(group));
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
    try {
      // Calculate completed rounds based on start date and frequency
      final completedRounds = _calculateCompletedRounds(
        group.startDate,
        group.frequency,
        group.targetMembers,
      );
      final totalRounds = group.targetMembers;

      // Safely format the contribution amount
      String formattedAmount;
      try {
        formattedAmount = group.contributionAmount.toCurrencyShort();
      } catch (e) {
        // Fallback if formatting fails
        formattedAmount = '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}';
      }

      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': formattedAmount,
        'completedRounds': completedRounds,
        'totalRounds': totalRounds,
        'type': 'cash',
        'group': group, // Store the full group object for navigation
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error converting group to ekub map: $e');
      }
      // Return a safe fallback
      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}',
        'completedRounds': 0,
        'totalRounds': group.targetMembers,
        'type': 'cash',
        'group': group,
      };
    }
  }

  Map<String, dynamic> _inKindGroupToEkubMap(InKindGroup group) {
    try {
      // Calculate completed rounds based on start date and frequency
      final completedRounds = _calculateCompletedRounds(
        group.startDate,
        group.frequency,
        group.targetMembers,
      );
      final totalRounds = group.targetMembers;

      // Safely format the contribution amount
      String formattedAmount;
      try {
        formattedAmount = group.contributionAmount.toCurrencyShort();
      } catch (e) {
        // Fallback if formatting fails
        formattedAmount = '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}';
      }

      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': formattedAmount,
        'completedRounds': completedRounds,
        'totalRounds': totalRounds,
        'type': 'in_kind',
        'group': group,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error converting in-kind group to ekub map: $e');
      }
      // Return a safe fallback
      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}',
        'completedRounds': 0,
        'totalRounds': group.targetMembers,
        'type': 'in_kind',
        'group': group,
      };
    }
  }

  /// Calculate completed rounds based on start date and frequency
  int _calculateCompletedRounds(
    DateTime? startDate,
    String frequency,
    int targetMembers,
  ) {
    try {
      if (startDate == null) return 0;

      final now = DateTime.now();
      
      // If start date is in the future, no rounds completed yet
      if (startDate.isAfter(now)) return 0;

      final daysSinceStart = now.difference(startDate).inDays;

      int completedRounds;
      switch (frequency.toLowerCase()) {
        case 'daily':
          completedRounds = daysSinceStart;
          break;
        case 'weekly':
          completedRounds = (daysSinceStart / 7).floor();
          break;
        case 'monthly':
          // Calculate months difference more accurately
          completedRounds = _calculateMonthsDifference(startDate, now);
          break;
        case 'hourly':
          // Handle hourly frequency
          final hoursSinceStart = now.difference(startDate).inHours;
          completedRounds = hoursSinceStart;
          break;
        default:
          completedRounds = 0;
      }

      // Cap at target members (can't have more completed rounds than total rounds)
      return completedRounds.clamp(0, targetMembers);
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating completed rounds: $e');
      }
      return 0; // Safe fallback
    }
  }

  /// Calculate the number of months between two dates
  int _calculateMonthsDifference(DateTime start, DateTime end) {
    int months = (end.year - start.year) * 12 + (end.month - start.month);
    
    // If the end day is before the start day, subtract one month
    if (end.day < start.day) {
      months--;
    }
    
    return months.clamp(0, 999999); // Use a large finite number instead of infinity
  }

  Map<String, dynamic> _groupToCompletedEkubMap(Group group) {
    try {
      // For completed groups, all rounds are completed
      final totalRounds = group.targetMembers;
      final completedRounds = totalRounds; // All rounds completed
      final totalAmount = group.contributionAmount * totalRounds;

      // Safely format amounts
      String formattedAmount;
      String formattedTotalAmount;
      try {
        formattedAmount = group.contributionAmount.toCurrencyShort();
        formattedTotalAmount = totalAmount.toCurrencyShort();
      } catch (e) {
        // Fallback if formatting fails
        formattedAmount = '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}';
        formattedTotalAmount = '${'etb'.tr} ${totalAmount.toStringAsFixed(0)}';
      }

      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': formattedAmount,
        'completedRounds': completedRounds,
        'totalRounds': totalRounds,
        'totalAmount': formattedTotalAmount,
        'type': 'cash_completed',
        'group': group,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error converting completed group to ekub map: $e');
      }
      // Return a safe fallback
      final totalRounds = group.targetMembers;
      final totalAmount = group.contributionAmount * totalRounds;
      return {
        'id': group.id,
        'title': group.name,
        'frequency': group.frequency,
        'amount': '${'etb'.tr} ${group.contributionAmount.toStringAsFixed(0)}',
        'completedRounds': totalRounds,
        'totalRounds': totalRounds,
        'totalAmount': '${'etb'.tr} ${totalAmount.toStringAsFixed(0)}',
        'type': 'cash_completed',
        'group': group,
      };
    }
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
        Get.toNamed('/in-kind-detail', arguments: group);
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
