// Purpose: Ekub list card widget for displaying ekubs in a list
// Author: Auto-generated
// Linked Spec Section: Ekub Type, In-Kind, Duration Pages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class EkubListCard extends StatelessWidget {
  final String name;
  final String frequency;
  final String amount;
  final String duration;
  final int memberCount;
  final VoidCallback? onTap;

  const EkubListCard({
    super.key,
    required this.name,
    required this.frequency,
    required this.amount,
    required this.duration,
    required this.memberCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.spacingSmall,
        ),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              name,
              style: AppTextStyles.h4(
                color: AppColors.splashBackground,
                isDark: false,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            // Details row
            Row(
              children: [
                _buildDetailChip(Icons.access_time, frequency),
                const SizedBox(width: AppSizes.spacingSmall),
                _buildDetailChip(Icons.attach_money, amount),
                const SizedBox(width: AppSizes.spacingSmall),
                _buildDetailChip(Icons.calendar_today, duration),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            // Member count
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.textLightGray,
                ),
                const SizedBox(width: 4),
                Text(
                  '$memberCount ${'members'.tr}',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.textLightGray,
                    isDark: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textLightGray,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall(
              color: AppColors.textLightGray,
              isDark: false,
            ),
          ),
        ],
      ),
    );
  }
}

