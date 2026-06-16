// Purpose: WebView for payment checkout — handles AddisPay and TeleBirr
//
// Scenario coverage:
//   AddisPay success  : WebView navigates to callback URL ?status=success  → intercept, notify backend, return 'success'
//   AddisPay failed   : WebView navigates to callback URL ?status=failed    → intercept, return 'failed'
//   AddisPay cancelled: WebView navigates to callback URL ?status=cancelled → intercept, return 'cancelled'
//   TeleBirr complete : WebView navigates to etequb.com/payment/complete    → intercept, poll backend, return final status
//   TeleBirr pending  : TeleBirr notify not yet received after 12 s polling → return 'pending'
//   User closes       : Taps ✕ in AppBar → return null (no snackbar shown)
//   Network error     : Dio throws during status poll → retry; if all fail, return 'failed'

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final RxBool isLoading = true.obs;
  final RxBool isVerifying = false.obs;

  late final String paymentUrl;
  late final String paymentId;
  late final String gateway; // 'addispay' | 'telebirr'

  /// Guards against re-entering callback logic if the URL fires multiple times.
  bool _isHandlingCallback = false;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    paymentUrl = args['url'] as String? ?? '';
    paymentId = args['paymentId'] as String? ?? '';
    gateway = args['gateway'] as String? ?? 'addispay';
  }

  // ─── URL pattern matchers ──────────────────────────────────────────────────

  /// True when the URL is our AddisPay callback endpoint.
  /// Example: https://api.etequb.com/api/v1/webhooks/addispay/callback?paymentId=xxx&status=success
  bool _isAddisPayCallback(String url) {
    return url.contains('webhooks/addispay/callback');
  }

  /// True when a gateway redirects the user back to our frontend after payment.
  /// AddisPay uses redirect_url (/payment/complete); TeleBirr uses the same family.
  /// Example: https://etequb.com/payment/complete
  bool _isFrontendRedirect(String url) {
    return url.contains('etequb.com/payment/complete') ||
        url.contains('etequb.com/payment/success') ||
        url.contains('etequb.com/payment/callback');
  }

  // ─── Authoritative status verification ─────────────────────────────────────

  /// Polls the backend status endpoint for the true payment outcome.
  /// Never trusts the redirect URL — the DB is the single source of truth.
  /// Returns 'success' | 'failed' | 'pending'.
  Future<String> _verifyStatusWithBackend({int maxAttempts = 4}) async {
    if (paymentId.isEmpty) return 'pending';
    final apiService = Get.find<ApiService>();
    const delay = Duration(seconds: 2);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response =
            await apiService.dio.get('/payments/$paymentId/status');
        if (response.data['success'] == true) {
          final s = response.data['data']?['status'] as String?;
          if (s == 'success') return 'success';
          if (s == 'failed') return 'failed';
          // 'initiated' / 'processing' — payment still in flight, keep polling
        }
      } catch (_) {
        // Network hiccup — retry on next attempt
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(delay);
      }
    }
    return 'pending';
  }

  // ─── AddisPay callback handler ────────────────────────────────────────────

  /// Intercepts the AddisPay callback URL (called from shouldOverrideUrlLoading).
  /// We DO NOT trust the status query param — it only tells the backend which
  /// outcome AddisPay reported. We await the backend callback (which updates the
  /// DB) and then verify the real status before telling the user anything.
  Future<void> _handleAddisPayCallback(String url) async {
    if (_isHandlingCallback) return;
    _isHandlingCallback = true;
    isVerifying.value = true;

    try {
      final uri = Uri.parse(url);
      final urlStatus = uri.queryParameters['status'];

      // User explicitly cancelled — no payment to verify.
      if (urlStatus == 'cancelled') {
        await _triggerBackendCallback(uri.queryParameters);
        if (mounted) Get.back(result: 'cancelled');
        return;
      }

      // Ask the backend to finalize the payment in the DB, then verify.
      await _triggerBackendCallback(uri.queryParameters);
      final verified = await _verifyStatusWithBackend();

      if (!mounted) return;
      Get.back(result: verified); // 'success' | 'failed' | 'pending'
    } catch (e) {
      if (mounted) Get.back(result: 'failed');
    } finally {
      if (mounted) isVerifying.value = false;
    }
  }

  /// Intercepts the AddisPay redirect_url fallback (/payment/complete) which
  /// carries no status param. AddisPay only navigates to redirect_url after a
  /// successful payment, so we synthesise a success callback to update the DB
  /// before polling — without this the payment stays in 'processing' forever.
  Future<void> _handleAddisPayRedirect() async {
    if (_isHandlingCallback) return;
    _isHandlingCallback = true;
    isVerifying.value = true;

    try {
      if (paymentId.isNotEmpty) {
        await _triggerBackendCallback({'paymentId': paymentId, 'status': 'success'});
      }
      final verified = await _verifyStatusWithBackend();
      if (!mounted) return;
      Get.back(result: verified);
    } catch (e) {
      if (mounted) Get.back(result: 'failed');
    } finally {
      if (mounted) isVerifying.value = false;
    }
  }

  /// Call the backend callback URL so it can update payment status in the DB.
  /// Awaited (not fire-and-forget) so the DB is updated before we verify status.
  Future<void> _triggerBackendCallback(Map<String, String?> queryParams) async {
    try {
      final apiService = Get.find<ApiService>();
      await apiService.dio
          .get('/webhooks/addispay/callback', queryParameters: queryParams);
    } catch (_) {
      // best-effort — the subsequent status poll is the source of truth
    }
  }

  // ─── TeleBirr completion handler ──────────────────────────────────────────

  /// Intercepts the TeleBirr redirect URL (called from shouldOverrideUrlLoading).
  /// TeleBirr's async notify may not have arrived yet, so we poll the backend
  /// status endpoint up to 6 times (total ~12 seconds) before giving up.
  Future<void> _handleTelebirrCompletion() async {
    if (_isHandlingCallback) return;
    _isHandlingCallback = true;
    isVerifying.value = true;

    try {
      // TeleBirr's async notify may lag, so poll a little longer (~12 s).
      final verified = await _verifyStatusWithBackend(maxAttempts: 6);
      if (!mounted) return;
      // 'pending' here means the notify hasn't arrived yet — payment may still
      // complete, so we surface it as pending rather than failed.
      Get.back(result: verified);
    } catch (e) {
      if (mounted) Get.back(result: 'failed');
    } finally {
      if (mounted) isVerifying.value = false;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebFallback() : _buildMobileWebView();
  }

  // ─── Mobile WebView ────────────────────────────────────────────────────────

  Widget _buildMobileWebView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: null), // user cancelled
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
              useOnLoadResource: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: 'camera; microphone',
              iframeAllowFullscreen: true,
            ),
            onLoadStart: (controller, url) {
              if (mounted) isLoading.value = true;
            },
            onLoadStop: (controller, url) {
              if (mounted) isLoading.value = false;
            },
            // Intercept every navigation decision.
            // For AddisPay/TeleBirr terminal URLs: cancel loading, handle ourselves.
            // For everything else: allow normally.
            shouldOverrideUrlLoading: (_, navigationAction) async {
              final url =
                  navigationAction.request.url?.toString() ?? '';

              if (gateway == 'addispay') {
                // AddisPay success/error/cancel callback (carries ?status=).
                if (_isAddisPayCallback(url)) {
                  // Don't load the JSON backend response in the WebView.
                  // ignore: discarded_futures
                  _handleAddisPayCallback(url);
                  return NavigationActionPolicy.CANCEL;
                }
                // AddisPay redirect_url fallback (/payment/complete, no status).
                if (_isFrontendRedirect(url)) {
                  // ignore: discarded_futures
                  _handleAddisPayRedirect();
                  return NavigationActionPolicy.CANCEL;
                }
              } else {
                // TeleBirr redirects to the frontend complete page.
                if (_isFrontendRedirect(url)) {
                  // ignore: discarded_futures
                  _handleTelebirrCompletion();
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (_, request, error) {
              // Silently ignore errors while we're already navigating away.
              if (_isHandlingCallback) return;
              // Only surface the error when the MAIN frame fails to load.
              // Sub-resource failures (e.g. payment-method logos blocked by
              // Android ORB / CORS) are expected and must not alarm the user.
              if (request.isForMainFrame != true) return;
              if (mounted) {
                Get.snackbar(
                  'Error',
                  'Failed to load payment page: ${error.description}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),

          // ── Loading overlay ────────────────────────────────────────────────
          Obx(() {
            if (!isLoading.value) return const SizedBox.shrink();
            return Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ── Verifying overlay ──────────────────────────────────────────────
          Obx(() {
            if (!isVerifying.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Verifying payment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Web fallback (opens in external browser) ──────────────────────────────

  Widget _buildWebFallback() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: null),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Complete Your Payment',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Click the button below to open the payment gateway.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(paymentUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                    if (mounted) {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Payment Verification'),
                          content: const Text(
                            'After completing your payment, tap "Verify" '
                            'to check the status.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                Get.back(result: null);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                await _handleTelebirrCompletion();
                              },
                              child: const Text('Verify'),
                            ),
                          ],
                        ),
                        barrierDismissible: false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Payment Gateway'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(result: null),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
