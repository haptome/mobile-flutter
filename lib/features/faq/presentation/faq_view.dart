// Purpose: FAQ/Help page
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/faq_item.dart';
import 'package:et_digital_equb/core/widgets/search_bar_widget.dart';
import 'package:et_digital_equb/core/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/faq_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/scaffold_with_bottom_bar.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();

    return ScaffoldWithBottomBar(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              'faq'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            TranslatedText(
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
            // Category dropdown
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLightGray),
                  ),
                  child: DropdownButton<int>(
                    value: controller.selectedTabIndex.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                    items: List.generate(
                      controller.tabs.length,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          controller.tabs[index],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        controller.onTabSelected(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            // Search section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'how_can_we_help'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
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
                  TranslatedText(
                    'top_questions'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
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
              child: Obx(() {
                if (controller.filteredFaqs.isEmpty) {
                  return Center(
                    child: TranslatedText(
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
                    final questionKey = faq['question']?.toString() ?? '';
                    final answerKey = faq['answer']?.toString() ?? '';
                    return FaqItem(
                      id: faq['id']?.toString() ?? '',
                      question: questionKey.tr,
                      answer: answerKey.tr,
                      usersAsked: faq['usersAsked'] ?? 0,
                      userAvatars: faq['userAvatars'] != null
                          ? List<String>.from(faq['userAvatars'] as List)
                          : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
