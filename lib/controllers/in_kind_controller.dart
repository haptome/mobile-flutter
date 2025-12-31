// Purpose: Controller for In-Kind page
// Author: haptome H.
// Linked Spec Section: In-Kind Page

import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/widgets/price_range_filter_bottom_sheet.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class InKindController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final RxList<category_models.Category> inKindCategories = <category_models.Category>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString selectedFilter = 'all'.obs;

  List<String> get categories => ['all'.tr, 'merchant'.tr, 'driver'.tr, 'employees'.tr];

  @override
  void onInit() {
    super.onInit();
    loadInKindCategories();
    // Listen to category and filter changes
    ever(selectedCategoryIndex, (_) => _filterCategories());
    ever(selectedFilter, (_) => _filterCategories());
  }

  Future<void> loadInKindCategories() async {
    try {
      isLoadingCategories.value = true;
      errorMessage.value = '';
      
      final response = await _groupService.getCategories(
        categoryType: 'in_kind',
        isActive: true,
      );

      if (response.success && response.data != null) {
        inKindCategories.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to load in-kind categories';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading in-kind categories: $e');
      }
      errorMessage.value = 'Failed to load in-kind categories: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void _filterCategories() {
    // Filtering logic can be added here if needed
    // For now, we just display all categories
  }

  void onCategoryTap(category_models.Category category) {
    Get.toNamed('/category-detail', arguments: category);
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

