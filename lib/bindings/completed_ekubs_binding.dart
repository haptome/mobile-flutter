// Purpose: Dependency injection binding for completed ekubs page
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:get/get.dart';
import '../controllers/completed_ekubs_controller.dart';

class CompletedEkubsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompletedEkubsController>(() => CompletedEkubsController());
  }
}

