// Purpose: Login view matching design
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/primary_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Title
              Text(
                'welcome_back'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'enter_credential_to_continue'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLightGray,
                ),
              ),
              const SizedBox(height: 40),
              // Phone input field
              Obx(
                () => PhoneInputField(
                  initialValue: controller.phone.value.isEmpty
                      ? null
                      : controller.phone.value,
                  selectedCountry: controller.selectedCountry.value,
                  onCountrySelected: (country) {
                    controller.selectedCountry.value = country;
                  },
                  onChanged: (value) {
                    // Store just the phone number without country code
                    controller.phone.value =
                        value.replaceAll(RegExp(r'[^\d]'), '');
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Login button - Navigate to OTP page (UI only, no API)
              Center(
                child: PrimaryButton(
                  text: 'log_in'.tr,
                  isLoading: false,
                  onPressed: () {
                    // Navigate to OTP verification page
                    Get.toNamed('/otp-verify');
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Sign up link
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont_have_account'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLightGray,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Get.toNamed('/register'),
                      child: Text(
                        'sign_up'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
