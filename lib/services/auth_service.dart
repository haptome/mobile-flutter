// Purpose: Authentication service for login, register, and OTP
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final ApiService _apiService = ApiService.to;
  final StorageService _storage = StorageService.to;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  // Register user with phone
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String phone,
    String? fullName,
    String? password,
    String? workStatus,
  }) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/register',
        data: {
          'phone': phone,
          if (fullName != null) 'full_name': fullName,
          if (password != null) 'password': password,
          if (workStatus != null) 'work_status': workStatus,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Save tokens
        await _storage.saveAccessToken(
          apiResponse.data!['access_token'] as String,
        );
        await _storage.saveRefreshToken(
          apiResponse.data!['refresh_token'] as String,
        );

        // Save user
        if (apiResponse.data!['user'] != null) {
          final user = UserModel.fromJson(
            apiResponse.data!['user'] as Map<String, dynamic>,
          );
          currentUser.value = user;
          isAuthenticated.value = true;
        }
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Login with phone and password/OTP
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String phone,
    String? password,
    String? otp,
  }) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/login',
        data: {
          'phone': phone,
          if (password != null) 'password': password,
          if (otp != null) 'otp': otp,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Save tokens
        await _storage.saveAccessToken(
          apiResponse.data!['access_token'] as String,
        );
        await _storage.saveRefreshToken(
          apiResponse.data!['refresh_token'] as String,
        );

        // Save user
        if (apiResponse.data!['user'] != null) {
          final user = UserModel.fromJson(
            apiResponse.data!['user'] as Map<String, dynamic>,
          );
          currentUser.value = user;
          isAuthenticated.value = true;
        }
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _apiService.authDio.get('/auth/profile');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        currentUser.value = apiResponse.data;
        isAuthenticated.value = true;
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<ApiResponse<void>> resendOtp(String phone) async {
    try {
      final response = await _apiService.authDio.post(
        '/otp/resend',
        data: {'phone': phone},
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearTokens();
    currentUser.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed('/login');
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      try {
        await getProfile();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }
}

