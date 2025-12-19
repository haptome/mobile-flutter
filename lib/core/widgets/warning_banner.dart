import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Reusable warning banner component
class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const WarningBanner({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.lightError,
          borderRadius: BorderRadius.zero,
        ),
        width: double.infinity,
        child: Row(
          children: [
            const Icon(
              Icons.info,
              color: AppColors.white,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.white,
                  isDark: false,
                ).copyWith(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

