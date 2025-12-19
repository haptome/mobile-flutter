// Purpose: Controller for Your Ekubs page
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:get/get.dart';

class YourEkubsController extends GetxController {
  // Ekub data - in real app, this would come from API
  final RxList<Map<String, dynamic>> ekubs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEkubs();
  }

  void _loadEkubs() {
    // Load sample data
    ekubs.value = [
      {
        'id': '1',
        'title': 'fridge_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'completedRounds': 2,
        'totalRounds': 5,
      },
      {
        'id': '2',
        'title': 'car_equb'.tr,
        'frequency': 'monthly'.tr,
        'amount': '10,000 Birr',
        'completedRounds': 1,
        'totalRounds': 12,
      },
    ];
  }

  Future<void> onRefresh() async {
    // TODO: Fetch ekubs from API
    await Future.delayed(const Duration(seconds: 1));
    _loadEkubs();
    Get.snackbar(
      'refreshed'.tr,
      'ekubs_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onEkubTap(String ekubId) {
    // TODO: Navigate to ekub details
    Get.snackbar(
      'ekub_details'.tr,
      'ekub_id: $ekubId',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onActionTap(String action) {
    switch (action) {
      case 'payment':
        Get.toNamed('/select-payment-method');
        break;
      case 'upcoming':
        Get.toNamed('/upcoming-payments');
        break;
      case 'lottery':
        Get.toNamed('/lottery');
        break;
      case 'current_ekub':
        // TODO: Navigate to current ekub
        Get.snackbar('current_ekub'.tr, 'current_ekub_page'.tr);
        break;
      case 'completed':
        Get.toNamed('/completed-ekubs');
        break;
      case 'help':
        Get.toNamed('/faq');
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

