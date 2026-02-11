import 'package:et_digital_equb/core/widgets/text_marquee.dart';
import 'package:flutter/material.dart';
import 'package:marqueer/marqueer.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Reusable warning banner component
class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const WarningBanner({super.key, required this.message, this.onTap});

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
              child: TextMarquee(
                text: message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
