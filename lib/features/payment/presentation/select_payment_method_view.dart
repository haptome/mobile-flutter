// Purpose: Select Payment Method page
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/payment_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_wrapper.dart';

class SelectPaymentMethodView extends StatelessWidget {
  final String? ekubId;
  final double? amount;

  const SelectPaymentMethodView({super.key, this.ekubId, this.amount});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

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
            'select_payment_method'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Column(
                children: [
                  _buildPaymentMethodCard(
                    context,
                    controller,
                    'chapa',
                    'Chapa',
                    controller.chapaDescription,
                    Icons.payment,
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(
                    context,
                    controller,
                    'arifpay',
                    'Arifpay',
                    controller.arifpayDescription,
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(
                    context,
                    controller,
                    'santim_pay',
                    'SANTIM PAY',
                    controller.santimPayDescription,
                    Icons.mobile_friendly,
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(
                    context,
                    controller,
                    'telebirr',
                    'Telebirr',
                    controller.telebirrDescription,
                    Icons.phone_android,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    PaymentController controller,
    String id,
    String name,
    String description,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == id;
      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLightGray,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.proceedToPayment(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'proceed_to_payment'.tr,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
