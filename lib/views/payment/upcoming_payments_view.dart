// Purpose: Upcoming Payments page
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/upcoming_payments_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/month_section.dart';
import '../../widgets/bottom_nav_bar.dart';

class UpcomingPaymentsView extends StatelessWidget {
  const UpcomingPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpcomingPaymentsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'upcoming_payments'.tr,
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
            // Payments list
            Expanded(
              child: Obx(
                () {
                  if (controller.filteredPayments.isEmpty) {
                    return Center(
                      child: Text(
                        'no_upcoming_payments'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textLightGray,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.filteredPayments.length,
                    itemBuilder: (context, index) {
                      final monthData = controller.filteredPayments[index];
                      return MonthSection(
                        month: monthData['month'] ?? '',
                        payments: monthData['payments'] ?? [],
                        onPaymentTap: controller.onPaymentTap,
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

