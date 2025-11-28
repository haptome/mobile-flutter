// Purpose: Dependency injection binding for profile page
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

