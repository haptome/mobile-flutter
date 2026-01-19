// Purpose: Small card widget for categories with iconify icon
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class CategorySmallCard extends StatelessWidget {
  final String iconUrl; // Material Symbols icon identifier
  final String label;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? iconBoxShadow;
  final Color? iconColor;
  final bool shadow;

  const CategorySmallCard({
    super.key,
    required this.iconUrl,
    required this.label,
    this.onTap,
    this.iconBackgroundColor,
    this.iconBoxShadow,
    this.iconColor,
    this.shadow = false,
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
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: const Color(0x14000000), // #00000014
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: iconBoxShadow,
                ),
                child: Center(
                  child: IconifyIcon(
                    icon:iconUrl,
                    color: iconColor ?? AppColors.white,
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
                ).copyWith(
                  fontWeight: FontWeight.bold,
                  
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
