// Purpose: Dependency injection binding for home
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

