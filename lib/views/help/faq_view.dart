// Purpose: FAQ/Help page
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/faq_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/tab_selector.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/faq_item.dart';
import '../../widgets/bottom_nav_bar.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'faq'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'explore_faq'.tr,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLightGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab selector
            Obx(
              () => TabSelector(
                tabs: controller.tabs,
                selectedIndex: controller.selectedTabIndex.value,
                onTabSelected: controller.onTabSelected,
              ),
            ),
            // Search section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'how_can_we_help'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchBarWidget(
                    hintText: 'search'.tr,
                    onChanged: controller.onSearchChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Top Questions section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'top_questions'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.onViewAll,
                    child: Text(
                      'view_all'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // FAQ list
            Expanded(
              child: Obx(
                () {
                  if (controller.filteredFaqs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_faqs_found'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textLightGray,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: controller.filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = controller.filteredFaqs[index];
                      return FaqItem(
                        id: faq['id'] ?? '',
                        question: faq['question'] ?? '',
                        answer: faq['answer'] ?? '',
                        usersAsked: faq['usersAsked'] ?? 0,
                        userAvatars: faq['userAvatars'] != null
                            ? List<String>.from(faq['userAvatars'] as List)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar - Use Scaffold's bottomNavigationBar property
      bottomNavigationBar: Obx(
        () => BottomNavBar(
          currentIndex: controller.currentBottomNavIndex.value,
          onTap: controller.onBottomNavTap,
        ),
      ),
    );
  }
}

