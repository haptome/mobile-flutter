// Purpose: Completed Ekubs page
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/completed_ekubs_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/completed_ekub_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class CompletedEkubsView extends StatelessWidget {
  const CompletedEkubsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompletedEkubsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'completed_ekubs'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with filter
            SearchBarWidget(
              hintText: 'search'.tr,
              onChanged: controller.onSearchChanged,
              onFilterTap: controller.onFilterTap,
            ),
            // Ekubs list
            Expanded(
              child: Obx(
                () {
                  if (controller.filteredEkubs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_completed_ekubs'.tr,
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
                      return CompletedEkubCard(
                        id: ekub['id'] ?? '',
                        name: ekub['name'] ?? '',
                        amount: ekub['amount'] ?? '',
                        round: ekub['round'] ?? 0,
                        frequency: ekub['frequency'] ?? '',
                        duration: ekub['duration'] ?? '',
                        totalAmount: ekub['totalAmount'] ?? '',
                        onTap: () => controller.onEkubTap(ekub['id'] ?? ''),
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

