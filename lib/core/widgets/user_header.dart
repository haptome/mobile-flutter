// Purpose: User header widget with avatar, name, and refresh button
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class UserHeader extends StatelessWidget {
  final String userName;
  final String userInitials;
  final VoidCallback? onRefresh;

  const UserHeader({
    super.key,
    required this.userName,
    required this.userInitials,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      color: AppColors.splashBackground,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User name
              SizedBox(
                width: 100,
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          // Create Group button
          if (onRefresh != null)
            TextButton(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'create_group'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
