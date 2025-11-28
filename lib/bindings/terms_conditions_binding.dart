// Purpose: Dependency injection binding for Terms & Conditions page
// Author: haptome H.
// Linked Spec Section: Terms & Conditions Page

import 'package:get/get.dart';
import '../controllers/terms_conditions_controller.dart';

class TermsConditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionsController>(() => TermsConditionsController());
  }
}

