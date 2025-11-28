// Purpose: Global bottom navigation controller
// Author: haptome H.
// Linked Spec Section: Navigation

import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
    _navigateToRoute(index);
  }

  void _navigateToRoute(int index) {
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

  void setIndex(int index) {
    currentIndex.value = index;
  }
}

