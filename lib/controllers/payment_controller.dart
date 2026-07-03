// Purpose: Controller for payment selection
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/controllers/group_detail_controller.dart';
import 'package:et_digital_equb/controllers/in_kind_detail_controller.dart';

class PaymentController extends GetxController {
  final RxString selectedPaymentMethod = ''.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set initial state if coming from Your Ekubs page
    currentBottomNavIndex.value = 1;
  }

  // Payment method descriptions
  final String addisPayDescription =
      'Secure Ethiopian payment gateway. Pay with your bank, mobile money, or card.';
  final String telebirrDescription =
      'Pay directly using your TeleBirr account. Quick and convenient.';

  void selectPaymentMethod(String method) {
    if (selectedPaymentMethod.value == method) {
      selectedPaymentMethod.value = ''; // Collapse if same
    } else {
      selectedPaymentMethod.value = method;
    }
  }

  Future<void> proceedToPayment(
    String method,
    String? groupId,
    double? amount, {
    int? cycleNumber,
  }) async {
    // Validate required parameters
    if (groupId == null || amount == null) {
      Get.snackbar(
        'Error',
        'Payment parameters are missing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authService = Get.find<AuthService>();
    final apiService = Get.find<ApiService>();

    // Get current user
    final currentUser = authService.currentUser.value;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Please login to make payments',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare metadata (user_id is taken from JWT server-side — never send it in body)
      final metadata = <String, dynamic>{
        'description': 'Ekub contribution payment',
      };
      if (cycleNumber != null) metadata['cycle_number'] = cycleNumber;

      // Route to the correct endpoint based on selected gateway
      final String endpoint;
      switch (method) {
        case 'telebirr':
          endpoint = '/payments/telebirr/create';
          break;
        case 'addispay':
        default:
          endpoint = '/payments/create';
          break;
      }

      // Create payment session
      final response = await apiService.dio.post(
        endpoint,
        data: {
          'group_id': groupId,
          'amount': amount,
          'metadata': metadata,
        },
      );

      if (response.data['success'] == true) {
        final paymentData = response.data['data'];
        final paymentUrl = paymentData['gateway_url'] as String? ?? '';
        final paymentId = paymentData['paymentId'] as String? ?? '';

        // Guard: backend returned an empty checkout URL (e.g. stuck session)
        if (paymentUrl.isEmpty) {
          Get.snackbar(
            'Payment Error',
            'Payment session is unavailable. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Close the bottom sheet
        Get.back();

        // Navigate to WebView — pass gateway so the WebView knows which
        // callback URL pattern to intercept.
        final result = await Get.toNamed(
          '/payment-webview',
          arguments: {
            'url': paymentUrl,
            'paymentId': paymentId,
            'gateway': method, // 'addispay' | 'telebirr'
          },
        );

        // Handle payment result
        // WebView returns: 'success' | 'failed' | 'cancelled' | 'pending' | null
        // For non-success outcomes, abandon the stale payment so the next
        // attempt generates a fresh AddisPay session with a new UUID.
        if (result != 'success' && result != 'pending' && paymentId.isNotEmpty) {
          try {
            await apiService.dio.patch('/payments/$paymentId/abandon');
          } catch (_) {
            // best-effort — failure here just means the next attempt may return
            // the same session, which is still better than blocking the user
          }
        }

        if (result == 'success') {
          // Payment confirmed — show success and refresh data
          Get.snackbar(
            'Payment Successful',
            'Your payment has been processed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Refresh group detail page if it exists
          try {
            if (Get.isRegistered<GroupDetailController>()) {
              final groupDetailController = Get.find<GroupDetailController>();
              await groupDetailController.loadGroupDetails();
              await groupDetailController.loadMembers();
              groupDetailController.payments.clear();
              groupDetailController.history.clear();
            }
            if (Get.isRegistered<InKindDetailController>()) {
              final inKindDetailController = Get.find<InKindDetailController>();
              await inKindDetailController.loadGroupDetails();
              await inKindDetailController.loadMembers();
              inKindDetailController.payments.clear();
              inKindDetailController.history.clear();
            }
          } catch (e) {
            // Refresh errors are non-fatal
          }
        } else if (result == 'pending') {
          // Payment in flight — refresh so history tab shows latest DB state
          try {
            if (Get.isRegistered<GroupDetailController>()) {
              final groupDetailController = Get.find<GroupDetailController>();
              await groupDetailController.loadGroupDetails();
              await groupDetailController.loadMembers();
              groupDetailController.payments.clear();
              groupDetailController.history.clear();
            }
            if (Get.isRegistered<InKindDetailController>()) {
              final inKindDetailController = Get.find<InKindDetailController>();
              await inKindDetailController.loadGroupDetails();
              await inKindDetailController.loadMembers();
              inKindDetailController.payments.clear();
              inKindDetailController.history.clear();
            }
          } catch (e) {
            // non-fatal
          }
          Get.snackbar(
            'Payment Pending',
            'Your payment is being processed. You will be notified once confirmed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        } else if (result == 'failed') {
          // Payment failed
          Get.snackbar(
            'Payment Failed',
            'Your payment could not be processed. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
        // 'cancelled' or null — user chose to leave; no snackbar needed
      } else {
        Get.snackbar(
          'Payment Error',
          response.data['message'] ?? 'Failed to initiate payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      // Extract the backend error message from the response body when available.
      final responseData = e.response?.data;
      final serverMessage = responseData is Map
          ? (responseData['message'] ??
              responseData['error']?['message'] ??
              responseData['error'] as String?)
          : null;
      final statusCode = e.response?.statusCode ?? 0;

      String errorMessage = 'Failed to process payment';
      bool isDisqualified = false;
      bool showRetryButton = true;

      final msgLower = (serverMessage?.toString() ?? '').toLowerCase();
      if (msgLower.contains('disqualified')) {
        isDisqualified = true;
        showRetryButton = false;
        errorMessage =
            'You have been permanently disqualified from this group due to '
            'missed payments. You cannot make any further payments.';
      } else if (serverMessage != null && serverMessage.isNotEmpty) {
        errorMessage = serverMessage.toString();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet and try again.';
      } else if (statusCode == 401 || statusCode == 403) {
        errorMessage = 'Payment authorization failed. Please log in again.';
        showRetryButton = false;
      } else if (statusCode == 404) {
        errorMessage = 'Payment service not found. Please contact support.';
        showRetryButton = false;
      } else if (statusCode >= 500) {
        errorMessage = 'Payment server error. Please try again later.';
      }

      if (isDisqualified) {
        Get.dialog(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.block, color: Colors.red),
                SizedBox(width: 8),
                Text('Account Disqualified'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.back(); // close payment sheet
                },
                child: const Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Payment Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: showRetryButton
              ? TextButton(
                  onPressed: () {
                    Get.back(); // close snackbar
                    proceedToPayment(method, groupId, amount,
                        cycleNumber: cycleNumber);
                  },
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                )
              : null,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Payment Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onBottomNavTap(int index) {
    currentBottomNavIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}
