// Purpose: App color theme constants
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFBBBB32); // Primary yellow-green
  static const Color secondary = Color(0xFF024141); // Secondary dark teal

  // Legacy aliases for backward compatibility
  static const Color primaryDark = Color(0xFF024141); // Secondary color
  static const Color primaryYellow = Color(0xFFBBBB32); // Primary color
  static const Color primaryGreen = Color(0xFFBBBB32); // Primary color

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLightGray = Color(0xFFF0F0F0);

  // Text Colors
  static const Color textDark = Color(0xFF000000);
  static const Color textLightGray = Color(0xFFA0A0A0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLightGray = Color(0xFFE0E0E0);
  static const Color borderActive = Color(0xFFBBBB32); // Primary color

  // Gradient Colors for Continue Button
  static const Color gradientStart = Color(0xFFBBBB32); // Primary color
  static const Color gradientEnd = Color(0xFFBBBB32); // Primary color
}

