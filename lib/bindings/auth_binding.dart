// Purpose: Dependency injection binding for authentication
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

