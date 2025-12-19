// Purpose: Controller for lottery page
// Author: haptome H.
// Linked Spec Section: Lottery Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:get/get.dart';

class LotteryController extends GetxController {
  final RxBool isSpinning = false.obs;
  final RxInt lastWonPrize = 0.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab

  // Prize amounts in Birr
  final List<int> prizes = [10, 20, 50, 90, 100, 200, 500, 800, 1000, 1500];

  @override
  void onInit() {
    super.onInit();
  }

  void spin() {
    if (isSpinning.value) return;
    isSpinning.value = true;
    lastWonPrize.value = 0;
  }

  void onSpinComplete(int prize) {
    isSpinning.value = false;
    lastWonPrize.value = prize;

    Get.snackbar(
      'congratulations'.tr,
      'you_won'.tr.replaceAll('{amount}', '$prize'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
    );

    // TODO: Save prize to user's account via API
  }

  void onRefresh() {
    // TODO: Refresh lottery data
    Get.snackbar(
      'refreshed'.tr,
      'lottery_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBottomNavTap(int index) {
    currentBottomNavIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
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

