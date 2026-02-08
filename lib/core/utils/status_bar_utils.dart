// Purpose: Utility class for consistent status bar management across the app
// Author: Generated for ET Digital Equb
// Handles status bar appearance for both light and dark themes

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class StatusBarUtils {
  /// Set status bar to light content (white icons/text)
  /// Use this for dark backgrounds
  static void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set status bar to dark content (black icons/text)
  /// Use this for light backgrounds
  static void setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Set status bar for splash screen (typically dark background)
  static void setSplashStatusBar() {
    setLightStatusBar();
  }

  /// Set status bar for main app screens (typically light background)
  static void setAppStatusBar() {
    setDarkStatusBar();
  }

  /// Set status bar with custom colors
  static void setCustomStatusBar({
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? iconBrightness,
    Brightness? navigationIconBrightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: iconBrightness ?? Brightness.dark,
        statusBarBrightness: iconBrightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
        systemNavigationBarColor: navigationBarColor ?? Colors.white,
        systemNavigationBarIconBrightness: 
            navigationIconBrightness ?? Brightness.dark,
      ),
    );
  }

  /// Apply status bar settings with automatic brightness detection
  /// based on the scaffold background color
  static void setStatusBarForBackgroundColor(Color backgroundColor) {
    final isDarkBackground = _isColorDark(backgroundColor);
    if (isDarkBackground) {
      setLightStatusBar();
    } else {
      setDarkStatusBar();
    }
  }

  /// Helper method to determine if a color is dark
  static bool _isColorDark(Color color) {
    // Calculate luminance (perceived brightness)
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }

  /// Set immersive mode (full screen with hidden system UI)
  static void setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// Set normal mode (show status bar and navigation bar)
  static void setNormalMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}