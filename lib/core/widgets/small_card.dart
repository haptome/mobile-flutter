import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Reusable small card component with icon and text
class SmallCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? iconBoxShadow;
  final Color? iconColor;

  const SmallCard({
    super.key,
    required this.iconPath,
    required this.label,
    this.onTap,
    this.iconBackgroundColor,
    this.iconBoxShadow,
    this.iconColor,
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
                  color: iconBackgroundColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: iconBoxShadow,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    colorFilter: ColorFilter.mode(
                      iconColor ?? AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(
                  color: Color(0xff232729),
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

