// Purpose: Your Ekubs page view
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/action_grid.dart';
import 'package:et_digital_equb/core/widgets/ekub_progress_carousel.dart';
import 'package:et_digital_equb/core/widgets/user_header.dart';
import 'package:et_digital_equb/core/widgets/app_bottom_nav.dart';
import 'package:et_digital_equb/core/app_assets.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/your_ekubs_controller.dart';



class YourEkubsView extends StatefulWidget {
  const YourEkubsView({super.key});

  @override
  State<YourEkubsView> createState() => _YourEkubsViewState();
}

class _YourEkubsViewState extends State<YourEkubsView> {
  int _currentNavIndex = 1; // Your Ekubs is index 1

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<YourEkubsController>();
    final authService = AuthService.to;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // User Header - Wrap only the user data in Obx
                      Obx(
                        () {
                          final user = authService.currentUser.value;
                          final userName = user?.fullName ?? 'User';
                          final initials = user?.fullName
                                  ?.split(' ')
                                  .map((n) => n[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase() ??
                              'NB';

                          return UserHeader(
                            userName: userName,
                            userInitials: initials,
                            onRefresh: controller.onRefresh,
                          );
                        },
                      ),
                      // Ekub Progress Carousel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Obx(
                          () {
                            // Access observable list properties directly - GetX tracks RxList
                            // Access length to ensure GetX properly tracks the observable
                            if (controller.ekubs.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            // Convert to List for the widget
                            final ekubsList =
                                List<Map<String, dynamic>>.from(controller.ekubs);
                            return EkubProgressCarousel(
                              ekubs: ekubsList,
                              onEkubTap: controller.onEkubTap,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action Grid
                      Expanded(
                        child: ActionGrid(
                          onActionTap: controller.onActionTap,
                        ),
                      ),
                    ],
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
