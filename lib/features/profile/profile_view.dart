// Purpose: Profile page
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/logout_button.dart';
import 'package:et_digital_equb/core/widgets/profile_user_card.dart';
import 'package:et_digital_equb/core/widgets/section_header.dart';
import 'package:et_digital_equb/core/widgets/section_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'profile'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              'manage_personal_account'.tr,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLightGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Obx(() {
                final user = controller.user;
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 80,
                  ), // Padding for bottom nav
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Profile Card
                      Stack(
                        children: [
                          ProfileUserCard(
                            profileImageUrl: user['profileImageUrl'] as String?,
                            userName: user['name'] ?? 'user_name'.tr,
                            phoneNumber: user['phone'] ?? '',
                            
                            location: user['location'] ?? '',
                            level: user['level'] ?? '1',
                            onEditProfile: controller.onEditProfile,
                          ),
                          // Loading overlay
                          if (controller.isUploadingPhoto.value)
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Wallets Section
                      SectionHeader(title: 'wallets'.tr),
                      SectionItem(
                        icon: Iconsax.wallet_1,
                        label: 'wallet_and_payments'.tr,
                        onTap: controller.onWalletTap,
                        off: false,
                      ),
                      // Profile Management Section
                      SectionHeader(title: 'profile_management'.tr),
                      SectionItem(
                        icon: Iconsax.user,
                        label: 'account_setting'.tr,
                        onTap: () {
                          Navigator.of(context).pushNamed('/account-setting');
                        },
                      ),
                      SectionItem(
                        icon: Iconsax.verify,
                        label: 'verification'.tr,
                        onTap: () {
                          Navigator.of(context).pushNamed('/verification');
                        },
                      ),
                      // Account and Security Section
                      SectionHeader(title: 'account_and_security'.tr),
                      SectionItem(
                        icon: Iconsax.lock,
                        label: 'set_password'.tr,
                        onTap: controller.onSetPasswordTap,
                      ),
                      SectionItem(
                        icon: Iconsax.document_text_1,
                        label: 'terms_conditions'.tr,
                        onTap: controller.onTermsConditionsTap,
                      ),
                      SectionItem(
                        icon: Iconsax.shield_tick,
                        label: 'privacy_policy'.tr,
                        onTap: controller.onPrivacyPolicyTap,
                      ),
                      SectionItem(
                        icon: Icons.help_outline,
                        label: 'faq'.tr,
                        onTap: controller.onFaqTap,
                      ),
                      // Logout Button
                      LogoutButton(onLogout: controller.onLogout),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
