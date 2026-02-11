// Purpose: Main wrapper with bottom navigation for authenticated screens
// Author: Auto-generated

import 'package:et_digital_equb/features/home/presentation/home_screen.dart';
import 'package:et_digital_equb/features/profile/profile_view.dart';
import 'package:et_digital_equb/features/transactions/transactions_view.dart';
import 'package:et_digital_equb/features/your_ekubs/your_ekubs_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_assets.dart';
import '../../controllers/bottom_nav_controller.dart';
import 'custom_bottom_bar.dart';

/// Main wrapper that provides bottom navigation for main app screens
class MainWrapper extends StatelessWidget {
  final int initialIndex;

  const MainWrapper({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    // Initialize the bottom nav controller
    final bottomNavController = Get.put(BottomNavController());

    // Set initial index if provided
    if (initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bottomNavController.index.value = initialIndex;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: bottomNavController.index.value,
                  children: const [
                    HomeScreen(),
                    YourEkubsView(),
                    TransactionsView(),
                    ProfileView(),
                  ],
                ),
              ),
              CustomBottomBar(
                index: bottomNavController.index.value,
                items: [
                  BottomBarItem(
                    selectedIcon: AppAssets.homeIcon,
                    unselectedIcon: AppAssets.homeIcon,
                    label: 'home'.tr,
        
                    onClick: (i) => bottomNavController.switchTab(i),
                  ),
                  BottomBarItem(
                    selectedIcon: AppAssets.personsIcon,
                    unselectedIcon: AppAssets.personsIcon,
                    label: 'your_ekubs'.tr,
                    onClick: (i) => bottomNavController.switchTab(i),
                  ),
                  BottomBarItem(
                    selectedIcon: AppAssets.transactionIcon,
                    unselectedIcon: AppAssets.transactionIcon,
                    label: 'transactions'.tr,
                    onClick: (i) => bottomNavController.switchTab(i),
                  ),
                  BottomBarItem(
                    selectedIcon: AppAssets.profileIcon,
                    unselectedIcon: AppAssets.profileIcon,
                    label: 'profile'.tr,
                    onClick: (i) => bottomNavController.switchTab(i),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
