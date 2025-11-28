// Purpose: Dependency injection binding for FAQ/Help page
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:get/get.dart';
import '../controllers/faq_controller.dart';

class FaqBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaqController>(() => FaqController());
  }
}

