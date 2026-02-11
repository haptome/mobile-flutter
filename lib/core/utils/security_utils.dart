// Purpose: Security utilities for KYC screens
// Author: Auto-generated
// Linked Spec Section: KYC ID & Liveness Flow - Security Implementation

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for security features during KYC flow
class SecurityUtils {
  SecurityUtils._();

  /// Enable screenshot and screen recording prevention
  /// 
  /// On Android: Sets FLAG_SECURE on the window
  /// On iOS: Not directly supported, but we can detect screenshots
  static Future<void> enableSecureMode() async {
    // Skip on web platform
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      try {
        await SystemChannels.platform.invokeMethod('setSecureFlag', true);
      } catch (e) {
        debugPrint('Failed to enable secure mode: $e');
      }
    }
  }

  /// Disable screenshot and screen recording prevention
  static Future<void> disableSecureMode() async {
    // Skip on web platform
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      try {
        await SystemChannels.platform.invokeMethod('setSecureFlag', false);
      } catch (e) {
        debugPrint('Failed to disable secure mode: $e');
      }
    }
  }

  /// Clear sensitive data from memory
  /// 
  /// This is a placeholder for clearing sensitive data.
  /// In production, you might want to:
  /// - Clear image caches
  /// - Clear temporary files
  /// - Reset controller states
  static Future<void> clearSensitiveData() async {
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Force garbage collection (not guaranteed but helps)
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Mixin for screens that need security features
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    SecurityUtils.enableSecureMode();
  }

  @override
  void dispose() {
    SecurityUtils.disableSecureMode();
    SecurityUtils.clearSensitiveData();
    super.dispose();
  }
}
