// Purpose: Helper utility to get Android app signature for SMS Retriever API
// Author: OTP Auto-Fill Implementation
// Linked Spec Section: OTP Auto-Fill Setup

import 'package:flutter/foundation.dart';

/// Helper class to retrieve Android app signature for SMS Retriever API
/// 
/// This signature is needed by the backend to format SMS messages correctly
/// for Android SMS auto-fill functionality.
/// 
/// Note: The actual app signature retrieval is handled by the flutter_otp_kit package
/// internally. This helper provides instructions for getting the signature.
class AppSignatureHelper {
  /// Print instructions for getting the app signature
  /// 
  /// The app signature is automatically used by flutter_otp_kit's OtpKit widget
  /// when SMS auto-fill is enabled. To get the signature for backend configuration:
  /// 
  /// 1. The signature is embedded in the app during build
  /// 2. It's based on the package name and signing certificate
  /// 3. Different for debug and release builds
  /// 
  /// To get the signature:
  /// - Use Android Studio's App Signing tool
  /// - Or use the command: keytool -list -v -keystore <keystore-path>
  /// - Or check the SMS Retriever API documentation
  static Future<void> printAppSignature() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      debugPrint('App signature is only available on Android');
      return;
    }

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════╗');
    debugPrint('║  ANDROID APP SIGNATURE FOR SMS AUTO-FILL                 ║');
    debugPrint('╠═══════════════════════════════════════════════════════════╣');
    debugPrint('║                                                           ║');
    debugPrint('║  To get your app signature hash:                          ║');
    debugPrint('║                                                           ║');
    debugPrint('║  METHOD 1: Using Google Play Console                     ║');
    debugPrint('║  1. Go to Release > Setup > App Integrity                ║');
    debugPrint('║  2. Find "App signing key certificate"                   ║');
    debugPrint('║  3. Use the SHA-256 fingerprint                          ║');
    debugPrint('║                                                           ║');
    debugPrint('║  METHOD 2: Using keytool (for debug builds)              ║');
    debugPrint('║  Run: keytool -list -v -keystore ~/.android/debug.keystore ║');
    debugPrint('║  Password: android                                        ║');
    debugPrint('║  Look for SHA-256 fingerprint                            ║');
    debugPrint('║                                                           ║');
    debugPrint('║  METHOD 3: Using SMS Retriever Helper                    ║');
    debugPrint('║  Use Google\'s AppSignatureHelper class                   ║');
    debugPrint('║  https://github.com/googlearchive/android-credentials    ║');
    debugPrint('║                                                           ║');
    debugPrint('╠═══════════════════════════════════════════════════════════╣');
    debugPrint('║  BACKEND CONFIGURATION:                                   ║');
    debugPrint('║                                                           ║');
    debugPrint('║  1. Open: et-ekub/services/auth-service/.env             ║');
    debugPrint('║                                                           ║');
    debugPrint('║  2. Set: ANDROID_APP_HASH=<your-11-char-hash>            ║');
    debugPrint('║                                                           ║');
    debugPrint('║  3. Restart the auth service                              ║');
    debugPrint('║                                                           ║');
    debugPrint('╠═══════════════════════════════════════════════════════════╣');
    debugPrint('║  NOTES:                                                   ║');
    debugPrint('║  • Debug and release builds have different hashes        ║');
    debugPrint('║  • Update backend config for each build type             ║');
    debugPrint('║  • The hash is 11 characters long                        ║');
    debugPrint('║  • flutter_otp_kit handles SMS detection automatically   ║');
    debugPrint('╚═══════════════════════════════════════════════════════════╝');
    debugPrint('');
  }
}
