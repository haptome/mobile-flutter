// Purpose: Controller for payment selection
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

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
  final String chapaDescription =
      'Secure and fast payment gateway. Pay with your mobile money.';
  final String arifpayDescription =
      'Secure payment gateway for Ethiopian businesses. Fast and reliable transactions.';
  final String santimPayDescription =
      'Simple and secure payment solution. Pay with ease using SANTIM PAY.';
  final String telebirrDescription =
      'Pay directly using your Telebirr account. Quick and convenient.';

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
      // Prepare metadata
      final metadata = {
        'description': 'Ekub contribution payment',
        'phone_number': currentUser.phone,
        'first_name': currentUser.fullName?.split(' ').first ?? 'User',
        'last_name': currentUser.fullName?.split(' ').skip(1).join(' ') ?? '',
      };

      // Create payment session
      final response = await apiService.dio.post(
        '/payments/create',
        data: {
          'user_id': currentUser.id,
          'group_id': groupId,
          'amount': amount,
          'gateway': method,
          'cycle_number': cycleNumber,
          'metadata': metadata,
        },
      );

      if (response.data['success'] == true) {
        final paymentData = response.data['data'];
        final paymentUrl = paymentData['gateway_url'];
        final paymentId = paymentData['paymentId'];

        // Close the bottom sheet
        Get.back();

        // Navigate to WebView for payment
        final result = await Get.toNamed(
          '/payment-webview',
          arguments: {
            'url': paymentUrl,
            'paymentId': paymentId,
          },
        );

        // Handle payment result
        if (result == true) {
          // Payment successful
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
              print('PaymentController - Refreshing group detail page');
              await groupDetailController.loadGroupDetails();
              await groupDetailController.loadMembers();
              // Clear cached data to force reload on tab switch
              groupDetailController.payments.clear();
              groupDetailController.history.clear();
            }
            
            // Also refresh in-kind detail page if it exists
            if (Get.isRegistered<InKindDetailController>()) {
              final inKindDetailController = Get.find<InKindDetailController>();
              print('PaymentController - Refreshing in-kind detail page');
              await inKindDetailController.loadGroupDetails();
              await inKindDetailController.loadMembers();
              // Clear cached data to force reload on tab switch
              inKindDetailController.payments.clear();
              inKindDetailController.history.clear();
            }
          } catch (e) {
            print('PaymentController - Error refreshing detail page: $e');
          }
        } else if (result == false) {
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
        // If result is null, user cancelled
      } else {
        Get.snackbar(
          'Payment Error',
          response.data['message'] ?? 'Failed to initiate payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Payment error: $e');
      
      // Extract error message from response if available
      String errorMessage = 'Failed to process payment';
      
      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        // Try to extract the actual error message
        if (e.toString().contains('Invalid API Key') || 
            e.toString().contains('business can\'t accept payments')) {
          errorMessage = 'Payment service is temporarily unavailable. Please contact support or try again later.';
        } else if (e.toString().contains('400')) {
          errorMessage = 'Invalid payment request. Please check your details and try again.';
        } else if (e.toString().contains('401') || e.toString().contains('403')) {
          errorMessage = 'Payment authorization failed. Please login again.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Payment service not found. Please contact support.';
        } else if (e.toString().contains('500') || e.toString().contains('502') || e.toString().contains('503')) {
          errorMessage = 'Payment server error. Please try again later.';
        } else if (e.toString().contains('timeout') || e.toString().contains('connection')) {
          errorMessage = 'Connection timeout. Please check your internet and try again.';
        }
      }
      
      Get.snackbar(
        'Payment Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            // Optionally retry
            proceedToPayment(method, groupId, amount, cycleNumber: cycleNumber);
          },
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
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
