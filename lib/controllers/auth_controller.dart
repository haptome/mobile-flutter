// Purpose: Authentication controller for login and registration
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/country_code_picker.dart';
import 'package:et_digital_equb/core/utils/device_info.dart';
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
  Future<void> register({
    String? fcmToken,
    String? deviceId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Build full phone number with country code
      final fullPhone = '${selectedCountry.value.dialCode}${phone.value}';

      // Create registration request
      final registerRequest = RegisterRequest(
        phone: fullPhone,
        fullName: fullName.value,
        password: password.value,
        workStatus: workStatus.value.isEmpty ? 'employed' : workStatus.value,
        fcmToken: fcmToken,
        deviceId: deviceId ?? DeviceInfo.getDeviceId(),
        deviceType: DeviceInfo.getDeviceType(),
      );

      final response = await _authService.register(registerRequest);

      if (response.success) {
        isOtpSent.value = true;
        Get.snackbar(
          'Success',
          response.message ?? 'OTP sent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
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
        Get.offAllNamed('/home');
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

  // Login
  Future<void> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Build full phone number with country code
      String fullPhone = phone.value;
      if (!fullPhone.startsWith('+')) {
        fullPhone = '${selectedCountry.value.dialCode}${phone.value}';
      }

      final loginRequest = LoginRequest(
        phone: fullPhone,
        password: password.value.isEmpty ? null : password.value,
        otp: otp.value.isEmpty ? null : otp.value,
        fcmToken: null, // TODO: Add FCM token when Firebase is set up
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
        // Navigate to OTP screen after login
        Get.toNamed('/otp', arguments: {'phoneNumber': fullPhone});
      } else {
        errorMessage.value = response.error?.message ?? 'login_failed'.tr;
        Get.snackbar(
          'error'.tr,
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'error'.tr,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.resendOtp(phone.value);

      if (response.success) {
        Get.snackbar(
          'success'.tr,
          response.message ?? 'otp_resent'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage.value = response.error?.message ?? 'resend_failed'.tr;
        Get.snackbar(
          'error'.tr,
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'error'.tr,
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
}

