// Purpose: Lottery number badge widget for displaying member lottery numbers
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class LotteryNumberBadge extends StatelessWidget {
  final String lotteryNumber;
  final double fontSize;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const LotteryNumberBadge({
    super.key,
    required this.lotteryNumber,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '#$lotteryNumber',
        style: GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Helper function to check if lottery numbers should be displayed
/// Only show lottery numbers when group status is 'started'
bool shouldShowLotteryNumber(String? groupStatus, String? lotteryNumber) {
  return groupStatus == 'started' && 
         lotteryNumber != null && 
         lotteryNumber.isNotEmpty;
}