import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/models/api_response.dart';

class SetPasswordController extends GetxController {
  final ApiService _apiService = ApiService.to;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (newPassword != confirmNewPassword) {
      throw Exception("New password and confirmation don't match");
    }

    if (newPassword.length < 8) {
      throw Exception("New password must be at least 8 characters");
    }

    _isLoading.value = true;
    try {
      // Prepare request data based on the operation type
      // The backend expects 'password' field for the new password
      // and 'current_password' field if changing existing password
      Map<String, dynamic> requestData;
      if (currentPassword.isNotEmpty) {
        // This is a password change operation
        requestData = {
          'current_password': currentPassword,
          'password': newPassword,
        };
      } else {
        // This is a first-time password set operation
        requestData = {'password': newPassword};
      }

      // Use the password update endpoint that handles both set and change scenarios
      // The backend will determine the appropriate action based on whether current password is provided
      final response = await _apiService.authDio.put(
        '/auth/password', // Using password endpoint for both scenarios
        data: requestData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      return apiResponse;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }
}
