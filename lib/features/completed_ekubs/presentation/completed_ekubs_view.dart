// Purpose: Completed Ekubs page
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/completed_ekubs_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/main_wrapper.dart';

class CompletedEkubsView extends StatelessWidget {
  const CompletedEkubsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompletedEkubsController>();

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
            'completed'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.black),
              onPressed: controller.onFilterTap,
            ),
          ],
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
                    hintText: 'search_ekubs'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              // Completed ekubs list
              Expanded(
                child: Obx(() {
                  if (controller.filteredEkubs.isEmpty) {
                    return Center(
                      child: Text(
                        'no_completed_ekubs'.tr,
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
                    itemCount: controller.filteredEkubs.length,
                    itemBuilder: (context, index) {
                      final ekub = controller.filteredEkubs[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSizes.spacingMedium,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                          title: Text(
                            ekub['name'] ?? '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${ekub['amount']} • ${ekub['frequency']}'),
                              Text(
                                '${ekub['duration']} • Round ${ekub['round']}',
                              ),
                            ],
                          ),
                          trailing: Text(
                            ekub['totalAmount'] ?? '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          onTap: () => controller.onEkubTap(ekub['id'] ?? ''),
                        ),
                      );
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
}
