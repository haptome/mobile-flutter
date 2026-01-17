// Purpose: In-Kind page view
// Author: Auto-generated
// Linked Spec Section: In-Kind Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/category_section_cards.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../controllers/in_kind_controller.dart';

class InKindView extends StatefulWidget {
  const InKindView({super.key});

  @override
  State<InKindView> createState() => _InKindViewState();
}

class _InKindViewState extends State<InKindView> {
  int _currentNavIndex = 0;
  final InKindController _controller = Get.put(InKindController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _buildHeader(),
                    // In-Kind Categories from API
                    Obx(() {
                      if (_controller.isLoadingCategories.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (_controller.errorMessage.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  _controller.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      _controller.loadInKindCategories(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (_controller.inKindCategories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: Text('No in-kind categories found.'),
                          ),
                        );
                      }
                      return CategorySectionCards(
                        title: 'In-Kind Categories',
                        categories: _controller.inKindCategories,
                        onCategoryTap: _controller.onCategoryTap,
                        onViewAll: null,
                      );
                    }),
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

  Widget _buildHeader() {
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
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'In-Kind',
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
}
