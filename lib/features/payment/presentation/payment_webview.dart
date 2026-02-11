// Purpose: WebView for payment gateway with URL monitoring and verification
// Author: Auto-generated

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
  InAppWebViewController? _webViewController;
  final RxBool isLoading = true.obs;
  final RxBool isVerifying = false.obs;
  late final String paymentUrl;
  late final String paymentId;
  bool hasVerified = false;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    paymentUrl = args['url'] as String;
    paymentId = args['paymentId'] as String;

    print('PaymentWebView - Initializing with URL: $paymentUrl');
    print('PaymentWebView - Payment ID: $paymentId');
  }

  Future<void> _handleUrlChange(String newUrl) async {
    if (hasVerified) return;
    
    hasVerified = true;
    isVerifying.value = true;

    print('PaymentWebView - URL changed to: $newUrl');
    print('PaymentWebView - Verifying payment with ID: $paymentId');

    try {
      // Call verification endpoint
      final apiService = Get.find<ApiService>();
      final response = await apiService.dio.get(
        '/webhooks/verify/$paymentId',
      );

      print('PaymentWebView - Verification response: ${response.data}');

      if (response.data['success'] == true) {
        final paymentStatus = response.data['data']?['status'] ?? 'unknown';
        
        if (paymentStatus == 'completed' || paymentStatus == 'success') {
          // Payment successful
          if (mounted) {
            Get.back(result: true);
          }
        } else if (paymentStatus == 'failed' || paymentStatus == 'cancelled') {
          // Payment failed
          if (mounted) {
            Get.back(result: false);
          }
        } else {
          // Unknown status - show message and close
          if (mounted) {
            Get.snackbar(
              'Payment Status',
              'Payment status: $paymentStatus',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            Get.back(result: null);
          }
        }
      } else {
        // Verification failed
        if (mounted) {
          Get.snackbar(
            'Verification Failed',
            response.data['message'] ?? 'Could not verify payment status',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          Get.back(result: false);
        }
      }
    } catch (e) {
      print('PaymentWebView - Verification error: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to verify payment: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back(result: false);
      }
    } finally {
      if (mounted) {
        isVerifying.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // For web platform, open in new tab and show instructions
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.back(result: null);
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.payment,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Complete Your Payment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Click the button below to open the payment gateway in a new tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(paymentUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      
                      // Show dialog to verify payment
                      if (mounted) {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Payment Verification'),
                            content: const Text(
                              'After completing your payment, click "Verify" to check the payment status.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back(); // Close dialog
                                  Get.back(result: null); // Close payment screen
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Get.back(); // Close dialog
                                  await _handleUrlChange(paymentUrl);
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.back(result: null);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // For mobile platforms, use InAppWebView
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // User cancelled payment
            Get.back(result: null);
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(paymentUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
              useOnLoadResource: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: "camera; microphone",
              iframeAllowFullscreen: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              print('PaymentWebView - WebView created');
            },
            onLoadStart: (controller, url) {
              print('PaymentWebView - Page started loading: $url');
              setState(() {
                isLoading.value = true;
              });
            },
            onLoadStop: (controller, url) async {
              print('PaymentWebView - Page finished loading: $url');
              setState(() {
                isLoading.value = false;
              });
              
              // Check if URL has changed (payment completed or cancelled)
              if (url.toString() != paymentUrl && !hasVerified) {
                await _handleUrlChange(url.toString());
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              print('PaymentWebView - Navigation request: $url');
              
              // Check if URL has changed (payment completed or cancelled)
              if (url != paymentUrl && !hasVerified) {
                await _handleUrlChange(url);
              }
              
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (controller, request, error) {
              print('PaymentWebView - Error: ${error.description}');
              Get.snackbar(
                'Error',
                'Failed to load payment page: ${error.description}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              print('PaymentWebView - HTTP Error: ${errorResponse.statusCode}');
            },
          ),
          
          // Loading indicator
          Obx(() {
            if (isLoading.value && progress < 1.0) {
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Verifying indicator
          Obx(() {
            if (isVerifying.value) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
