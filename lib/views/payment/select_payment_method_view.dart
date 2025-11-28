// Purpose: Select Payment Method page
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/payment_logo.dart';
import '../../widgets/bottom_nav_bar.dart';

class SelectPaymentMethodView extends StatelessWidget {
  final String? ekubId;
  final double? amount;

  const SelectPaymentMethodView({
    super.key,
    this.ekubId,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'select_payment_method'.tr,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Obx(
                  () => Column(
                    children: [
                      // Chapa
                      PaymentMethodCard(
                        id: 'chapa',
                        name: 'Chapa',
                        logo: const ChapaLogo(),
                        description: controller.chapaDescription,
                        isSelected:
                            controller.selectedPaymentMethod.value == 'chapa',
                        onTap: () => controller.selectPaymentMethod('chapa'),
                        onProceed: () => controller.proceedToPayment('chapa'),
                      ),
                      // Arifpay
                      PaymentMethodCard(
                        id: 'arifpay',
                        name: 'Arifpay',
                        logo: const ArifpayLogo(),
                        description: controller.arifpayDescription,
                        isSelected:
                            controller.selectedPaymentMethod.value == 'arifpay',
                        onTap: () => controller.selectPaymentMethod('arifpay'),
                        onProceed: () => controller.proceedToPayment('arifpay'),
                      ),
                      // SANTIM PAY
                      PaymentMethodCard(
                        id: 'santim_pay',
                        name: 'SANTIM PAY',
                        logo: const SantimPayLogo(),
                        description: controller.santimPayDescription,
                        isSelected: controller.selectedPaymentMethod.value ==
                            'santim_pay',
                        onTap: () =>
                            controller.selectPaymentMethod('santim_pay'),
                        onProceed: () =>
                            controller.proceedToPayment('santim_pay'),
                      ),
                      // Telebirr (if needed)
                      PaymentMethodCard(
                        id: 'telebirr',
                        name: 'Telebirr',
                        logo: const ChapaLogo(), // Use placeholder logo
                        description: controller.telebirrDescription,
                        isSelected: controller.selectedPaymentMethod.value ==
                            'telebirr',
                        onTap: () => controller.selectPaymentMethod('telebirr'),
                        onProceed: () =>
                            controller.proceedToPayment('telebirr'),
                      ),
                    ],
                  ),
                ),
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
