// Purpose: Your Ekubs page view
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/action_grid.dart';
import 'package:et_digital_equb/core/widgets/ekub_progress_carousel.dart';
import 'package:et_digital_equb/core/widgets/user_header.dart';
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
                      Obx(() {
                        final user = authService.currentUser.value;
                        final userName = user?.fullName ?? 'User';
                        final initials =
                            user?.fullName
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
                      }),
                      // Ekub Progress Carousel with Loading/Error States
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return _buildSkeletonLoader();
                          }

                          if (controller.errorMessage.value.isNotEmpty &&
                              controller.ekubs.isEmpty) {
                            return _buildErrorWidget(controller);
                          }

                          if (controller.ekubs.isEmpty) {
                            return _buildEmptyState();
                          }

                          // Convert to List for the widget
                          final ekubsList = List<Map<String, dynamic>>.from(
                            controller.ekubs,
                          );
                          return EkubProgressCarousel(
                            ekubs: ekubsList,
                            onEkubTap: controller.onEkubTap,
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // Action Grid
                      Expanded(
                        child: ActionGrid(onActionTap: controller.onActionTap),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(YourEkubsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.loadUserGroups(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a group to get started!',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
