// Purpose: Home controller
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  final GroupService _groupService = GroupService.to;

  final RxInt currentBottomNavIndex = 0.obs;
  final RxBool isAccountVerified = false.obs; // Set to false to show banner
  final RxList<category_models.Category> cashCategories =
      <category_models.Category>[].obs;
  final RxList<category_models.Category> inKindCategories =
      <category_models.Category>[].obs;
  final RxBool isLoadingCategories = true.obs;
  final RxBool isLoadingInKindCategories = true.obs;
  final RxMap<String, int> durationGroupsCount = <String, int>{}.obs; // frequency -> count
  final RxBool isLoadingDuration = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadCashCategories();
    loadInKindCategories();
    loadDurationGroups();
  }

  Future<void> loadUserData() async {
    try {
      await _authService.getProfile();
      // Check verification status from user data
      final kycStatus = _authService.currentUser.value?.kycStatus;
      isAccountVerified.value = kycStatus == 'verified';
    } catch (e) {
      // Silently handle error for UI-only mode
    }
  }

  Future<void> loadCashCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _groupService.getCategories(
        categoryType: 'cash',
        isActive: true,
        limit: 3, // Only show first 3 categories on home
      );

      if (response.success && response.data != null) {
        cashCategories.value = List<category_models.Category>.from(
          response.data!,
        );
      }
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void onBottomNavTap(int index) {
    currentBottomNavIndex.value = index;
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Get.toNamed('/your-ekubs');
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }

  void onVerifyAccountTap() {
    // Navigate to verification page
    Get.toNamed('/verification');
  }

  void logout() {
    _authService.logout();
  }

  void onViewAllEkubTypes() {
    Get.toNamed('/ekub-type');
  }

  void onViewAllInKind() {
    Get.toNamed('/in-kind');
  }

  Future<void> loadInKindCategories() async {
    try {
      isLoadingInKindCategories.value = true;
      final response = await _groupService.getCategories(
        categoryType: 'in_kind',
        isActive: true,
        limit: 3, // Only show first 3 categories on home
      );

      if (response.success && response.data != null) {
        inKindCategories.value = List<category_models.Category>.from(
          response.data!,
        );
      }
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingInKindCategories.value = false;
    }
  }

  Future<void> loadDurationGroups() async {
    try {
      isLoadingDuration.value = true;
      // Fetch groups to count by frequency
      final response = await _groupService.getGroups(
        status: 'active',
        limit: 100, // Get more groups to count frequencies
      );

      if (response.success && response.data != null) {
        final groups = response.data!;
        final counts = <String, int>{};
        
        // Count groups by frequency
        for (var group in groups) {
          final frequency = group.frequency.toLowerCase();
          counts[frequency] = (counts[frequency] ?? 0) + 1;
        }
        
        durationGroupsCount.value = counts;
      }
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingDuration.value = false;
    }
  }

  void onCategoryTap(category_models.Category category) {
    Get.toNamed('/category-detail', arguments: category);
  }

  void onInKindCategoryTap(category_models.Category category) {
    Get.toNamed('/category-detail', arguments: category);
  }

  void onDurationTap(String frequency) {
    // Navigate to duration page with frequency filter
    Get.toNamed('/duration', arguments: {'frequency': frequency});
  }

  void onViewAllDuration() {
    Get.toNamed('/duration');
  }
}
