// Purpose: Ekub Type page view - shows cash categories
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../controllers/ekub_type_controller.dart';
import '../../../../core/widgets/scaffold_with_bottom_bar.dart';

class EkubTypeView extends StatelessWidget {
  const EkubTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EkubTypeController());

    return ScaffoldWithBottomBar(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context),
                    // Categories Grid
                    Obx(() => _buildCategoriesGrid(controller)),
                    const SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.lightTextPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'main_ekub'.tr,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.splashBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(EkubTypeController controller) {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(
          child: Column(
            children: [
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadCategories(),
                child: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.categories.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(child: Text('no_categories_found'.tr)),
      );
    }

    // Display categories in rows of 3
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Column(
        children: [
          for (int i = 0; i < controller.categories.length; i += 3)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
              child: Row(
                children: [
                  for (
                    int j = i;
                    j < i + 3 && j < controller.categories.length;
                    j++
                  )
                    CategoryCard(
                      iconUrl:
                          controller.categories[j].icon ??
                          'material-symbols:category-outline',
                      label: controller.categories[j].name,
                      onTap: () => Get.toNamed(
                        '/category-detail',
                        arguments: controller.categories[j],
                      ),
                    ),
                  // Fill remaining slots with empty space
                  if (controller.categories.length - i < 3)
                    for (
                      int k = 0;
                      k < 3 - (controller.categories.length - i);
                      k++
                    )
                      const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
