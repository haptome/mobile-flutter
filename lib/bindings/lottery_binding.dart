// Purpose: Dependency injection binding for lottery page
// Author: haptome H.
// Linked Spec Section: Lottery Page

import 'package:get/get.dart';
import '../controllers/lottery_controller.dart';

class LotteryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LotteryController>(() => LotteryController());
  }
}

