import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../models/login_request.dart';

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

        final loginRequest = LoginRequest(
          phone: fullPhone,
          password: _passwordController.text,
          otp: null, // Not using OTP for password login
          fcmToken: null, // TODO: Add FCM token when Firebase is set up
          deviceId: null, // Will be handled by AuthService
          deviceType: null, // Will be handled by AuthService
        );

        final response = await _authService.login(loginRequest);

        if (mounted) {
          if (response.success) {
            // Login successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful!'),
                backgroundColor: AppColors.primary,
              ),
            );
            // Navigate to home screen
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.error?.message ?? 'Login failed. Please try again.',
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
            Navigator.of(context).pushNamed(
              AppRoutes.otp,
              arguments: {'phoneNumber': fullPhone, 'isFromLogin': true},
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.error?.message ??
                      'Failed to send OTP. Please try again.',
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
            content: Text('Network error: ${e.toString()}'),
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
      return 'Please enter your phone number';
    }
    if (value.length != 9) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
                Positioned.fill(
                  child: Container(
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
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
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
                    // Back button
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.lightTextPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Title
                    Text(
                      'Welcome back',
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
                      'Enter your credential to continue',
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
                        hint: 'Password',
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
                              ? 'Use OTP instead'
                              : 'Login with password',
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
                        text: _usePasswordLogin
                            ? 'Login with Password'
                            : 'Log in',
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
                            const TextSpan(text: 'Don\'t have account? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to signup screen
                                  Navigator.of(context).pushNamed('/signup');
                                },
                                child: Text(
                                  'Sign up',
                                  style:
                                      AppTextStyles.bodyMedium(
                                        color: AppColors.splashBackground,
                                        isDark: false,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.splashBackground,
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
        ],
      ),
    );
  }
}
