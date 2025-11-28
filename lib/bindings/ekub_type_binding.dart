// Purpose: Dependency injection binding for Ekub Type page
// Author: haptome H.
// Linked Spec Section: Ekub Type Page

import 'package:get/get.dart';
import '../controllers/ekub_type_controller.dart';

class EkubTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EkubTypeController>(() => EkubTypeController());
  }
}

