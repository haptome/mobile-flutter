// Purpose: Home controller
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  
  final RxInt currentBottomNavIndex = 0.obs;
  final RxBool isAccountVerified = false.obs; // Set to false to show banner

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      await _authService.getProfile();
      // Check verification status from user data
      // isAccountVerified.value = _authService.currentUser.value?.kycStatus == 'verified';
    } catch (e) {
      // Silently handle error for UI-only mode
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
    Get.snackbar(
      'Info',
      'Verification page will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
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

  void onViewAllDuration() {
    Get.toNamed('/duration');
  }
}

