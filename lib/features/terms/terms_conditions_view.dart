// Purpose: Terms & Conditions page
// Author: haptome H.
// Linked Spec Section: Terms & Conditions Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/app_button.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/primary_button.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermsConditionsController>();

    return ScaffoldWithBottomBar(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'terms_conditions'.tr,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              'agreement_subtitle'.tr,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.normal,
                height: 1.25,
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
                    // Intro
                    Text(
                      'terms_intro'.tr,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF494949),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'terms_consent'.tr,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF494949),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 1
                    _buildSection(
                      title: 'terms_section_1_title'.tr,
                      content: ['terms_section_1_content'.tr],
                    ),
                    
                    // Section 2
                    _buildSection(
                      title: 'terms_section_2_title'.tr,
                      content: [
                        'terms_section_2_eligibility'.tr,
                        'terms_section_2_identification'.tr,
                        'terms_section_2_kyc'.tr,
                        'terms_section_2_one_account'.tr,
                      ],
                    ),
                    
                    // Section 3
                    _buildSection(
                      title: 'terms_section_3_title'.tr,
                      content: [
                        'terms_section_3_commitment'.tr,
                        'terms_section_3_lottery'.tr,
                        'terms_section_3_transparency'.tr,
                      ],
                    ),
                    
                    // Section 4
                    _buildSection(
                      title: 'terms_section_4_title'.tr,
                      content: [
                        'terms_section_4_service_fees'.tr,
                        'terms_section_4_deduction'.tr,
                        'terms_section_4_channels'.tr,
                      ],
                    ),
                    
                    // Section 5
                    _buildSection(
                      title: 'terms_section_5_title'.tr,
                      content: [
                        'terms_section_5_intro'.tr,
                        'terms_section_5_late_fees'.tr,
                        'terms_section_5_legal'.tr,
                      ],
                    ),
                    
                    // Section 6
                    _buildSection(
                      title: 'terms_section_6_title'.tr,
                      content: ['terms_section_6_content'.tr],
                    ),
                    
                    // Section 7
                    _buildSection(
                      title: 'terms_section_7_title'.tr,
                      content: [
                        'terms_section_7_outages'.tr,
                        'terms_section_7_substitute'.tr,
                        'terms_section_7_payout'.tr,
                        'terms_section_7_blacklist'.tr,
                        'terms_section_7_sos'.tr,
                        'terms_section_7_user_error'.tr,
                        'terms_section_7_indirect'.tr,
                      ],
                    ),
                    
                    // Section 8
                    _buildSection(
                      title: 'terms_section_8_title'.tr,
                      content: ['terms_section_8_content'.tr],
                    ),
                    
                    // Section 9
                    _buildSection(
                      title: 'terms_section_9_title'.tr,
                      content: [
                        'terms_section_9_mediation'.tr,
                        'terms_section_9_jurisdiction'.tr,
                      ],
                    ),
                    
                    // Section 10
                    _buildSection(
                      title: 'terms_section_10_title'.tr,
                      content: ['terms_section_10_content'.tr],
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Agree & Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: AppButton(
                text: 'agree_continue'.tr,
                onPressed: controller.onAgreeContinue,
                isLoading: controller.isAgreeing.value,
                isFullWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF494949),
            ),
          ),
          const SizedBox(height: 12),
          ...content.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      height: 1.6,
                      color: const Color(0xFF494949),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      paragraph,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        height: 1.6,
                        color: const Color(0xFF494949),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
