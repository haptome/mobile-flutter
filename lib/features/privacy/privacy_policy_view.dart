// Purpose: Privacy Policy page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/privacy_policy_controller.dart';
import '../../controllers/terms_conditions_controller.dart' show LegalSection;

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivacyPolicyController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'privacy_policy'.tr,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.montserrat(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: controller.fetchContent,
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.effectiveDate.value.isNotEmpty)
                  TranslatedText(
                    'Effective Date: ${controller.effectiveDate.value}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textLightGray,
                    ),
                  ),
                if (controller.effectiveDate.value.isNotEmpty)
                  const SizedBox(height: 12),
                if (controller.introduction.value.isNotEmpty)
                  TranslatedText(
                    controller.introduction.value,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      height: 1.6,
                      color: const Color(0xFF494949),
                    ),
                  ),
                const SizedBox(height: 24),
                ...controller.sections.map((s) => _SectionWidget(section: s)),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final LegalSection section;
  const _SectionWidget({required this.section});

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<strong>'), '')
        .replaceAll(RegExp(r'</strong>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            '${section.id}. ${section.title}',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF232729),
            ),
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            TranslatedText(
              section.content,
              style: GoogleFonts.lato(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF494949),
              ),
            ),
          ],
          if (section.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFF494949))),
                    Expanded(
                      child: TranslatedText(
                        _stripHtml(item),
                        style: GoogleFonts.lato(
                          fontSize: 14,
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
        ],
      ),
    );
  }
}
