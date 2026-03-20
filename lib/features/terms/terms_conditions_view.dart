// Purpose: Terms & Conditions page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/app_button.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
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
        title: Text(
          'terms_conditions'.tr,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorView(onRetry: controller.fetchContent);
                }
                return _LegalContentView(
                  introduction: controller.introduction.value,
                  consent: controller.consent.value,
                  effectiveDate: controller.effectiveDate.value,
                  sections: controller.sections,
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Obx(
                () => AppButton(
                  text: 'agree_continue'.tr,
                  onPressed: controller.onAgreeContinue,
                  isLoading: controller.isAgreeing.value,
                  isFullWidth: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalContentView extends StatelessWidget {
  final String introduction;
  final String consent;
  final String effectiveDate;
  final List<LegalSection> sections;

  const _LegalContentView({
    required this.introduction,
    required this.consent,
    required this.effectiveDate,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (effectiveDate.isNotEmpty)
            Text(
              'Effective Date: $effectiveDate',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textLightGray,
              ),
            ),
          if (effectiveDate.isNotEmpty) const SizedBox(height: 12),
          if (introduction.isNotEmpty)
            Text(
              introduction,
              style: GoogleFonts.lato(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF494949),
              ),
            ),
          if (consent.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              consent,
              style: GoogleFonts.lato(
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF494949),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...sections.map((s) => _SectionWidget(section: s)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final LegalSection section;
  const _SectionWidget({required this.section});

  // Strip basic HTML tags for display
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
          Text(
            '${section.id}. ${section.title}',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF232729),
            ),
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
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
                      child: Text(
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

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'failed_to_load_content'.tr,
            style: GoogleFonts.montserrat(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text('retry'.tr)),
        ],
      ),
    );
  }
}
