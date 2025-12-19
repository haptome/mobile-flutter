// Purpose: Controller for Terms & Conditions page
// Author: haptome H.
// Linked Spec Section: Terms & Conditions Page

import 'package:get/get.dart';

class TermsConditionsController extends GetxController {
  final RxBool isAgreeing = false.obs;

  void onAgreeContinue() async {
    isAgreeing.value = true;

    try {
      // TODO: Save user agreement to backend
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'success'.tr,
        'terms_accepted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'acceptance_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAgreeing.value = false;
    }
  }
}

