// Purpose: Authentication controller for login and registration
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../widgets/country_code_picker.dart';

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

  // Register user
  Future<void> register() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.register(
        phone: phone.value,
        fullName: fullName.value.isEmpty ? null : fullName.value,
        password: password.value.isEmpty ? null : password.value,
        workStatus: workStatus.value.isEmpty ? null : workStatus.value,
      );

      if (response.success) {
        isOtpSent.value = true;
        Get.snackbar(
          'success'.tr,
          response.message ?? 'otp_sent'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage.value = response.error?.message ?? 'registration_failed'.tr;
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

  // Verify OTP
  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.verifyOtp(
        phone: phone.value,
        otp: otp.value,
      );

      if (response.success) {
        Get.snackbar(
          'success'.tr,
          response.message ?? 'login_successful'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/home');
      } else {
        errorMessage.value = response.error?.message ?? 'invalid_otp'.tr;
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

  // Login
  Future<void> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.login(
        phone: phone.value,
        password: password.value.isEmpty ? null : password.value,
        otp: otp.value.isEmpty ? null : otp.value,
      );

      if (response.success) {
        Get.snackbar(
          'success'.tr,
          response.message ?? 'login_successful'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/home');
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

