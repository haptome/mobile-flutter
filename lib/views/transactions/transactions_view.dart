// Purpose: Transactions page
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transactions_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/main_scaffold.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();

    return MainScaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Light grey background
      initialBottomNavIndex: 2,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'transactions'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_outlined,
                color: AppColors.textDark,
              ),
              onPressed: controller.onRefresh,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Transactions list
            Expanded(
              child: Obx(
                () {
                  if (controller.transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'no_transactions'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textLightGray,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return TransactionCard(
                        id: transaction['id'] ?? '',
                        type: transaction['type'] as TransactionType,
                        amount: transaction['amount'] ?? '',
                        date: transaction['date'] ?? '',
                        source: transaction['source'] ?? '',
                        ekubName: transaction['ekubName'] as String?,
                        transactionId: transaction['transactionId'] as String?,
                        rounds: transaction['rounds'] as String?,
                        initiallyExpanded: index == 0, // First card expanded
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

