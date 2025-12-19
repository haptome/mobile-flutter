import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Custom numeric keyboard widget
class CustomNumericKeyboard extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback? onBackspaceTap;

  const CustomNumericKeyboard({
    super.key,
    required this.onNumberTap,
    this.onBackspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightSurface,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // OTP Code label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OTP Code: ',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.lightTextSecondary,
                  isDark: false,
                ),
              ),
              Text(
                '123456',
                style: AppTextStyles.h3(
                  color: AppColors.lightTextPrimary,
                  isDark: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          // Keyboard grid
          Column(
            children: [
              // Row 1: 1, 2(abc), 3(def)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('1', ''),
                  _buildKey('2', 'abc'),
                  _buildKey('3', 'def'),
                ],
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              // Row 2: 4(ghi), 5(jkl), 6(mno)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('4', 'ghi'),
                  _buildKey('5', 'jkl'),
                  _buildKey('6', 'mno'),
                ],
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              // Row 3: 7(pqrs), 8(tuv), 9(wxyz)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('7', 'pqrs'),
                  _buildKey('8', 'tuv'),
                  _buildKey('9', 'wxyz'),
                ],
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              // Row 4: 0, backspace
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('0', ''),
                  const SizedBox(width: 80),
                  _buildBackspaceKey(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number, String letters) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: InkWell(
            onTap: () => onNumberTap(number),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: AppTextStyles.h3(
                      color: AppColors.lightTextPrimary,
                      isDark: false,
                    ),
                  ),
                  if (letters.isNotEmpty)
                    Text(
                      letters,
                      style: AppTextStyles.caption(
                        color: AppColors.lightTextSecondary,
                        isDark: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: InkWell(
            onTap: onBackspaceTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.backspace,
                color: AppColors.lightTextPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

