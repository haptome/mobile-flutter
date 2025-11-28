// Purpose: Home view matching design
// Author: haptome H.
// Linked Spec Section: Home Screen

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../controllers/home_controller.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/home_app_bar.dart';
import '../../widgets/verification_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/section_card.dart';
import '../../widgets/promotional_banner.dart';
import '../../widgets/main_scaffold.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final authService = AuthService.to;

    return MainScaffold(
      backgroundColor: AppColors.backgroundLightGray,
      initialBottomNavIndex: 0,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: Obx(
          () {
            final user = authService.currentUser.value;
            final userName = user?.fullName?.split(' ').first ?? 'User';
            final initials = user?.fullName
                    ?.split(' ')
                    .map((n) => n[0])
                    .take(2)
                    .join()
                    .toUpperCase() ??
                'NB';

            return HomeAppBar(
              userName: userName,
              userInitials: initials,
              onNotificationTap: () {
                Get.snackbar('Notifications', 'Notifications page');
              },
              onLanguageTap: () {
                Get.snackbar('Language', 'Language selector');
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verification Banner
                    Obx(
                      () => controller.isAccountVerified.value
                          ? const SizedBox.shrink()
                          : VerificationBanner(
                              onVerifyTap: controller.onVerifyAccountTap,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Ekub Type Section
                    SectionHeader(
                      title: 'ekub_type'.tr,
                      onViewAllTap: controller.onViewAllEkubTypes,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          SectionCard(
                            icon: Iconsax.car,
                            label: 'for_drivers'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.shop,
                            label: 'for_merchant'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.people,
                            label: 'for_employee'.tr,
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // In-Kind Section
                    SectionHeader(
                      title: 'in_kind'.tr,
                      onViewAllTap: controller.onViewAllInKind,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          SectionCard(
                            icon: Iconsax.car,
                            label: 'cars'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.monitor,
                            label: 'television'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.box,
                            label: 'fridge'.tr,
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Promotional Banner
                    const PromotionalBanner(),
                    const SizedBox(height: 24),

                    // Duration Section
                    SectionHeader(
                      title: 'duration'.tr,
                      onViewAllTap: controller.onViewAllDuration,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          SectionCard(
                            icon: Iconsax.calendar,
                            label: 'three_months'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.calendar,
                            label: 'six_months'.tr,
                            onTap: null,
                          ),
                          const SizedBox(width: 16),
                          SectionCard(
                            icon: Iconsax.calendar,
                            label: 'one_year'.tr,
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
