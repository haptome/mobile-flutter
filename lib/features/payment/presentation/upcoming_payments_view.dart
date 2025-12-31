// Purpose: Upcoming Payments page
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/upcoming_payments_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/main_wrapper.dart';

class UpcomingPaymentsView extends StatelessWidget {
  const UpcomingPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpcomingPaymentsController>();

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
            'upcoming'.tr,
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
                    hintText: 'search_payments'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              // Payments list
              Expanded(
                child: Obx(() {
                  if (controller.filteredPayments.isEmpty) {
                    return Center(
                      child: Text(
                        'no_upcoming_payments'.tr,
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
                    itemCount: controller.filteredPayments.length,
                    itemBuilder: (context, index) {
                      final monthData = controller.filteredPayments[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.spacingMedium,
                            ),
                            child: Text(
                              monthData['month'] as String,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          ...((monthData['payments'] as List).map((payment) {
                            return _buildPaymentCard(
                              context,
                              controller,
                              payment,
                            );
                          })),
                        ],
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

  Widget _buildPaymentCard(
    BuildContext context,
    UpcomingPaymentsController controller,
    Map<String, dynamic> payment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (payment['colorType'] == 'yellow')
                ? Colors.yellow[100]
                : Colors.teal[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (payment['round'] ?? '').toString(),
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        title: Text(
          payment['ekubName'] ?? '',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${payment['date']} • ${payment['frequency']}',
          style: GoogleFonts.montserrat(fontSize: 12),
        ),
        trailing: Text(
          '${payment['amount']} ETB',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        onTap: () => controller.onPaymentTap(payment['id'] ?? ''),
      ),
    );
  }
}
