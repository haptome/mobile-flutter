package com.etequb

import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {

    private val CHANNEL = "et_digital_equb/app_signature"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAppSignature") {
                    result.success(getAppSignatureHash())
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Computes the 11-character app signature hash used by the SMS Retriever API.
     * The backend must append this hash to every OTP SMS message.
     *
     * Format: "<#> Your code is: 123456\n[HASH]"
     */
    private fun getAppSignatureHash(): String? {
        return try {
            val packageName = packageName
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )
                info.signatures
            } ?: return null

            for (sig in signatures) {
                val md = MessageDigest.getInstance("SHA-256")
                md.update(packageName.toByteArray())
                md.update(sig.toByteArray())
                val digest = md.digest()
                val hash = Base64.encodeToString(digest, Base64.NO_PADDING or Base64.NO_WRAP)
                // Return first 11 characters — this is the SMS Retriever API hash
                return hash.substring(0, 11)
            }
            null
        } catch (e: Exception) {
            null
        }
    }
}
