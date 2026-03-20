// Purpose: Helper utility to get Android app signature for SMS Retriever API

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Retrieves the Android app signature hash needed for SMS Retriever API.
///
/// The backend must append this 11-character hash to every OTP SMS so Android
/// can route the message to this app without requiring READ_SMS permission.
///
/// SMS format required by the backend:
///   <#> Your ET Equb code is: 123456\n[HASH]
class AppSignatureHelper {
  static const _channel = MethodChannel('et_digital_equb/app_signature');

  static String? _cachedSignature;

  /// Returns the 11-character app signature hash, or null on non-Android / error.
  static Future<String?> getAppSignature() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    if (_cachedSignature != null) return _cachedSignature;

    try {
      final String? signature =
          await _channel.invokeMethod<String>('getAppSignature');
      _cachedSignature = signature;
      if (kDebugMode) {
        debugPrint('╔══════════════════════════════════════════╗');
        debugPrint('║  Android App Signature: $signature');
        debugPrint('║  Add to backend .env: ANDROID_APP_HASH=$signature');
        debugPrint('╚══════════════════════════════════════════╝');
      }
      return signature;
    } on PlatformException catch (e) {
      debugPrint('Could not get app signature: ${e.message}');
      return null;
    }
  }

  /// Prints setup instructions (debug only).
  static Future<void> printAppSignature() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final sig = await getAppSignature();
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════╗');
    debugPrint('║  ANDROID APP SIGNATURE FOR SMS AUTO-FILL                 ║');
    debugPrint('╠═══════════════════════════════════════════════════════════╣');
    if (sig != null) {
      debugPrint('║  App Signature: $sig');
      debugPrint('║  Set in backend .env: ANDROID_APP_HASH=$sig');
    } else {
      debugPrint('║  Could not retrieve signature automatically.             ║');
      debugPrint('║  Run: keytool -list -v -keystore ~/.android/debug.keystore ║');
    }
    debugPrint('╚═══════════════════════════════════════════════════════════╝');
    debugPrint('');
  }
}
