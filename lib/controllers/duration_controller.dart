// Purpose: Controller for Duration page
// Author: haptome H.
// Linked Spec Section: Duration Page

import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/widgets/duration_filter_bottom_sheet.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class DurationController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final RxList<Group> allGroups = <Group>[].obs;
  final RxList<Group> filteredGroups = <Group>[].obs;
  final RxString selectedFrequency = 'all'.obs; // 'all', 'daily', 'weekly', 'monthly'
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['frequency'] != null) {
      selectedFrequency.value = args['frequency'] as String;
    }
    loadGroups();
    // Listen to filter changes
    ever(selectedFrequency, (_) => _filterGroups());
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _groupService.getGroups(
        status: 'active',
        limit: 100, // Get more groups to filter by frequency
      );

      if (response.success && response.data != null) {
        allGroups.value = response.data!;
        _filterGroups();
      } else {
        errorMessage.value = response.message ?? 'Failed to load groups';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading groups: $e');
      }
      errorMessage.value = 'Failed to load groups: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _filterGroups() {
    List<Group> filtered = List.from(allGroups);

    // Filter by frequency (if filter is set)
    if (selectedFrequency.value != 'all') {
      filtered = filtered
          .where((group) => group.frequency.toLowerCase() == selectedFrequency.value.toLowerCase())
          .toList();
    }

    filteredGroups.value = filtered;
  }

  Map<String, int> getFrequencyCounts() {
    final counts = <String, int>{};
    for (var group in allGroups) {
      final frequency = group.frequency.toLowerCase();
      counts[frequency] = (counts[frequency] ?? 0) + 1;
    }
    return counts;
  }

  void onFrequencyTap(String frequency) {
    selectedFrequency.value = frequency;
  }

  void onFilterTap() {
    Get.bottomSheet(
      DurationFilterBottomSheet(
        selectedFilter: selectedFrequency,
        onFilterSelected: (filter) {
          selectedFrequency.value = filter;
        },
      ),
      isScrollControlled: true,
    );
  }

  void onGroupTap(Group group) {
    Get.toNamed('/group-detail', arguments: group);
  }
}

