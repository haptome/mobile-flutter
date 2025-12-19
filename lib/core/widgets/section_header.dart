import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Reusable section header with title and "View All" link
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.h3(
              color: AppColors.black,
              isDark: false,
            ).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.splashBackground,
                  isDark: false,
                   
                ).copyWith(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  decorationColor: AppColors.splashBackground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

