// Purpose: Account verification banner
// Author: haptome H.
// Linked Spec Section: Home Screen

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';

class VerificationBanner extends StatelessWidget {
  final VoidCallback? onVerifyTap;

  const VerificationBanner({
    super.key,
    this.onVerifyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Exclamation icon
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.textWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.warning_2,
              color: Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: GestureDetector(
              onTap: onVerifyTap,
              child: Text(
                'account_not_verified'.tr,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

