// Purpose: Privacy Policy page
// Author: haptome H.
// Linked Spec Section: Privacy Policy Page

import 'package:et_digital_equb/core/widgets/app_button.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
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
              'privacy_policy_title'.tr,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              'privacy_policy_subtitle'.tr,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro
              Text(
                'privacy_intro'.tr,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF494949),
                ),
              ),
              const SizedBox(height: 24),
              
              // Section I - Definitions
              _buildSection(
                title: 'privacy_section_1_title'.tr,
                content: [
                  'privacy_section_1_service'.tr,
                  'privacy_section_1_protected'.tr,
                  'privacy_section_1_user'.tr,
                ],
              ),
              
              // Section II - Information We Collect
              _buildSection(
                title: 'privacy_section_2_title'.tr,
                intro: 'privacy_section_2_intro'.tr,
                content: [
                  'privacy_section_2_identity'.tr,
                  'privacy_section_2_contact'.tr,
                  'privacy_section_2_financial'.tr,
                  'privacy_section_2_geolocation'.tr,
                  'privacy_section_2_usage'.tr,
                ],
              ),
              
              // Section III - Use of Information
              _buildSection(
                title: 'privacy_section_3_title'.tr,
                intro: 'privacy_section_3_intro'.tr,
                content: [
                  'privacy_section_3_cycle'.tr,
                  'privacy_section_3_kyc'.tr,
                  'privacy_section_3_communication'.tr,
                ],
              ),
              
              // Section IV - Group Transparency
              _buildSection(
                title: 'privacy_section_4_title'.tr,
                intro: 'privacy_section_4_intro'.tr,
                content: [
                  'privacy_section_4_confidentiality'.tr,
                  'privacy_section_4_limited'.tr,
                ],
              ),
              
              // Section V - Data Sharing
              _buildSection(
                title: 'privacy_section_5_title'.tr,
                intro: 'privacy_section_5_intro'.tr,
                content: [
                  'privacy_section_5_regulatory'.tr,
                  'privacy_section_5_legal'.tr,
                ],
              ),
              
              // Section VI - Data Security
              _buildSection(
                title: 'privacy_section_6_title'.tr,
                content: [
                  'privacy_section_6_storage'.tr,
                  'privacy_section_6_encryption'.tr,
                  'privacy_section_6_retention'.tr,
                ],
              ),
              
              // Section VII - Your Rights
              _buildSection(
                title: 'privacy_section_7_title'.tr,
                intro: 'privacy_section_7_intro'.tr,
                content: [
                  'privacy_section_7_access'.tr,
                  'privacy_section_7_correction'.tr,
                  'privacy_section_7_deletion'.tr,
                  'privacy_section_7_optout'.tr,
                ],
              ),
              
              // Section VIII - Changes
              _buildSection(
                title: 'privacy_section_8_title'.tr,
                content: ['privacy_section_8_content'.tr],
              ),
              
              // Section IX - Contact
              _buildSection(
                title: 'privacy_section_9_title'.tr,
                intro: 'privacy_section_9_content'.tr,
                content: [
                  'privacy_contact_office'.tr,
                  'privacy_contact_phone'.tr,
                  'privacy_contact_email'.tr,
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? intro,
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
          if (intro != null) ...[
            const SizedBox(height: 8),
            Text(
              intro,
              style: GoogleFonts.lato(
                fontSize: 15,
                height: 1.6,
                color: const Color(0xFF494949),
              ),
            ),
          ],
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
