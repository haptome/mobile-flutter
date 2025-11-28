// Purpose: Profile page
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile_user_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/section_item.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/main_scaffold.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return MainScaffold(
      backgroundColor: AppColors.backgroundLightGray,
      initialBottomNavIndex: 3,
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
                color: AppColors.textDark,
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
      ),
      body: SafeArea(
        child: Obx(
          () {
            final user = controller.user.value;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  ProfileUserCard(
                    profileImageUrl: user['profileImageUrl'] as String?,
                    userName: user['name'] ?? 'user_name'.tr,
                    phoneNumber: user['phone'] ?? '',
                    idNumber: user['idNumber'] ?? '',
                    location: user['location'] ?? '',
                    level: user['level'] ?? '1',
                    onEditProfile: controller.onEditProfile,
                  ),
                  // Wallets Section
                  SectionHeader(title: 'wallets'.tr),
                  SectionItem(
                    icon: Icons.wallet_outlined,
                    label: 'wallet_and_payments'.tr,
                    onTap: controller.onWalletTap,
                  ),
                  // Profile Management Section
                  SectionHeader(title: 'profile_management'.tr),
                  SectionItem(
                    icon: Icons.person_outline,
                    label: 'account_setting'.tr,
                    onTap: controller.onAccountSettingTap,
                  ),
                  SectionItem(
                    icon: Icons.verified_user_outlined,
                    label: 'verification'.tr,
                    onTap: controller.onVerificationTap,
                  ),
                  // Account and Security Section
                  SectionHeader(title: 'account_and_security'.tr),
                  SectionItem(
                    icon: Icons.lock_outline,
                    label: 'set_password'.tr,
                    onTap: controller.onSetPasswordTap,
                  ),
                  SectionItem(
                    icon: Icons.description_outlined,
                    label: 'terms_conditions'.tr,
                    onTap: controller.onTermsConditionsTap,
                  ),
                  SectionItem(
                    icon: Icons.help_outline,
                    label: 'faq'.tr,
                    onTap: controller.onFaqTap,
                  ),
                  // Logout Button
                  LogoutButton(
                    onLogout: controller.onLogout,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

