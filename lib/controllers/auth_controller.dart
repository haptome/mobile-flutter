// Purpose: Authentication controller for login and registration
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/storage_service.dart';
import 'package:et_digital_equb/core/widgets/country_code_picker.dart';
import 'package:et_digital_equb/core/utils/device_info.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/models/register_request.dart';
import 'package:et_digital_equb/models/verify_otp_request.dart';
import 'package:et_digital_equb/models/login_request.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.to;

  // Form state
  final RxString phone = ''.obs;
  final RxString password = ''.obs;
  final RxString otp = ''.obs;
  final RxString fullName = ''.obs;
  final RxString workStatus = ''.obs;

  // Country code
  final Rx<CountryCode> selectedCountry = const CountryCode(
    name: 'Ethiopia',
    code: 'ET',
    dialCode: '+251',
    flag: '🇪🇹',
  ).obs;

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxString errorMessage = ''.obs;

  // Register user with complete registration data
  // Flow: Register → OTP sent automatically → Navigate to OTP verification
  Future<void> register({String? fcmToken, String? deviceId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Build full phone number with country code
      final fullPhone = '${selectedCountry.value.dialCode}${phone.value}';

      // Create registration request (password is optional for mobile - OTP only)
      final registerRequest = RegisterRequest(
        phone: fullPhone,
        fullName: fullName.value.isEmpty ? null : fullName.value,
        password: null, // Mobile users don't use passwords - OTP only
        workStatus: workStatus.value.isEmpty ? null : workStatus.value,
        fcmToken: fcmToken,
        deviceId: deviceId ?? DeviceInfo.getDeviceId(),
        deviceType: DeviceInfo.getDeviceType(),
      );

      final response = await _authService.register(registerRequest);

      if (response.success && response.data != null) {
        // Registration successful - check if OTP was sent
        final otpSent = response.data!['otp_sent'] == true;

        if (otpSent) {
          isOtpSent.value = true;
          // Navigate to OTP screen, removing signup from the back stack
          Get.offNamed(
            AppRoutes.otp,
            arguments: {
              'phoneNumber': fullPhone,
              'isFromLogin': false,
            },
          );
        } else {
          isOtpSent.value = false;
          Get.snackbar(
            'Warning',
            'Account registered but OTP not sent. You can request OTP again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offNamed(
            AppRoutes.otp,
            arguments: {
              'phoneNumber': fullPhone,
              'isFromLogin': false,
            },
          );
        }
      } else {
        errorMessage.value = response.error?.message ?? 'Registration failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<void> verifyOtp({String? fcmToken}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Build full phone number with country code if not already included
      String fullPhone = phone.value;
      if (!fullPhone.startsWith('+')) {
        fullPhone = '${selectedCountry.value.dialCode}${phone.value}';
      }

      final verifyRequest = VerifyOtpRequest(
        phone: fullPhone,
        otp: otp.value,
        fcmToken: fcmToken,
        deviceId: DeviceInfo.getDeviceId(),
        deviceType: DeviceInfo.getDeviceType(),
      );

      final response = await _authService.verifyOtp(verifyRequest);

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'OTP verified successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await _navigateAfterAuth();
      } else {
        errorMessage.value = response.error?.message ?? 'Invalid OTP';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Request OTP for login
  // Flow: User enters phone → Request OTP → Navigate to OTP screen
  Future<void> requestOtpForLogin() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Build full phone number with country code
      String fullPhone = phone.value;
      if (!fullPhone.startsWith('+')) {
        fullPhone = '${selectedCountry.value.dialCode}${phone.value}';
      }

      // Request OTP for login
      final response = await _authService.resendOtp(fullPhone);

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'OTP sent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to OTP verification screen for login
        Get.toNamed(
          AppRoutes.otp,
          arguments: {
            'phoneNumber': fullPhone,
            'isFromLogin': true, // This is for login
          },
        );
      } else {
        errorMessage.value = response.error?.message ?? 'Failed to send OTP';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Login with OTP (after OTP is entered)
  // Flow: User enters OTP → Login with phone + OTP → Logged in
  Future<void> loginWithOtp({
    required String phoneNumber,
    required String otpCode,
    String? fcmToken,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final loginRequest = LoginRequest(
        phone: phoneNumber,
        password: null, // Mobile users use OTP only
        otp: otpCode,
        fcmToken: fcmToken,
        deviceId: DeviceInfo.getDeviceId(),
        deviceType: DeviceInfo.getDeviceType(),
      );

      final response = await _authService.login(loginRequest);

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'Login successful',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to home screen (or pending invitation if one exists)
        await _navigateAfterAuth();
      } else {
        errorMessage.value = response.error?.message ?? 'Login failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP (used during OTP verification screen)
  Future<void> resendOtp({String? phoneNumber}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Use provided phone or current phone value
      String fullPhone = phoneNumber ?? phone.value;
      if (!fullPhone.startsWith('+')) {
        fullPhone = '${selectedCountry.value.dialCode}${fullPhone}';
      }

      final response = await _authService.resendOtp(fullPhone);

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'OTP resent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage.value = response.error?.message ?? 'Failed to resend OTP';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    phone.value = '';
    password.value = '';
    otp.value = '';
    fullName.value = '';
    workStatus.value = '';
    errorMessage.value = '';
    isOtpSent.value = false;
  }

  /// Navigate after successful auth — checks for a pending invitation deep link first
  Future<void> _navigateAfterAuth() async {
    final storage = StorageService.to;
    final pendingGroupId = storage.getString('pending_invitation_group_id');

    if (pendingGroupId != null && pendingGroupId.isNotEmpty) {
      // Clear the stored pending invitation
      await storage.saveString('pending_invitation_group_id', '');

      // Navigate to home first, then push invite screen on top
      Get.offAllNamed('/home');
      Get.toNamed(
        AppRoutes.groupInvite,
        arguments: {'groupId': pendingGroupId},
      );
    } else {
      Get.offAllNamed('/home');
    }
  }
}
