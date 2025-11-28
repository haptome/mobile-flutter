// Purpose: Controller for Duration page
// Author: haptome H.
// Linked Spec Section: Duration Page

import 'package:get/get.dart';
import '../widgets/duration_filter_bottom_sheet.dart';

class DurationController extends GetxController {
  final RxList<Map<String, dynamic>> allEkubs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredEkubs = <Map<String, dynamic>>[].obs;
  final RxString selectedFilter = 'all'.obs; // Store filter key, not translated text

  @override
  void onInit() {
    super.onInit();
    _loadEkubs();
    // Listen to filter changes
    ever(selectedFilter, (_) => _filterEkubs());
  }

  void _loadEkubs() {
    // Sample data - in real app, this would come from API
    allEkubs.value = [
      {
        'id': '1',
        'name': 'fridge_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'duration': '3 ${'months'.tr}',
        'totalAmount': '100,000 ETB',
        'memberCount': 4,
        'memberAvatars': [],
      },
      {
        'id': '2',
        'name': 'koka_tv_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'duration': '6 ${'months'.tr}',
        'totalAmount': '120,000 ETB',
        'memberCount': 8,
        'memberAvatars': [],
      },
      {
        'id': '3',
        'name': 'byd_seagull_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'duration': '1 ${'year'.tr}',
        'totalAmount': '260,000 ETB',
        'memberCount': 12,
        'memberAvatars': [],
      },
      {
        'id': '4',
        'name': 'koka_tv_equb'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'duration': '3 ${'months'.tr}',
        'totalAmount': '65,000 ETB',
        'memberCount': 5,
        'memberAvatars': [],
      },
      {
        'id': '5',
        'name': 'byd_seagull_equb_short'.tr,
        'frequency': 'weekly'.tr,
        'amount': '5,000 Birr',
        'duration': '6 ${'months'.tr}',
        'totalAmount': '130,000 ETB',
        'memberCount': 10,
        'memberAvatars': [],
      },
    ];
    _filterEkubs();
  }

  void _filterEkubs() {
    List<Map<String, dynamic>> filtered = List.from(allEkubs);

    // Filter by duration (if filter is set)
    if (selectedFilter.value != 'all') {
      // TODO: Implement duration filtering logic based on selectedFilter
      // For now, just pass through
    }

    filteredEkubs.value = filtered;
  }

  void onFilterTap() {
    Get.bottomSheet(
      DurationFilterBottomSheet(
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

