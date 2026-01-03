// Purpose: Custom app bar for home screen
// Author: haptome H.
// Linked Spec Section: Home Screen

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userInitials;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLanguageTap;
  final String currentLanguage;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.userInitials,
    this.onNotificationTap,
    this.onLanguageTap,
    this.currentLanguage = 'Eng',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar with initials
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary, // Green background
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting
          Expanded(
            child: Text(
              '${'greeting'.tr}, $userName!',
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Notification icon
          IconButton(
            icon: const Icon(
              Iconsax.notification,
              color: AppColors.lightTextPrimary,
              size: 24,
            ),
            onPressed: onNotificationTap ?? () {},
          ),
          // Language selector
          GestureDetector(
            onTap: onLanguageTap ?? () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'language_eng'.tr,
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Iconsax.arrow_down_2,
                  color: AppColors.lightTextPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
