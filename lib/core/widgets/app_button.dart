import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Customizable button widget with primary color and rounded corners
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isFullWidth;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.icon,
    this.isFullWidth = true,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBackgroundColor = backgroundColor ??
        (type == ButtonType.primary ? AppColors.primary : Colors.transparent);
    final effectiveTextColor = textColor ??
        (type == ButtonType.primary
            ? AppColors.white
            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary));

    Widget buttonContent = isLoading
        ? SizedBox(
            height: AppSizes.iconMedium,
            width: AppSizes.iconMedium,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary ? AppColors.white : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconMedium, color: effectiveTextColor),
                const SizedBox(width: AppSizes.spacingSmall),
              ],
              Text(
                text,
                style: textStyle ?? AppTextStyles.button(color: effectiveTextColor),
              ),
            ],
          );

    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all(effectiveBackgroundColor),
      foregroundColor: WidgetStateProperty.all(effectiveTextColor),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? AppSizes.paddingLarge,
          vertical: verticalPadding ?? (height != null ? 2.0 : AppSizes.paddingMedium),
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.buttonRadius),
          side: type == ButtonType.outlined
              ? BorderSide(color: AppColors.primary, width: 1.0)
              : BorderSide.none,
        ),
      ),
      minimumSize: WidgetStateProperty.all(
        Size(
          isFullWidth ? double.infinity : (width ?? 0),
          height ?? AppSizes.buttonHeightMedium,
        ),
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      autofocus: false,
      child: buttonContent,
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  outlined,
}

