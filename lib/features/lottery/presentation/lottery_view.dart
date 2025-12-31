// Purpose: Lottery page
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/main_wrapper.dart';
import '../../../../controllers/lottery_controller.dart';

class LotteryView extends StatelessWidget {
  const LotteryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LotteryController>();

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
            'lottery'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.black),
              onPressed: controller.onRefresh,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'spin_to_win'.tr,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXLarge),
                  Obx(() {
                    if (controller.lastWonPrize.value > 0) {
                      return Column(
                        children: [
                          Text(
                            '${controller.lastWonPrize.value} ETB',
                            style: GoogleFonts.montserrat(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingMedium),
                          Text(
                            'you_won'.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: AppColors.textLightGray,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: AppSizes.spacingXLarge),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSpinning.value
                          ? null
                          : controller.spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingLarge * 2,
                          vertical: AppSizes.paddingMedium,
                        ),
                      ),
                      child: controller.isSpinning.value
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : Text(
                              'spin'.tr,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
