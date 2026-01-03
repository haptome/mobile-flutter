// Purpose: Terms & Conditions page
// Author: haptome H.
// Linked Spec Section: Terms & Conditions Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermsConditionsController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'terms_conditions'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            Text(
              'agreement_subtitle'.tr,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLightGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clause 1
                    _buildClause(
                      number: 1,
                      paragraphs: ['clause_1_paragraph_1'.tr],
                    ),
                    const SizedBox(height: 24),
                    // Clause 2
                    _buildClause(
                      number: 2,
                      paragraphs: [
                        'clause_2_paragraph_1'.tr,
                        'clause_2_paragraph_2'.tr,
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 3
                    _buildClause(
                      number: 3,
                      paragraphs: [
                        'clause_3_paragraph_1'.tr,
                        'clause_3_paragraph_2'.tr,
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 4
                    _buildClause(
                      number: 4,
                      paragraphs: [
                        'clause_4_paragraph_1'.tr,
                        'clause_4_paragraph_2'.tr,
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 5
                    _buildClause(
                      number: 5,
                      paragraphs: ['clause_5_paragraph_1'.tr],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Agree & Continue Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'agree_continue'.tr,
                onPressed: controller.onAgreeContinue,
                isLoading: controller.isAgreeing.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClause({required int number, required List<String> paragraphs}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ${'clause'.tr} $number',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              paragraph,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
