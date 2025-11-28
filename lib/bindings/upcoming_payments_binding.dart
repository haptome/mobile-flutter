// Purpose: Dependency injection binding for upcoming payments page
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:get/get.dart';
import '../controllers/upcoming_payments_controller.dart';

class UpcomingPaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpcomingPaymentsController>(() => UpcomingPaymentsController());
  }
}

