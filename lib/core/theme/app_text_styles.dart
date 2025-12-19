import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text style definitions for the app
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle h1({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.2,
    );
  }

  static TextStyle h2({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.3,
    );
  }

  static TextStyle h3({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }

  static TextStyle h4({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.4,
    );
  }

  // Body text
  static TextStyle bodyLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      height: 1.5,
    );
  }

  static TextStyle bodySmall({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      height: 1.5,
    );
  }

  // Button text
  static TextStyle button({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
      letterSpacing: 0.5,
    );
  }

  // Caption
  static TextStyle caption({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      height: 1.4,
    );
  }

  // Overline
  static TextStyle overline({Color? color, bool isDark = false}) {
    return GoogleFonts.montserrat(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      height: 1.4,
      letterSpacing: 1.5,
    );
  }
}

