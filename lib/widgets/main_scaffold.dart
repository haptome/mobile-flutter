// Purpose: Main scaffold with bottom navigation bar
// Author: haptome H.
// Linked Spec Section: Navigation

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../theme/app_colors.dart';
import 'bottom_nav_bar.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool showBottomNav;
  final int? initialBottomNavIndex;

  const MainScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.showBottomNav = true,
    this.initialBottomNavIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize bottom nav controller if not already initialized
    final bottomNavController = Get.put(BottomNavController(), permanent: true);
    
    // Set initial index if provided
    if (initialBottomNavIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bottomNavController.setIndex(initialBottomNavIndex!);
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
      appBar: appBar,
      body: body,
      bottomNavigationBar: showBottomNav
          ? Obx(
              () => BottomNavBar(
                currentIndex: bottomNavController.currentIndex.value,
                onTap: bottomNavController.changeIndex,
              ),
            )
          : null,
    );
  }
}

