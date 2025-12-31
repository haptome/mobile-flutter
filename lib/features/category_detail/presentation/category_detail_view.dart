// Purpose: Category Detail page - shows groups in a category
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/category_model.dart' as category_models;
import '../../../../models/group_model.dart';
import '../../../../controllers/category_detail_controller.dart';

class CategoryDetailView extends StatelessWidget {
  const CategoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get category from arguments or from controller if already registered
    category_models.Category? category;
    if (Get.isRegistered<CategoryDetailController>()) {
      category = Get.find<CategoryDetailController>().category.value;
    } else {
      category = Get.arguments as category_models.Category?;
      if (category == null) {
        // If no category, show error
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.lightTextPrimary,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(child: Text('Category not found')),
        );
      }
      Get.put(CategoryDetailController(category: category));
    }

    final controller = Get.find<CategoryDetailController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.category.value.name,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadGroups(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.groups.isEmpty) {
          return Center(
            child: Text(
              'No groups found in this category',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppColors.textLightGray,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            return _buildGroupCard(group, controller);
          },
        );
      }),
    );
  }

  Widget _buildGroupCard(Group group, CategoryDetailController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: () => controller.onGroupTap(group),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackground,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: group.type == 'public'
                          ? Colors.green
                          : group.type == 'private'
                          ? Colors.orange
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                '${group.contributionAmount.toStringAsFixed(0)} ETB / ${group.frequency}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.textLightGray,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppColors.textLightGray),
                  const SizedBox(width: 4),
                  Text(
                    '${group.currentMembers} / ${group.targetMembers} members',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textLightGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
