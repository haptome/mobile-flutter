// Purpose: Controller for upcoming payments page
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:get/get.dart';

class UpcomingPaymentsController extends GetxController {
  final RxList<Map<String, dynamic>> allPayments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredPayments = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab

  @override
  void onInit() {
    super.onInit();
    _loadPayments();
    // Listen to search query changes
    ever(searchQuery, (_) => _filterPayments());
  }

  void _loadPayments() {
    // Sample data - in real app, this would come from API
    allPayments.value = [
      {
        'month': 'november'.tr,
        'payments': [
          {
            'id': '1',
            'ekubName': 'ekub_name'.tr,
            'date': '10/22/25',
            'round': '2',
            'frequency': 'weekly'.tr,
            'amount': '5,000',
            'colorType': 'yellow',
          },
          {
            'id': '2',
            'ekubName': 'ekub_name'.tr,
            'date': '10/22/25',
            'round': '2',
            'frequency': 'daily'.tr,
            'amount': '5,000',
            'colorType': 'teal',
          },
        ],
      },
      {
        'month': 'december'.tr,
        'payments': [
          {
            'id': '3',
            'ekubName': 'ekub_name'.tr,
            'date': '12/15/25',
            'round': '3',
            'frequency': 'weekly'.tr,
            'amount': '5,000',
            'colorType': 'yellow',
          },
        ],
      },
      {
        'month': 'january'.tr,
        'payments': [
          {
            'id': '4',
            'ekubName': 'ekub_name'.tr,
            'date': '01/10/26',
            'round': '1',
            'frequency': 'monthly'.tr,
            'amount': '10,000',
            'colorType': 'teal',
          },
        ],
      },
    ];
    _filterPayments();
  }

  void _filterPayments() {
    if (searchQuery.value.isEmpty) {
      filteredPayments.value = allPayments.value;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredPayments.value = allPayments.value.map((monthData) {
        final payments = (monthData['payments'] as List)
            .where((payment) {
              final ekubName = (payment['ekubName'] ?? '').toString().toLowerCase();
              final date = (payment['date'] ?? '').toString().toLowerCase();
              return ekubName.contains(query) || date.contains(query);
            })
            .toList();
        return {
          'month': monthData['month'],
          'payments': payments,
        };
      }).where((monthData) => (monthData['payments'] as List).isNotEmpty).toList();
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onFilterTap() {
    // TODO: Show filter dialog
    Get.snackbar(
      'filter'.tr,
      'filter_options'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onPaymentTap(String paymentId) {
    // TODO: Navigate to payment details or payment method selection
    Get.snackbar(
      'payment'.tr,
      'payment_details'.tr.replaceAll('{id}', paymentId),
      snackPosition: SnackPosition.BOTTOM,
    );
    // Get.toNamed('/select-payment-method', arguments: {'paymentId': paymentId});
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

