import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Bottom navigation item data
class BottomNavItem {
  final String iconPath;
  final String label;
  final String route;

  const BottomNavItem({
    required this.iconPath,
    required this.label,
    required this.route,
  });
}

/// Reusable bottom navigation bar
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
        boxShadow: [
            BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        item.iconPath,
                        width: AppSizes.iconMedium,
                        height: AppSizes.iconMedium,
                        colorFilter: ColorFilter.mode(
                          isActive ? AppColors.primary : AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        item.label,
                        style: AppTextStyles.caption(
                          color: isActive ? AppColors.primary : AppColors.black,
                          isDark: false,
                        )?.copyWith(
                          fontSize: 10
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

