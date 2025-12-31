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
      backgroundColor: AppColors.backgroundLightGray,
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
                        onTap: () {
                          Navigator.of(context).pushNamed('/account-setting');
                        },
                      ),
                      SectionItem(
                        icon: Icons.verified_user_outlined,
                        label: 'verification'.tr,
                        onTap: () {
                          Navigator.of(context).pushNamed('/verification');
                        },
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
