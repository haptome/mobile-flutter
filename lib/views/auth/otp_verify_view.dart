// Purpose: OTP verification view matching design
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/primary_button.dart';

class OtpVerifyView extends StatefulWidget {
  const OtpVerifyView({super.key});

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  final AuthController controller = Get.find<AuthController>();

  String _maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final visibleStart = phone.substring(0, 5);
    final visibleEnd = phone.substring(phone.length - 2);
    final masked = '*' * (phone.length - 7);
    return '$visibleStart$masked$visibleEnd';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'enter_otp'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Obx(
                    () => Text(
                      'otp_sent_to'.tr.replaceAll(
                            '{phone}',
                            _maskPhoneNumber(controller.phone.value),
                          ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // OTP input fields
                  OtpInputField(
                    initialValue: controller.otp.value,
                    onChanged: (value) {
                      controller.otp.value = value;
                    },
                    onCompleted: (value) {
                      controller.otp.value = value;
                      // Auto-navigate when OTP is complete (UI only)
                      if (value.length == 6) {
                        Get.offAllNamed('/home');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Request again link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'didnt_receive_code'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLightGray,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => controller.resendOtp(),
                        child: Text(
                          'request_again'.tr,
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
                  const SizedBox(height: 32),
                  // Continue button - Navigate to home (UI only, no API)
                  Center(
                    child: Obx(
                      () {
                        final otpLength = controller.otp.value.length;
                        return PrimaryButton(
                          text: 'continue'.tr,
                          isLoading: false,
                          onPressed: otpLength == 6
                              ? () {
                                  // Navigate to home page (UI only)
                                  Get.offAllNamed('/home');
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
