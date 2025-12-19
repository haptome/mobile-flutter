// Purpose: Controller for In-Kind page
// Author: haptome H.
// Linked Spec Section: In-Kind Page

import 'package:et_digital_equb/core/widgets/price_range_filter_bottom_sheet.dart';
import 'package:get/get.dart';

class InKindController extends GetxController {
  final RxList<Map<String, dynamic>> allEkubs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredEkubs = <Map<String, dynamic>>[].obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString selectedFilter = 'all'.obs; // Store filter key, not translated text

  List<String> get categories => ['all'.tr, 'merchant'.tr, 'driver'.tr, 'employees'.tr];

  @override
  void onInit() {
    super.onInit();
    _loadEkubs();
    // Listen to category and filter changes
    ever(selectedCategoryIndex, (_) => _filterEkubs());
    ever(selectedFilter, (_) => _filterEkubs());
  }

  void _loadEkubs() {
    // Sample data - in real app, this would come from API
    allEkubs.value = [
      {
        'id': '1',
        'name': 'fridge_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '100,000 ETB',
        'duration': '3 ${'months'.tr}',
        'category': 'driver',
        'memberCount': 4,
        'memberAvatars': [],
      },
      {
        'id': '2',
        'name': 'samsung_a15_equb'.tr,
        'frequency': 'monthly'.tr,
        'amount': '5,000 Birr',
        'duration': '6 ${'months'.tr}',
        'category': 'merchant',
        'memberCount': 8,
        'memberAvatars': [],
      },
      {
        'id': '3',
        'name': 'byd_seagull_equb'.tr,
        'frequency': 'monthly'.tr,
        'amount': '5,000 Birr',
        'duration': '1 ${'year'.tr}',
        'category': 'employees',
        'memberCount': 12,
        'memberAvatars': [],
      },
      {
        'id': '4',
        'name': 'koka_tv_equb'.tr,
        'frequency': 'monthly'.tr,
        'amount': '5,000 Birr',
        'duration': '6 ${'months'.tr}',
        'category': 'merchant',
        'memberCount': 10,
        'memberAvatars': [],
      },
    ];
    _filterEkubs();
  }

  void _filterEkubs() {
    List<Map<String, dynamic>> filtered = List.from(allEkubs);

    // Filter by category
    if (selectedCategoryIndex.value > 0) {
      final categoryKeys = ['all', 'merchant', 'driver', 'employees'];
      final selectedCategoryKey = categoryKeys[selectedCategoryIndex.value];
      filtered = filtered
          .where((ekub) => (ekub['category'] as String) == selectedCategoryKey)
          .toList();
    }

    // Filter by price range (if filter is set)
    if (selectedFilter.value != 'all') {
      // TODO: Implement price range filtering logic
      // For now, just pass through
    }

    filteredEkubs.value = filtered;
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
  }

  void onFilterTap() {
    Get.bottomSheet(
      PriceRangeFilterBottomSheet(
        selectedFilter: selectedFilter,
        onFilterSelected: (filter) {
          selectedFilter.value = filter;
        },
      ),
      isScrollControlled: true,
    );
  }

  void onJoinEkub(String ekubId) {
    // TODO: Navigate to join ekub page or show join dialog
    Get.snackbar(
      'join_ekub'.tr,
      'joining_ekub'.tr.replaceAll('{id}', ekubId),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

