// Purpose: Authentication service for login, register, and OTP
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'dart:io';
import 'package:et_digital_equb/models/api_response.dart';
import 'package:et_digital_equb/models/user_model.dart';
import 'package:et_digital_equb/models/register_request.dart';
import 'package:et_digital_equb/models/verify_otp_request.dart';
import 'package:et_digital_equb/models/login_request.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Options;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final ApiService _apiService = ApiService.to;
  final StorageService _storage = StorageService.to;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  // Initialize and load user data from storage
  Future<void> init() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      // Load user data from storage
      final user = await _storage.getUser();
      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        // Optionally verify token is still valid by fetching profile
        // This will refresh user data and validate the token
        try {
          await getProfile();
        } catch (e) {
          // If token is invalid, clear auth state
          if (kDebugMode) {
            print('Token validation failed: $e');
          }
          await clearAuthState();
        }
      } else {
        // Token exists but no user data, clear tokens
        await clearAuthState();
      }
    }
  }

  // Clear authentication state
  Future<void> clearAuthState() async {
    await _storage.clearTokens();
    await _storage.clearUser();
    currentUser.value = null;
    isAuthenticated.value = false;
  }

  // Register user with complete registration data
  // Note: Registration only creates the user and sends OTP
  // Tokens are returned after OTP verification via verifyOtp()
  Future<ApiResponse<Map<String, dynamic>>> register(
    RegisterRequest request,
  ) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/register',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      // Registration only returns userId and otp_sent status
      // Do NOT save tokens here - they come after OTP verification
      // The response should contain: { userId: string, otp_sent: boolean }

      return apiResponse;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Register user with phone (legacy method for backward compatibility)
  Future<ApiResponse<Map<String, dynamic>>> registerWithPhone({
    required String phone,
    String? fullName,
    String? password,
    String? workStatus,
    String? fcmToken,
    String? deviceId,
    String? deviceType,
  }) async {
    return register(
      RegisterRequest(
        phone: phone,
        fullName: fullName,
        password: password, // Optional for mobile
        workStatus: workStatus,
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
  }

  // Verify OTP with complete request data
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
    VerifyOtpRequest request,
  ) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Save tokens
        if (apiResponse.data!.containsKey('access_token')) {
          await _storage.saveAccessToken(
            apiResponse.data!['access_token'] as String,
          );
        }
        if (apiResponse.data!.containsKey('refresh_token')) {
          await _storage.saveRefreshToken(
            apiResponse.data!['refresh_token'] as String,
          );
        }

        // Save user
        if (apiResponse.data!.containsKey('user')) {
          final user = UserModel.fromJson(
            apiResponse.data!['user'] as Map<String, dynamic>,
          );
          currentUser.value = user;
          isAuthenticated.value = true;
          // Persist user data to storage
          await _storage.saveUser(user);
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP with phone and OTP (legacy method for backward compatibility)
  Future<ApiResponse<Map<String, dynamic>>> verifyOtpWithPhone({
    required String phone,
    required String otp,
    String? fcmToken,
    String? deviceId,
    String? deviceType,
  }) async {
    return verifyOtp(
      VerifyOtpRequest(
        phone: phone,
        otp: otp,
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
  }

  // Login with complete request data
  Future<ApiResponse<Map<String, dynamic>>> login(LoginRequest request) async {
    try {
      final response = await _apiService.authDio.post(
        '/auth/login',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Save tokens if returned
        if (apiResponse.data!.containsKey('access_token')) {
          await _storage.saveAccessToken(
            apiResponse.data!['access_token'] as String,
          );
        }
        if (apiResponse.data!.containsKey('refresh_token')) {
          await _storage.saveRefreshToken(
            apiResponse.data!['refresh_token'] as String,
          );
        }

        // Save user if returned
        if (apiResponse.data!.containsKey('user')) {
          final user = UserModel.fromJson(
            apiResponse.data!['user'] as Map<String, dynamic>,
          );
          currentUser.value = user;
          isAuthenticated.value = true;
          // Persist user data to storage
          await _storage.saveUser(user);
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Login with phone and password/OTP (legacy method for backward compatibility)
  Future<ApiResponse<Map<String, dynamic>>> loginWithPhone({
    required String phone,
    String? password,
    String? otp,
    String? fcmToken,
    String? deviceId,
    String? deviceType,
  }) async {
    return login(
      LoginRequest(
        phone: phone,
        password: password,
        otp: otp,
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
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
        // Persist user data to storage
        await _storage.saveUser(apiResponse.data!);
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<ApiResponse<Map<String, dynamic>>> uploadProfileImage(
    File imageFile,
  ) async {
    try {
      // Prepare form data for image upload
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiService.authDio.post(
        '/auth/upload-profile-image',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      return apiResponse;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<ApiResponse<Map<String, dynamic>>> resendOtp(String phone) async {
    try {
      final response = await _apiService.authDio.post(
        '/otp/resend',
        data: {'phone': phone},
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call backend logout endpoint if user is authenticated
      final token = await _storage.getAccessToken();
      if (token != null) {
        try {
          await _apiService.authDio.post('/auth/logout');
        } catch (e) {
          // Log error but continue with local logout
          // This ensures logout works even if backend is unavailable
          if (kDebugMode) {
            print('Logout API call failed: $e');
          }
        }
      }
    } catch (e) {
      // Continue with local logout even if there's an error
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      // Always clear local storage and reset state
      await _storage.clearTokens();
      await _storage.clearUser();
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed('/login');
    }
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      // First, try to load user from storage
      final storedUser = await _storage.getUser();
      if (storedUser != null) {
        currentUser.value = storedUser;
        isAuthenticated.value = true;
      }

      // Then verify with API
      try {
        await getProfile();
        return true;
      } catch (e) {
        // If API call fails, still use stored user if available
        if (storedUser != null) {
          return true;
        }
        await logout();
        return false;
      }
    }
    return false;
  }

  // Check if user has password set
  Future<ApiResponse<bool>> hasPassword() async {
    try {
      final response = await _apiService.authDio.get('/auth/profile');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => _extractHasPassword(data as Map<String, dynamic>),
      );

      // Update local user data if successful
      if (apiResponse.success && apiResponse.data != null) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        currentUser.value = user;
        isAuthenticated.value = true;
        // Persist user data to storage
        await _storage.saveUser(user);
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to extract password status from profile response
  bool _extractHasPassword(Map<String, dynamic> profileData) {
    // Check if the profile response contains a field indicating password status
    // Backend now returns 'has_password' field in the profile response
    if (profileData.containsKey('has_password')) {
      return profileData['has_password'] as bool;
    } else if (profileData.containsKey('hasPassword')) {
      return profileData['hasPassword'] as bool;
    }

    // Default assumption: if we can retrieve the profile, password may be set
    return false; // Default to false if field is not present
  }

  // Update user profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? fullName,
    String? email,
    String? workStatus,
    String? location,
    String? profilePicUrl,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (fullName != null) requestData['full_name'] = fullName;
      if (email != null) requestData['email'] = email;
      if (workStatus != null) requestData['work_status'] = workStatus;
      if (location != null) requestData['location'] = location;
      if (profilePicUrl != null) requestData['profile_pic_url'] = profilePicUrl;

      final response = await _apiService.authDio.put(
        '/auth/profile',
        data: requestData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      // Update local user data if successful
      if (apiResponse.success && apiResponse.data != null) {
        currentUser.value = apiResponse.data;
        isAuthenticated.value = true;
        // Persist user data to storage
        await _storage.saveUser(apiResponse.data!);
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }
}
