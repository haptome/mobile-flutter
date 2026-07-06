// Purpose: Select Payment Method page
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:et_digital_equb/controllers/payment_controller.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/payment_logo.dart';
import 'package:et_digital_equb/core/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPaymentMethodView extends StatelessWidget {
  final String? ekubId;
  final double? amount;
  final int? cycleNumber;

  const SelectPaymentMethodView({
    super.key,
    this.ekubId,
    this.amount,
    this.cycleNumber,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLightGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bottom sheet handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'select_payment_method'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.lightTextPrimary,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Column(
                  children: [
                    // AddisPay
                    PaymentMethodCard(
                      id: 'addispay',
                      name: 'AddisPay',
                      logo: const AddisPayLogo(),
                      description: controller.addisPayDescription,
                      isSelected:
                          controller.selectedPaymentMethod.value == 'addispay',
                      onTap: () => controller.selectPaymentMethod('addispay'),
                      onProceed: () => controller.proceedToPayment(
                        'addispay',
                        ekubId,
                        amount,
                        cycleNumber: cycleNumber,
                      ),
                    ),
                    // TeleBirr
                    PaymentMethodCard(
                      id: 'telebirr',
                      name: 'telebirr'.tr,
                      logo: const TelebirrLogo(),
                      description: controller.telebirrDescription,
                      isSelected:
                          controller.selectedPaymentMethod.value == 'telebirr',
                      onTap: () => controller.selectPaymentMethod('telebirr'),
                      onProceed: () => controller.proceedToPayment(
                        'telebirr',
                        ekubId,
                        amount,
                        cycleNumber: cycleNumber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
