// Purpose: User header widget with avatar, name, and refresh button
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: AppColors.splashBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User name
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          // Create Group button
          if (onRefresh != null)
            TextButton(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Create Group',
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
