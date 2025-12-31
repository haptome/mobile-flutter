// Purpose: Controller for Category Detail page
// Author: Auto-generated

import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/models/group_model.dart';

class CategoryDetailController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final Rx<category_models.Category> category;
  final RxList<Group> groups = <Group>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  CategoryDetailController({required category_models.Category category})
    : category = category.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _groupService.getGroups(
        categoryId: category.value.id,
        status: 'active', // Only show active groups
      );

      if (response.success && response.data != null) {
        groups.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to load groups';
      }
    } catch (e) {
      errorMessage.value = 'Error loading groups: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onGroupTap(Group group) {
    Get.toNamed('/group-detail', arguments: group);
  }
}
