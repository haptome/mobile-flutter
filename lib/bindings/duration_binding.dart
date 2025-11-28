// Purpose: Dependency injection binding for Duration page
// Author: haptome H.
// Linked Spec Section: Duration Page

import 'package:get/get.dart';
import '../controllers/duration_controller.dart';

class DurationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DurationController>(() => DurationController());
  }
}

