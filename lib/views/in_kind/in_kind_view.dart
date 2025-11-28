// Purpose: In-Kind page
// Author: haptome H.
// Linked Spec Section: In-Kind Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/in_kind_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/category_tabs.dart';
import '../../widgets/ekub_type_card.dart';

class InKindView extends StatelessWidget {
  const InKindView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InKindController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'in_kind'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_outlined,
              color: AppColors.textDark,
            ),
            onPressed: controller.onFilterTap,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Tabs
            Obx(
              () => CategoryTabs(
                categories: controller.categories,
                selectedIndex: controller.selectedCategoryIndex.value,
                onTabSelected: controller.onCategorySelected,
              ),
            ),
            // Ekub List
            Expanded(
              child: Obx(
                () {
                  if (controller.filteredEkubs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_ekubs_found'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textLightGray,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: controller.filteredEkubs.length,
                    itemBuilder: (context, index) {
                      final ekub = controller.filteredEkubs[index];
                      return EkubTypeCard(
                        id: ekub['id'] ?? '',
                        name: ekub['name'] ?? '',
                        frequency: ekub['frequency'] ?? '',
                        amount: ekub['amount'] ?? '',
                        duration: ekub['duration'] ?? '',
                        memberCount: ekub['memberCount'] ?? 0,
                        memberAvatars: ekub['memberAvatars'] != null
                            ? List<String>.from(ekub['memberAvatars'] as List)
                            : null,
                        onJoin: () => controller.onJoinEkub(ekub['id'] ?? ''),
                        initiallyExpanded: index == 0, // First card expanded
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

