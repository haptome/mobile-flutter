// Purpose: Controller for handling invitation acceptance logic
// Author: Generated for ET Digital Equb
// Manages invitation data loading, acceptance, and rejection

import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';

class InvitationController extends GetxController {
  final String? groupId;
  final String? inviteCode;

  InvitationController({this.groupId, this.inviteCode});

  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> groupData = <String, dynamic>{}.obs;

  late final ApiService _apiService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService.to;
    _authService = AuthService.to;
  }

  /// Load invitation details from API
  Future<void> loadInvitationDetails() async {
    if (groupId == null || inviteCode == null) {
      errorMessage.value = 'Invalid invitation data';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.groupDio.get(
        '/groups/$groupId/invite/$inviteCode',
      );

      if (response.data['success'] == true) {
        groupData.value = response.data['data'] ?? {};
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to load invitation';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept the invitation
  Future<void> acceptInvitation() async {
    if (groupId == null || inviteCode == null) {
      Get.snackbar('Error', 'Invalid invitation data');
      return;
    }

    try {
      isProcessing.value = true;

      final response = await _apiService.groupDio.post(
        '/groups/$groupId/invite/$inviteCode/accept',
        data: {'userId': _authService.currentUser.value?.id},
      );

      if (response.data['success'] == true) {
        Get.snackbar(
          'Success',
          'You have successfully joined the group!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to group detail or home
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to accept invitation',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Decline the invitation
  Future<void> declineInvitation() async {
    // Simply navigate back
    Get.back();
  }
}
