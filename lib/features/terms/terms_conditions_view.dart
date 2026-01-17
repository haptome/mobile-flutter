// Purpose: Terms & Conditions page
// Author: haptome H.
// Linked Spec Section: Terms & Conditions Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/app_button.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermsConditionsController>();

    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clause 1
                    _buildClause(
                      clause: '1. Acceptance of Terms',
                      paragraphs: [
                        'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 2
                    _buildClause(
                      clause: '2. User Responsibilities',
                      paragraphs: [
                        'You are responsible for maintaining the confidentiality of your account and password.',
                        'You agree to accept responsibility for all activities that occur under your account.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 3
                    _buildClause(
                      clause: '3. Service Description',
                      paragraphs: [
                        'The application provides digital equb services for financial savings and lending.',
                        'Services are subject to availability and may be modified or discontinued at any time.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 4
                    _buildClause(
                      clause: '4. Privacy Policy',
                      paragraphs: [
                        'We collect and use personal information in accordance with our Privacy Policy.',
                        'Your information will be protected and used only for providing our services.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clause 5
                    _buildClause(
                      clause: '5. Limitation of Liability',
                      paragraphs: [
                        'The service is provided "as is" without warranties of any kind, either express or implied.',
                      ],
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
                text: 'Agree & Continue'.tr,
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

  Widget _buildClause({
    required String clause,
    required List<String> paragraphs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$clause',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF494949),
          ),
        ),
        const SizedBox(height: 6),
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              paragraph,
              style: GoogleFonts.lato(
                fontSize: 16,
                height: 1.5,
                color: const Color(0xFF494949),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
