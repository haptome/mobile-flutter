// Purpose: Controller for Privacy Policy page

import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/controllers/terms_conditions_controller.dart';
import 'package:get/get.dart';

class PrivacyPolicyController extends GetxController {
  final ApiService _apiService = ApiService.to;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString pageTitle = ''.obs;
  final RxString introduction = ''.obs;
  final RxString effectiveDate = ''.obs;
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
          .get('/webapp/sections/privacy.content');
      final meta = response.data['metadata'] as Map<String, dynamic>? ?? {};
      pageTitle.value = meta['title'] as String? ?? 'privacy_policy'.tr;
      introduction.value = meta['introduction'] as String? ?? '';
      effectiveDate.value = meta['effectiveDate'] as String? ?? '';
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
}
