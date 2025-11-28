// Purpose: Dependency injection binding for payment pages
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(() => PaymentController());
  }
}

