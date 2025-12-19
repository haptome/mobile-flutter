// Purpose: Controller for transactions page
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:et_digital_equb/core/widgets/transaction_card.dart';
import 'package:get/get.dart';

class TransactionsController extends GetxController {
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  void _loadTransactions() {
    // Sample data - in real app, this would come from API
    transactions.value = [
      {
        'id': '1',
        'type': TransactionType.deposit,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'From Fere\'s Driver\'s Equb',
        'ekubName': 'From Fere\'s Driver\'s Equb',
        'transactionId': 'FT12345678945',
        'rounds': '12th ${'round'.tr}',
      },
      {
        'id': '2',
        'type': TransactionType.withdrawal,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'To Fere\'s Driver\'s Equb',
      },
      {
        'id': '3',
        'type': TransactionType.deposit,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'From Fere\'s Driver\'s Equb',
      },
      {
        'id': '4',
        'type': TransactionType.withdrawal,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'To Fere\'s Driver\'s Equb',
      },
      {
        'id': '5',
        'type': TransactionType.deposit,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'From Fere\'s Driver\'s Equb',
      },
      {
        'id': '6',
        'type': TransactionType.failed,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'To Fere\'s Driver\'s Equb',
      },
      {
        'id': '7',
        'type': TransactionType.rewards,
        'amount': '5,000.00 Birr',
        'date': 'Oct, 24,2018.E.C.',
        'source': 'From ET-Equb',
      },
    ];
  }

  void onRefresh() {
    // TODO: Refresh transactions from API
    _loadTransactions();
    Get.snackbar(
      'refreshed'.tr,
      'transactions_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
        break;
      case 2:
        // Already on Transactions page
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}

