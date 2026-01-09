import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

/// Small reusable amount label with icon used across ekub list items
class EkubAmount extends StatelessWidget {
  final String amount;
  final Color iconColor;
  final TextStyle? textStyle;

  const EkubAmount({
    super.key,
    required this.amount,
    this.iconColor = AppColors.splashBackground,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.attach_money, color: iconColor),
        const SizedBox(width: AppSizes.spacingXSmall),
        Text(
          amount,
          style: textStyle ?? GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
