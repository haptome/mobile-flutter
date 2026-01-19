// Purpose: Category Detail page - shows groups in a category
// Author: Auto-generated

import 'package:et_digital_equb/core/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_design/iconify_design.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/category_model.dart' as category_models;
import '../../../../models/group_model.dart';
import '../../../../controllers/category_detail_controller.dart';
import '../../../../core/widgets/ekub_list_item.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import '../../../../core/theme/app_text_styles.dart';

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
        title: Row(
          children: [
            if (controller.category.value.icon != null)
              IconifyIcon(
                icon: controller.category.value.icon!,
                size: 24.0,
                color: AppColors.splashBackground,
              ),
            const SizedBox(width: 8),
            Text(
              controller.category.value.name,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.splashBackground,
              ),
            ),
          ],
        ),
        centerTitle: false,
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

        // Group groups by frequency
        final Map<String, List<Group>> grouped = {};
        for (var g in controller.groups) {
          final key = (g.frequency ?? 'other').toLowerCase();
          grouped.putIfAbsent(key, () => []).add(g);
        }

        // Build a scrollable list with collapsible sections
        return ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // Collapsible sections
            for (var entry in grouped.entries)
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                color: AppColors.white,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  childrenPadding: const EdgeInsets.all(AppSizes.paddingMedium),
                  initiallyExpanded: true,
                  title: Text(
                    entry.key[0].toUpperCase() + entry.key.substring(1),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.splashBackground,
                    ),
                  ),
                  children: entry.value.map((g) {
                    return EkubListItem.fromGroup(
                      g,
                      onJoin: () => controller.onJoinTap(g),
                      onTap: () => controller.onGroupTap(g),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
    );
  }
}
