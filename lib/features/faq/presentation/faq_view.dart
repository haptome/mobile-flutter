// Purpose: FAQ/Help page
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/faq_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/main_wrapper.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();

    return MainWrapper(
      currentIndex: 1, // Your Ekubs tab
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'help'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'search_faq'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              // Tabs
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                child: Obx(
                  () => Row(
                    children: controller.tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final isSelected =
                          controller.selectedTabIndex.value == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.onTabSelected(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tab,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              // FAQ list
              Expanded(
                child: Obx(() {
                  if (controller.filteredFaqs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_faqs_found'.tr,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: AppColors.textLightGray,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                    ),
                    itemCount: controller.filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = controller.filteredFaqs[index];
                      return _buildFaqCard(context, faq);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: ExpansionTile(
        title: Text(
          faq['question'] ?? '',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              faq['answer'] ?? '',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.textLightGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
