// Purpose: Controller for Ekub Type page
// Author: Auto-generated

import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/core/routes/app_routes.dart';

class EkubTypeController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final RxList<category_models.Category> categories =
      <category_models.Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _groupService.getCategories(
        categoryType: 'cash',
        isActive: true,
      );

      if (response.success && response.data != null) {
        categories.value = List<category_models.Category>.from(response.data!);
      } else {
        errorMessage.value = response.message ?? 'Failed to load categories';
      }
    } catch (e) {
      errorMessage.value = 'Error loading categories: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onCategoryTap(category_models.Category category) {
    // Navigate to Create Group page instead of category detail
    Get.toNamed(AppRoutes.categoryDetail);
  }
}
