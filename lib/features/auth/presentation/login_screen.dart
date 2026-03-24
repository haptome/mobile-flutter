import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/device_info.dart';
import '../../../../models/login_request.dart';
import '../../../../controllers/language_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService.to;
  bool _isLoading = false;
  bool _usePasswordLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate based on the current login method
    bool isPhoneValid = _validatePhone(_phoneController.text) == null;
    bool isPasswordValid =
        true; // Only validate password if using password login

    if (_usePasswordLogin) {
      isPasswordValid = _validatePassword(_passwordController.text) == null;
    }

    if (!isPhoneValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_validatePhone(_phoneController.text)!),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
      return;
    }

    if (_usePasswordLogin && !isPasswordValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_validatePassword(_passwordController.text)!),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_usePasswordLogin) {
        // Password-based login
        final fullPhone = '+251${_phoneController.text}';

        // Get FCM token (only on mobile platforms)
        String? fcmToken;
        if (!kIsWeb && DeviceInfo.isMobile()) {
          try {
            final fcmService = FcmService.to;
            fcmToken = fcmService.fcmToken.isNotEmpty ? fcmService.fcmToken : null;
          } catch (e) {
            print('FCM service not available: $e');
          }
        }

        final loginRequest = LoginRequest(
          phone: fullPhone,
          password: _passwordController.text,
          otp: null, // Not using OTP for password login
          fcmToken: fcmToken,
          deviceId: DeviceInfo.getDeviceId(),
          deviceType: DeviceInfo.getDeviceType(),
        );

        final response = await _authService.login(loginRequest);

        if (mounted) {
          if (response.success) {
            // Login successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login_successful'.tr),
                backgroundColor: AppColors.primary,
              ),
            );
            // Navigate to home screen
            Get.offAllNamed(AppRoutes.home);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.error?.message ?? 'login_failed'.tr,
                ),
                backgroundColor: AppColors.lightError,
              ),
            );
          }
        }
      } else {
        // OTP-based login
        // Build full phone number with country code
        final fullPhone = '+251${_phoneController.text}';

        // Request OTP before navigating to OTP screen
        final response = await _authService.resendOtp(fullPhone);

        if (mounted) {
          if (response.success) {
            // Navigate to OTP screen after successful OTP request
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.otp,
              arguments: {'phoneNumber': fullPhone, 'isFromLogin': true},
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.error?.message ??
                      'failed_resend_otp'.tr,
                ),
                backgroundColor: AppColors.lightError,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('network_error'.tr + ': ${e.toString()}'),
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_phone'.tr;
    }
    if (value.length != 9) {
      return 'please_enter_valid_phone'.tr;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_password'.tr;
    }
    if (value.length < 6) {
      return 'password_min_length'.tr;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and Language toggle
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Language toggle button
                    Obx(() {
                      final languageController = Get.find<LanguageController>();
                      return InkWell(
                        onTap: () => languageController.toggleLanguage(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languageController.getCurrentLanguageFlag(),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                languageController.isEnglish() ? 'አማ' : 'EN',
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // Title
                Text(
                  'welcome_back'.tr,
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
                  'enter_credential_continue'.tr,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.lightTextSecondary,
                    isDark: false,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Phone input field
                PhoneInputField(
                  hint: '94 825 228 5',
                  controller: _phoneController,
                  validator: _validatePhone,
                  onChanged: (value) {},
                  onSubmitted: (_) {
                    if (_usePasswordLogin) {
                      // Move focus to password field when using password login
                      FocusScope.of(context).nextFocus();
                    } else {
                      _handleLogin();
                    }
                  },
                  maxLength: 9,
                ),

                SizedBox(height: screenHeight * 0.02),

                // Password field (only shown when using password login)
                AnimatedCrossFade(
                  firstChild: Container(height: 0, width: 0),
                  secondChild: AppTextField(
                    hint: 'password'.tr,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  crossFadeState: _usePasswordLogin
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Toggle login method
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _usePasswordLogin = !_usePasswordLogin;
                        // Clear password field when switching
                        if (!_usePasswordLogin) {
                          _passwordController.clear();
                        }
                      });
                    },
                    child: Text(
                      _usePasswordLogin
                          ? 'use_otp_instead'.tr
                          : 'login_with_password'.tr,
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.splashBackground,
                        isDark: false,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Log in button
                Center(
                  child: AppButton(
                    text: _usePasswordLogin ? 'login_with_password'.tr : 'login'.tr,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    isFullWidth: false,
                    horizontalPadding: 62.2,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Sign up link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                        isDark: false,
                      ),
                      children: [
                        TextSpan(text: 'dont_have_account'.tr),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to signup screen
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: Text(
                              'sign_up'.tr,
                              style:
                                  AppTextStyles.bodyMedium(
                                    color: AppColors.splashBackground,
                                    isDark: false,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.splashBackground,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
