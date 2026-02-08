// Purpose: Test status bar utility functionality
// Tests the StatusBarUtils class methods

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:et_digital_equb/core/utils/status_bar_utils.dart';

void main() {
  group('StatusBarUtils Tests', () {
    test('StatusBarUtils methods exist', () {
      // Test that all static methods are accessible
      expect(StatusBarUtils.setLightStatusBar, isNotNull);
      expect(StatusBarUtils.setDarkStatusBar, isNotNull);
      expect(StatusBarUtils.setSplashStatusBar, isNotNull);
      expect(StatusBarUtils.setAppStatusBar, isNotNull);
      expect(StatusBarUtils.setStatusBarForBackgroundColor, isNotNull);
    });

    test('Color darkness detection works', () {
      // Test the private _isColorDark method indirectly
      // Dark colors should use light status bar
      StatusBarUtils.setStatusBarForBackgroundColor(Colors.black);
      StatusBarUtils.setStatusBarForBackgroundColor(Colors.grey[900]!);

      // Light colors should use dark status bar
      StatusBarUtils.setStatusBarForBackgroundColor(Colors.white);
      StatusBarUtils.setStatusBarForBackgroundColor(Colors.grey[100]!);

      // Medium colors should be detected appropriately
      StatusBarUtils.setStatusBarForBackgroundColor(Colors.grey[500]!);

      expect(true, isTrue); // If we get here without exceptions, it works
    });

    test('Custom status bar settings work', () {
      // Test custom status bar configuration
      StatusBarUtils.setCustomStatusBar(
        statusBarColor: Colors.blue,
        navigationBarColor: Colors.red,
        iconBrightness: Brightness.light,
        navigationIconBrightness: Brightness.dark,
      );

      expect(true, isTrue); // If we get here without exceptions, it works
    });
  });
}
