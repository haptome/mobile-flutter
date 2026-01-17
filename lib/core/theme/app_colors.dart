import 'package:flutter/material.dart';

/// Centralized color definitions for the app
class AppColors {
  AppColors._();

  // Primary color
  static const Color primary = Color(0xFFBBBB32);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF1F5460);
  static const Color lightTextSecondary = Color(0xFF879EA4);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color textFieldBorder = Color(0xFFD8DADC);
  static const Color lightError = Color(0xFFD32F2F);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkError = Color(0xFFCF6679);

  //text colors
  static const Color textLightGray = Color(0xFFA0A0A0);

  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color backgroundLightGray = Color(0xFFF0F0F0);

  // Border Colors
  static const Color borderLightGray = Color(0xFFE0E0E0);
  static const Color borderActive = Color(0xFFBBBB32); // Primary color

  // Splash screen
  static const Color splashBackground = Color(0xFF024141); // Dark teal
}
