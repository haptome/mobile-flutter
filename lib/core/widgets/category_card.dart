// Purpose: Category card widget with iconify icon
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String iconUrl; // Material Symbols icon identifier
  final String label;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.iconUrl,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingMedium,
            horizontal: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: const Color(0x40000000), // #00000040
              width: 0.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000), // #00000014
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Iconify(
                    iconUrl,
                    color: AppColors.white,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(
                  color: const Color(0xff232729),
                  isDark: false,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

