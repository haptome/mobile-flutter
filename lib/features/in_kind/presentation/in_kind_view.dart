// Purpose: In-Kind page view
// Author: Auto-generated
// Linked Spec Section: In-Kind Page

import 'package:et_digital_equb/core/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../controllers/in_kind_controller.dart';
import '../../../../core/widgets/scaffold_with_bottom_bar.dart';

class InKindView extends StatefulWidget {
  const InKindView({super.key});

  @override
  State<InKindView> createState() => _InKindViewState();
}

class _InKindViewState extends State<InKindView> {
  final InKindController _controller = Get.put(InKindController());

  @override
  Widget build(BuildContext context) {
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
                                  child: Text('retry'.tr),
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
                      // Display categories in rows of 3
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingLarge,
                        ),
                        child: Column(
                          children: [
                            for (
                              int i = 0;
                              i < _controller.inKindCategories.length;
                              i += 3
                            )
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.spacingMedium,
                                ),
                                child: Row(
                                  children: [
                                    for (
                                      int j = i;
                                      j < i + 3 &&
                                          j <
                                              _controller
                                                  .inKindCategories
                                                  .length;
                                      j++
                                    )
                                      CategoryCard(
                                        iconUrl:
                                            _controller
                                                .inKindCategories[j]
                                                .icon ??
                                            'material-symbols:category-outline',
                                        label: _controller
                                            .inKindCategories[j]
                                            .name,
                                        onTap: () => Get.toNamed(
                                          '/category-detail',
                                          arguments:
                                              _controller.inKindCategories[j],
                                        ),
                                      ),
                                    // Fill remaining slots with empty space
                                    if (_controller.inKindCategories.length -
                                            i <
                                        3)
                                      for (
                                        int k = 0;
                                        k <
                                            3 -
                                                (_controller
                                                        .inKindCategories
                                                        .length -
                                                    i);
                                        k++
                                      )
                                        const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
