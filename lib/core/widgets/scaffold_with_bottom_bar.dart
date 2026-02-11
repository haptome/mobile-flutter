// Purpose: Scaffold wrapper that includes the bottom navigation bar
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_assets.dart';
import '../../controllers/bottom_nav_controller.dart';
import 'custom_bottom_bar.dart';

/// Scaffold wrapper that includes persistent bottom navigation
class ScaffoldWithBottomBar extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const ScaffoldWithBottomBar({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Get or create the bottom nav controller
    final bottomNavController = Get.isRegistered<BottomNavController>()
        ? Get.find<BottomNavController>()
        : Get.put(BottomNavController());

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: body,
      bottomNavigationBar: Obx(
        () => CustomBottomBar(
          index: bottomNavController.index.value,
          items: [
            BottomBarItem(
              selectedIcon: AppAssets.homeIcon,
              unselectedIcon: AppAssets.homeIcon,
              label: 'home'.tr,
              onClick: (i) {
                bottomNavController.switchTab(i);
                Get.offAllNamed('/home');
              },
            ),
            BottomBarItem(
              selectedIcon: AppAssets.personsIcon,
              unselectedIcon: AppAssets.personsIcon,
              label: 'your_ekubs'.tr,
              onClick: (i) {
                bottomNavController.switchTab(i);
                Get.offAllNamed('/ekubs');
              },
            ),
            BottomBarItem(
              selectedIcon: AppAssets.transactionIcon,
              unselectedIcon: AppAssets.transactionIcon,
              label: 'transactions'.tr,
              onClick: (i) {
                bottomNavController.switchTab(i);
                Get.offAllNamed('/transactions');
              },
            ),
            BottomBarItem(
              selectedIcon: AppAssets.profileIcon,
              unselectedIcon: AppAssets.profileIcon,
              label: 'profile'.tr,
              onClick: (i) {
                bottomNavController.switchTab(i);
                Get.offAllNamed('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
