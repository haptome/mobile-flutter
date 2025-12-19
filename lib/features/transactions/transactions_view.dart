// Purpose: Transactions page
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/transaction_card.dart';
import 'package:et_digital_equb/core/widgets/app_bottom_nav.dart';
import 'package:et_digital_equb/core/app_assets.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transactions_controller.dart';


class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  int _currentNavIndex = 2; // Transactions is index 2

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Light grey background
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
                color: AppColors.black,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_outlined,
                color: AppColors.black,
              ),
              onPressed: controller.onRefresh,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
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
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 80.0, // Padding for bottom nav
                        ),
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
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == _currentNavIndex) return; // Don't navigate if already on this screen
                setState(() {
                  _currentNavIndex = index;
                });
                final route = [
                  AppRoutes.home,
                  AppRoutes.ekubs,
                  AppRoutes.transactions,
                  AppRoutes.profile,
                ][index];
                Navigator.of(context).pushNamedAndRemoveUntil(
                  route,
                  (route) => false, // Remove all previous routes
                );
              },
              items: const [
                BottomNavItem(
                  iconPath: AppAssets.homeIcon,
                  label: 'Home',
                  route: '/home',
                ),
                BottomNavItem(
                  iconPath: AppAssets.personsIcon,
                  label: 'Your Ekubs',
                  route: '/ekubs',
                ),
                BottomNavItem(
                  iconPath: AppAssets.transactionIcon,
                  label: 'Transactions',
                  route: '/transactions',
                ),
                BottomNavItem(
                  iconPath: AppAssets.profileIcon,
                  label: 'Profile',
                  route: '/profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

