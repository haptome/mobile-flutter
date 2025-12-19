import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/services/auth_service.dart';
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
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _otpValues = [];
  bool _isLoading = false;
  
  // Resend OTP state
  final AuthService _authService = AuthService.to;
  Timer? _resendTimer;
  final RxInt _resendCountdown = 60.obs;
  final RxBool _canResend = false.obs;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _otpValues.add('');
    }
    // Focus first field
    _focusNodes[0].requestFocus();
    
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    // Format: +251925******85
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) return phone;
    final start = cleaned.substring(0, 5);
    final end = cleaned.substring(cleaned.length - 2);
    return '+251$start******$end';
  }

  void _checkCompletion() {
    final otp = _otpValues.join('');
    if (otp.length == 6) {
      // OTP completed
    }
  }

  Future<void> _handleContinue() async {
    final otp = _otpValues.join('');
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse<Map<String, dynamic>> response;

      if (widget.isFromLogin) {
        // If from login screen, use login endpoint with OTP
        final loginRequest = LoginRequest(
          phone: widget.phoneNumber,
          password: null,
          otp: otp,
          fcmToken: null, // TODO: Add FCM token when Firebase is set up
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
          fcmToken: null, // TODO: Add FCM token when Firebase is set up
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
              content: Text(widget.isFromLogin 
                ? 'Login successful!' 
                : 'OTP verified successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          // Navigate to home screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 
                (widget.isFromLogin ? 'Login failed' : 'OTP verification failed')),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRequestAgain() async {
    if (!_canResend.value) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Call resend OTP API
      final response = await _authService.resendOtp(widget.phoneNumber);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        
        // Restart countdown timer
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to resend OTP'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.lightError,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with gradient overlay
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.authBackground,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.lightBackground);
                  },
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0024, 0.2921, 0.5801, 0.8322],
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.85),
                        Colors.white.withOpacity(0.9),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
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
                      'Enter OTP',
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
                      'We\'ve sent 6 digit code to ${_maskPhoneNumber(widget.phoneNumber)}',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                        isDark: false,
                      ).copyWith(
                      fontSize: 16.6
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // OTP input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        6,
                        (index) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: (MediaQuery.of(context).size.width -
                                        AppSizes.paddingLarge * 2 -
                                        10.79 * 5) /
                                    6,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: AppTextStyles.h3(
                                    color: AppColors.lightTextPrimary,
                                    isDark: false,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: AppSizes.paddingMedium,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.otpFieldRadius),
                                      borderSide: const BorderSide(
                                        color: AppColors.textFieldBorder,
                                        width: AppSizes.textFieldBorderWidth,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.otpFieldRadius),
                                      borderSide: const BorderSide(
                                        color: AppColors.textFieldBorder,
                                        width: AppSizes.textFieldBorderWidth,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.otpFieldRadius),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    counterText: '',
                                    constraints: const BoxConstraints(
                                      minHeight: AppSizes.textFieldHeight,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _otpValues[index] = value;
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    _checkCompletion();
                                  },
                                ),
                              ),
                              if (index < 5) const SizedBox(width: 10.79),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacingLarge),

                    // Request again link with countdown
                    Center(
                      child: Obx(
                        () => RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.lightTextSecondary,
                              isDark: false,
                            ),
                            children: [
                              const TextSpan(text: 'Didn\'t receive a code? '),
                              if (_canResend.value)
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _handleRequestAgain,
                                    child: Text(
                                      'Request again',
                                      style: AppTextStyles.bodyMedium(
                                        color: AppColors.splashBackground,
                                        isDark: false,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.splashBackground,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TextSpan(
                                  text: 'Request again in ${_resendCountdown.value}s',
                                  style: AppTextStyles.bodyMedium(
                                    color: AppColors.lightTextSecondary,
                                    isDark: false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Continue button
                    Center(
                      child: AppButton(
                        text: 'Continue',
                        onPressed: _handleContinue,
                        isLoading: _isLoading,
                        isFullWidth: false,
                        horizontalPadding: 62.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }
}

