// Purpose: Controller for payment selection
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:get/get.dart';

class PaymentController extends GetxController {
  final RxString selectedPaymentMethod = ''.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab

  @override
  void onInit() {
    super.onInit();
    // Set initial state if coming from Your Ekubs page
    currentBottomNavIndex.value = 1;
  }

  // Payment method descriptions
  final String chapaDescription =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  final String arifpayDescription =
      'Secure payment gateway for Ethiopian businesses. Fast and reliable transactions.';
  final String santimPayDescription =
      'Simple and secure payment solution. Pay with ease using SANTIM PAY.';
  final String telebirrDescription =
      'Pay directly using your Telebirr account. Quick and convenient.';

  void selectPaymentMethod(String method) {
    if (selectedPaymentMethod.value == method) {
      selectedPaymentMethod.value = ''; // Collapse if same
    } else {
      selectedPaymentMethod.value = method;
    }
  }

  void proceedToPayment(String method) {
    // TODO: Navigate to payment processing page
    Get.snackbar(
      'payment'.tr,
      'proceeding_to_payment'.tr.replaceAll('{method}', method),
      snackPosition: SnackPosition.BOTTOM,
    );
    // Get.toNamed('/payment-process', arguments: {'method': method});
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
