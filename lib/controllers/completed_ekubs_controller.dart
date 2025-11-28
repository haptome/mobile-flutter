// Purpose: Controller for completed ekubs page
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:get/get.dart';

class CompletedEkubsController extends GetxController {
  final RxList<Map<String, dynamic>> allEkubs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredEkubs = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab

  @override
  void onInit() {
    super.onInit();
    _loadEkubs();
    // Listen to search query changes
    ever(searchQuery, (_) => _filterEkubs());
  }

  void _loadEkubs() {
    // Sample data - in real app, this would come from API
    allEkubs.value = [
      {
        'id': '1',
        'name': 'fridge_equb'.tr,
        'amount': '100,000 birr',
        'round': 7,
        'frequency': 'weekly'.tr,
        'duration': '3 ${'months'.tr}',
        'totalAmount': '100,000 ETB',
      },
      {
        'id': '2',
        'name': 'ekub_name'.tr,
        'amount': '50,000 birr',
        'round': 7,
        'frequency': 'monthly'.tr,
        'duration': '6 ${'months'.tr}',
        'totalAmount': '50,000 ETB',
      },
      {
        'id': '3',
        'name': 'ekub_name'.tr,
        'amount': '250,000 ETB birr',
        'round': 7,
        'frequency': 'weekly'.tr,
        'duration': '12 ${'months'.tr}',
        'totalAmount': '250,000 ETB',
      },
    ];
    _filterEkubs();
  }

  void _filterEkubs() {
    if (searchQuery.value.isEmpty) {
      filteredEkubs.value = allEkubs.value;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredEkubs.value = allEkubs.value
          .where((ekub) {
            final name = (ekub['name'] ?? '').toString().toLowerCase();
            return name.contains(query);
          })
          .toList();
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

  void onEkubTap(String ekubId) {
    // TODO: Navigate to ekub details
    Get.snackbar(
      'ekub_details'.tr,
      'ekub_id: $ekubId',
      snackPosition: SnackPosition.BOTTOM,
    );
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

