import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_sizes.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.lightSurface,
        error: AppColors.lightError,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: AppTextStyles.h3(color: AppColors.lightTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(),
        displayMedium: AppTextStyles.h2(),
        displaySmall: AppTextStyles.h3(),
        headlineMedium: AppTextStyles.h4(),
        bodyLarge: AppTextStyles.bodyLarge(),
        bodyMedium: AppTextStyles.bodyMedium(),
        bodySmall: AppTextStyles.bodySmall(),
        labelLarge: AppTextStyles.button(),
        labelSmall: AppTextStyles.caption(),
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.textFieldBorder,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.textFieldBorder,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.lightError,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.lightError,
            width: 2.0,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.lightTextSecondary,
        ),
        constraints: const BoxConstraints(minHeight: AppSizes.textFieldHeight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: AppTextStyles.button(),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button(color: AppColors.primary),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          textStyle: AppTextStyles.button(color: AppColors.primary),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: AppTextStyles.h3(
          color: AppColors.darkTextPrimary,
          isDark: true,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(isDark: true),
        displayMedium: AppTextStyles.h2(isDark: true),
        displaySmall: AppTextStyles.h3(isDark: true),
        headlineMedium: AppTextStyles.h4(isDark: true),
        bodyLarge: AppTextStyles.bodyLarge(isDark: true),
        bodyMedium: AppTextStyles.bodyMedium(isDark: true),
        bodySmall: AppTextStyles.bodySmall(isDark: true),
        labelLarge: AppTextStyles.button(),
        labelSmall: AppTextStyles.caption(isDark: true),
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.darkError,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.darkError,
            width: 2.0,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.darkTextSecondary,
          isDark: true,
        ),
        constraints: const BoxConstraints(minHeight: AppSizes.textFieldHeight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: AppTextStyles.button(),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button(color: AppColors.primary),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          textStyle: AppTextStyles.button(color: AppColors.primary),
        ),
      ),
    );
  }
}

