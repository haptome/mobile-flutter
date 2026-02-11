// Purpose: Controller for managing bottom navigation state
// Author: Generated for IndexedStack navigation

import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/your_ekubs_controller.dart';
import '../../controllers/transactions_controller.dart';
import '../../controllers/profile_controller.dart';

class BottomNavController extends GetxController {
  final RxInt index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-register all controllers to avoid initialization delays
    _registerControllers();
  }

  void switchTab(int newIndex) {
    if (index.value == newIndex) return;

    index.value = newIndex;

    // Ensure the controller for the new tab is registered
    _ensureControllerRegistered(newIndex);
    
    // Notify the transactions controller when switching to transactions tab
    if (newIndex == 2 && Get.isRegistered<TransactionsController>()) {
      final transactionsController = Get.find<TransactionsController>();
      transactionsController.loadTransactionsIfNeeded();
    }
  }

  void _registerControllers() {
    // Register all controllers at startup
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    if (!Get.isRegistered<YourEkubsController>()) {
      Get.put(YourEkubsController());
    }
    if (!Get.isRegistered<TransactionsController>()) {
      Get.put(TransactionsController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }

  void _ensureControllerRegistered(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController());
        }
        break;
      case 1: // Your Ekubs
        if (!Get.isRegistered<YourEkubsController>()) {
          Get.put(YourEkubsController());
        }
        break;
      case 2: // Transactions
        if (!Get.isRegistered<TransactionsController>()) {
          Get.put(TransactionsController());
        }
        break;
      case 3: // Profile
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
        break;
    }
  }
}
