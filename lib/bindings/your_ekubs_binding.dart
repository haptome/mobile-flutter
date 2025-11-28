// Purpose: Dependency injection binding for Your Ekubs page
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:get/get.dart';
import '../controllers/your_ekubs_controller.dart';

class YourEkubsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YourEkubsController>(() => YourEkubsController());
  }
}

