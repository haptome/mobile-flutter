// Purpose: Dependency injection binding for transactions page
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}

