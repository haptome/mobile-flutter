// Purpose: Lottery page with Spin the Wheel
// Author: haptome H.
// Linked Spec Section: Lottery Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lottery_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/spin_wheel.dart';
import '../../widgets/spin_button.dart';
import '../../widgets/main_scaffold.dart';

class LotteryView extends StatefulWidget {
  const LotteryView({super.key});

  @override
  State<LotteryView> createState() => _LotteryViewState();
}

class _LotteryViewState extends State<LotteryView> {
  final GlobalKey<SpinWheelState> _wheelKey = GlobalKey<SpinWheelState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LotteryController>();

    return MainScaffold(
      backgroundColor: AppColors.backgroundWhite,
      initialBottomNavIndex:
          1, // Your Ekubs tab (since lottery is accessed from there)
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'lottery'.tr,
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
              Icons.refresh_outlined,
              color: AppColors.textDark,
            ),
            onPressed: controller.onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Title - Left aligned
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'spin_the'.tr + ' ',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary, // Light green/yellow
                              ),
                            ),
                            TextSpan(
                              text: 'wheel'.tr,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary, // Dark teal/green
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle - Left aligned
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'win'.tr + ' ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary, // Dark teal/green
                              ),
                            ),
                            TextSpan(
                              text: 'lotterys'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary, // Light green/yellow
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Spin Wheel - Centered
                      Center(
                        child: SpinWheel(
                          key: _wheelKey,
                          prizes: controller.prizes,
                          onSpinComplete: controller.onSpinComplete,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Spin Button
                      Center(
                        child: Obx(
                          () => SpinButton(
                            isSpinning: controller.isSpinning.value,
                            onSpin: () {
                              controller.spin();
                              _wheelKey.currentState?.spin();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Last win message (if any)
                      Obx(
                        () => controller.lastWonPrize.value > 0
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'you_won'.tr.replaceAll(
                                          '{amount}',
                                          '${controller.lastWonPrize.value}',
                                        ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
