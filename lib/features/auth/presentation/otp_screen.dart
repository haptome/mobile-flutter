import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_otp_kit/flutter_otp_kit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/device_info.dart';
import '../../../../models/verify_otp_request.dart';
import '../../../../models/login_request.dart';
import '../../../../models/api_response.dart';
import '../../../../core/routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isFromLogin; // Flag to indicate if OTP screen is from login flow

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.isFromLogin = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otpCode = '';

  // Resend OTP state
  final AuthService _authService = AuthService.to;
  Timer? _resendTimer;
  final RxInt _resendCountdown = 60.obs;
  final RxBool _canResend = false.obs;

  @override
  void initState() {
    super.initState();

    // Start countdown timer
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend.value = false;
    _resendCountdown.value = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown.value > 0) {
        _resendCountdown.value--;
      } else {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _resendCountdown.close();
    _canResend.close();
    super.dispose();
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    // Format: +251925******85
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) return phone;
    final start = cleaned.substring(0, 5);
    final end = cleaned.substring(cleaned.length - 2);
    return '+$start******$end';
  }

  // _checkCompletion is no longer needed as we're using flutter_otp_kit
  // The OTP code is directly captured in the _otpCode variable

  Future<void> _handleContinue() async {
    final otp = _otpCode;
    if (otp.isEmpty || otp.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('enter_complete_otp'.tr),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
      return;
    }

    try {
      ApiResponse<Map<String, dynamic>> response;

      // Get FCM token (only on mobile platforms)
      String? fcmToken;
      if (!kIsWeb && DeviceInfo.isMobile()) {
        try {
          final fcmService = FcmService.to;
          fcmToken = fcmService.fcmToken.isNotEmpty ? fcmService.fcmToken : null;
        } catch (e) {
          debugPrint('FCM service not available: $e');
        }
      }

      if (widget.isFromLogin) {
        // If from login screen, use login endpoint with OTP
        final loginRequest = LoginRequest(
          phone: widget.phoneNumber,
          password: null,
          otp: otp,
          fcmToken: fcmToken,
          deviceId: DeviceInfo.getDeviceId(),
          deviceType: DeviceInfo.getDeviceType(),
        );

        // Call login API with OTP
        response = await _authService.login(loginRequest);
      } else {
        // If from signup/registration, use verify-otp endpoint
        final verifyRequest = VerifyOtpRequest(
          phone: widget.phoneNumber,
          otp: otp,
          fcmToken: fcmToken,
          deviceId: DeviceInfo.getDeviceId(),
          deviceType: DeviceInfo.getDeviceType(),
        );

        // Call verify OTP API
        response = await _authService.verifyOtp(verifyRequest);
      }

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isFromLogin
                    ? 'login_successful'.tr
                    : 'otp_verified_successfully'.tr,
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          // Navigate to home screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.error?.message ??
                    (widget.isFromLogin
                        ? 'login_failed'.tr
                        : 'otp_verification_failed'.tr),
              ),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr}: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    }
  }

  Future<void> _handleRequestAgain() async {
    if (!_canResend.value) return;

    try {
      // Call resend OTP API
      final response = await _authService.resendOtp(widget.phoneNumber);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('otp_resent_successfully'.tr),
              backgroundColor: AppColors.primary,
            ),
          );

          // Restart countdown timer
          _startResendTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'failed_resend_otp'.tr),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr}: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.lightTextPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    SizedBox(height: screenHeight * 0.029),

                    // Title
                    Text(
                      'enter_otp'.tr,
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackground,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),

                    // Subtitle
                    Text(
                      '${'otp_sent_to'.tr}${_maskPhoneNumber(widget.phoneNumber)}',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                        isDark: false,
                      ).copyWith(fontSize: 16.6),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // OTP input field with SMS auto-fill
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: AppSizes.spacingMedium,
                      ),
                      child: OtpKit(
                        fieldCount: 6,
                        fieldConfig: OtpFieldConfig(
                          fieldWidth: 40,
                          fieldHeight: 60,
                          borderRadius: AppSizes.otpFieldRadius,
                          borderWidth: AppSizes.textFieldBorderWidth,
                          primaryColor: AppColors.primary,
                          secondaryColor: AppColors.textFieldBorder,
                          backgroundColor: AppColors.white,
                          fieldFontSize: 20,
                          fieldFontWeight: FontWeight.w600,
                        ),
                        smsConfig: OtpSmsConfig(
                          // Enable SMS auto-fill for Android
                          enableSmsAutofill: true,
                          enableSmartAuth: true,
                          enableSmsRetrieverAPI: true, // Android SMS Retriever API
                          enableSmsUserConsentAPI: true, // Android SMS User Consent API
                          // App signature for SMS verification (optional)
                          appSignature: null, // Will use package name by default
                        ),
                        primaryColor: AppColors.primary,
                        successColor: AppColors.primary,
                        autoFocus: true,
                        buttonText: 'continue'.tr,
                        buttonBorderRadius: AppSizes.buttonRadius,
                        buttonPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingLarge,
                          vertical: AppSizes.paddingMedium,
                        ),
                        buttonWidth: screenHeight * 0.3,
                        onVerify: (String otp) async {
                          _otpCode = otp;
                          // Auto-continue when OTP is complete
                          if (otp.length == 6) {
                            await _handleContinue();
                          }
                          return true; // Return true to indicate success
                        },
                        onResend: () {
                          _handleRequestAgain();
                        },
                        animationConfig: const OtpAnimationConfig(
                          enableAnimation: true,
                        ),
                      ),
                    ),

                    // const SizedBox(height: AppSizes.spacingLarge),

                    // // Request again link with countdown
                    // Center(
                    //   child: Obx(
                    //     () => RichText(
                    //       textAlign: TextAlign.center,
                    //       text: TextSpan(
                    //         style: AppTextStyles.bodyMedium(
                    //           color: AppColors.lightTextSecondary,
                    //           isDark: false,
                    //         ),
                    //         children: [
                    //           const TextSpan(text: 'Didn\'t receive a code? '),
                    //           if (_canResend.value)
                    //             WidgetSpan(
                    //               child: GestureDetector(
                    //                 onTap: _handleRequestAgain,
                    //                 child: Text(
                    //                   'Request again',
                    //                   style:
                    //                       AppTextStyles.bodyMedium(
                    //                         color: AppColors.splashBackground,
                    //                         isDark: false,
                    //                       ).copyWith(
                    //                         decoration:
                    //                             TextDecoration.underline,
                    //                         decorationColor:
                    //                             AppColors.splashBackground,
                    //                       ),
                    //                 ),
                    //               ),
                    //             )
                    //           else
                    //             TextSpan(
                    //               text:
                    //                   'Request again in ${_resendCountdown.value}s',
                    //               style: AppTextStyles.bodyMedium(
                    //                 color: AppColors.lightTextSecondary,
                    //                 isDark: false,
                    //               ),
                    //             ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // SizedBox(height: screenHeight * 0.04),

                    // // Continue button
                    // Center(
                    //   child: AppButton(
                    //     text: 'Continue',
                    //     onPressed: _handleContinue,
                    //     isLoading: _isLoading,
                    //     isFullWidth: false,
                    //     horizontalPadding: 62.2,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
