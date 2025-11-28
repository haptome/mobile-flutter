// Purpose: Your Ekubs page view
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/your_ekubs_controller.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_header.dart';
import '../../widgets/ekub_progress_carousel.dart';
import '../../widgets/action_grid.dart';
import '../../widgets/main_scaffold.dart';

class YourEkubsView extends StatelessWidget {
  const YourEkubsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<YourEkubsController>();
    final authService = AuthService.to;

    return MainScaffold(
      backgroundColor: AppColors.backgroundLightGray,
      initialBottomNavIndex: 1,
      body: SafeArea(
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
    );
  }
}
