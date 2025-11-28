// Purpose: Primary action button with design specifications
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? minWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.minWidth = 200.0, // Minimum width from design spec
  });

  @override
  Widget build(BuildContext context) {
    // Responsive design: Use screen width with constraints
    final screenWidth = MediaQuery.of(context).size.width;
    final screenPadding = MediaQuery.of(context).padding.horizontal;
    final availableWidth =
        screenWidth - (screenPadding * 2) - 48; // 48 = padding from parent

    // Calculate button width: responsive but with min/max constraints
    final buttonWidth = width ??
        (availableWidth > minWidth!
            ? availableWidth.clamp(minWidth!, 400.0)
            : minWidth!);

    // Design specs converted to responsive values
    const buttonHeight = 51.0;
    const borderRadius = 104.0; // Very rounded (pill shape)
    const verticalPadding = 15.6;
    const buttonHorizontalPadding = 31.2;
    const gap = 10.4;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: buttonHorizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textWhite,
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
}
