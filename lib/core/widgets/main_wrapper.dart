// Purpose: Main wrapper with bottom navigation for authenticated screens
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_bottom_nav.dart';
import '../routes/app_routes.dart';
import '../app_assets.dart';

/// Main wrapper that provides bottom navigation for main app screens
class MainWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex)
            return; // Don't navigate if already on this screen

          final route = [
            AppRoutes.home,
            AppRoutes.ekubs,
            AppRoutes.transactions,
            AppRoutes.profile,
          ][index];

          Get.offAllNamed(route);
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
    );
  }
}
