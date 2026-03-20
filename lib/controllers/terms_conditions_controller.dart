// Purpose: Controller for Terms & Conditions page

import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:get/get.dart';

class LegalSection {
  final String id;
  final String title;
  final String content;
  final List<String> items;

  LegalSection({
    required this.id,
    required this.title,
    required this.content,
    required this.items,
  });

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class TermsConditionsController extends GetxController {
  final ApiService _apiService = ApiService.to;

  final RxBool isLoading = true.obs;
  final RxBool isAgreeing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString pageTitle = ''.obs;
  final RxString introduction = ''.obs;
  final RxString effectiveDate = ''.obs;
  final RxString consent = ''.obs;
  final RxList<LegalSection> sections = <LegalSection>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  Future<void> fetchContent() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiService.dio
          .get('/webapp/sections/terms.content');
      final meta = response.data['metadata'] as Map<String, dynamic>? ?? {};
      pageTitle.value = meta['title'] as String? ?? 'terms_conditions'.tr;
      introduction.value = meta['introduction'] as String? ?? '';
      effectiveDate.value = meta['effectiveDate'] as String? ?? '';
      consent.value = meta['consent'] as String? ?? '';
      final rawSections = meta['sections'] as List<dynamic>? ?? [];
      sections.value = rawSections
          .map((s) => LegalSection.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = 'failed_to_load_content'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void onAgreeContinue() async {
    isAgreeing.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        'success'.tr,
        'terms_accepted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'acceptance_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAgreeing.value = false;
    }
  }
}
