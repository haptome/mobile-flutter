// Purpose: Payment item widget for upcoming payments list
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class PaymentItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onTap;

  const PaymentItem({super.key, required this.payment, this.onTap});

  Color _getColorFromType(String? type) {
    switch (type?.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFEB3B); // Yellow
      case 'teal':
        return const Color(0xFF009688); // Teal
      default:
        return AppColors.primary; // Default green
    }
  }

  Color _getBackgroundColorFromType(String? type) {
    switch (type?.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFF9C4); // Light yellow/cream
      case 'teal':
        return const Color(0xFFE0F2F1); // Light teal/cream
      default:
        return AppColors.primary.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorType = payment['colorType'] ?? 'default';
    final accentColor = _getColorFromType(colorType);
    final backgroundColor = _getBackgroundColorFromType(colorType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Colored vertical bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Payment details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ekub Name
                    Text(
                      payment['ekubName'] ?? 'ekub_name'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      payment['date'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Round number
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${'round'.tr} ${payment['round'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Frequency and Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        payment['frequency'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLightGray,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${payment['amount'] ?? ''} ETB',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
