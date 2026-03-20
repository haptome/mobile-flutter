// Purpose: Ekub progress card widget
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class EkubProgressCard extends StatelessWidget {
  final String title;
  final String frequency;
  final String amount;
  final int completedRounds;
  final int totalRounds;
  final VoidCallback? onTap;

  const EkubProgressCard({
    super.key,
    required this.title,
    required this.frequency,
    required this.amount,
    required this.completedRounds,
    required this.totalRounds,
    this.onTap,
  });

  double get progress => completedRounds / totalRounds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and frequency row
            Row(
              children: [
                SizedBox(
                  // maxWidth: AppSizes.sizedBoxWidth,
                  width: AppSizes.sizedBoxWidth,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.splashBackground,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.borderLightGray,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    '$frequency $amount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress text
            Text(
              '${completedRounds} of ${totalRounds} ${'rounds_completed'.tr}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLightGray,
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.borderLightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
