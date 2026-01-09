// Purpose: Ekub Type page view - shows cash categories
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../controllers/ekub_type_controller.dart';

class EkubTypeView extends StatelessWidget {
  const EkubTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EkubTypeController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Background image with gradient overlay
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.authBackground,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.lightBackground);
                  },
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0024, 0.2921, 0.5801, 0.8322],
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.9),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
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
        ],
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
                'Ekub Type',
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(child: Text('No categories found')),
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
                          controller.categories[j].iconUrl ??
                          'material-symbols:category-outline',
                      label: controller.categories[j].name,
                      onTap: () =>
                          controller.onCategoryTap(controller.categories[j]),
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
