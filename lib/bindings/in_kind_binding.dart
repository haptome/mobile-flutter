// Purpose: Dependency injection binding for In-Kind page
// Author: haptome H.
// Linked Spec Section: In-Kind Page

import 'package:get/get.dart';
import '../controllers/in_kind_controller.dart';

class InKindBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InKindController>(() => InKindController());
  }
}

