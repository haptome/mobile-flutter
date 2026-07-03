// Purpose: Category card widget with iconify icon
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';
import 'translated_text.dart';

class CategoryCard extends StatelessWidget {
  final String iconUrl;
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
              color: const Color(0x40000000),
              width: 0.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: iconUrl,
                    color: AppColors.white,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              TranslatedText(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(
                  color: const Color(0xff232729),
                  isDark: false,
                ).copyWith(fontWeight: FontWeight.bold),
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
