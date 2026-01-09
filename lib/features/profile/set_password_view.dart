import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/app_assets.dart';
import '../../controllers/set_password_controller.dart';
import '../../../core/services/auth_service.dart';

class SetPasswordView extends StatefulWidget {
  final bool hasExistingPassword;

  const SetPasswordView({
    super.key,
    this.hasExistingPassword =
        false, // Default to false for first-time password set
  });

  @override
  State<SetPasswordView> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  late final SetPasswordController _controller;
  bool _hasExistingPassword = false; // Track if user already has a password

  @override
  void initState() {
    super.initState();
    // Initialize SetPasswordController if not already registered
    if (!Get.isRegistered<SetPasswordController>()) {
      _controller = Get.put(SetPasswordController());
    } else {
      _controller = Get.find<SetPasswordController>();
    }

    // Check if user has an existing password by looking at their profile
    // For now, we'll check if they have previously set a password
    // In a real implementation, this would involve calling an API to check password status
    _checkIfUserHasPassword();

    // After initializing with the widget parameter, check the actual status from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActualPasswordStatus();
    });
  }

  void _checkIfUserHasPassword() {
    // Initially use the passed parameter to determine if user has existing password
    // Later we will check the actual status via API
    _hasExistingPassword = widget.hasExistingPassword;
  }

  void _checkActualPasswordStatus() async {
    // Check the actual password status via API to get the most up-to-date info
    try {
      final authService = AuthService.to;
      // First try to get fresh profile data which will include has_password field
      await authService.getProfile();

      // Now check the updated user model
      final currentUser = authService.currentUser.value;
      final actualHasPassword =
          currentUser?.hasPassword ?? widget.hasExistingPassword;

      if (mounted) {
        setState(() {
          _hasExistingPassword = actualHasPassword;
        });
      }
    } catch (e) {
      // If API call fails, use the initial value passed as parameter
      // This maintains the original behavior as a fallback
      if (mounted) {
        setState(() {
          _hasExistingPassword = widget.hasExistingPassword;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    );
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number and special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateCurrentPassword(String? value) {
    if (_hasExistingPassword) {
      if (value == null || value.isEmpty) {
        return 'Please enter your current password';
      }
      if (value.length < 6) {
        // Adjust based on your password requirements
        return 'Current password is required';
      }
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? currentPassword;
        if (_hasExistingPassword) {
          currentPassword = _currentPasswordController.text;
        }

        final response = await _controller.changePassword(
          currentPassword: currentPassword ?? '',
          newPassword: _newPasswordController.text,
          confirmNewPassword: _confirmPasswordController.text,
        );

        if (response.success) {
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.message ?? 'Password updated successfully!',
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Clear the controllers
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          // Navigate back to the previous screen after a brief delay to allow the snackbar to show
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            Get.back();
          }
        } else {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.error?.message ?? 'Failed to update password',
                ),
                backgroundColor: AppColors.lightError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.lightError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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

                    SizedBox(height: screenHeight * 0.029),

                    // Title
                    Text(
                      'Set Password',
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
                      'Create a strong password for your account',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                        isDark: false,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Current Password Field (only shown if user has existing password)
                    AnimatedCrossFade(
                      firstChild: Container(height: 0, width: 0),
                      secondChild: Column(
                        children: [
                          AppTextField(
                            hint: 'Current Password',
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            validator: _hasExistingPassword
                                ? _validateCurrentPassword
                                : null,
                            suffixIcon: _obscureCurrentPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                          const SizedBox(height: AppSizes.spacingMedium),
                        ],
                      ),
                      crossFadeState: _hasExistingPassword
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    // New Password Field
                    AppTextField(
                      hint: 'New Password',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      validator: _validatePassword,
                      suffixIcon: _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconTap: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),

                    // Confirm Password Field
                    AppTextField(
                      hint: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconTap: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),

                    // Change Password button
                    Center(
                      child: AppButton(
                        text: _hasExistingPassword
                            ? 'Change Password'
                            : 'Set Password',
                        onPressed: _handleChangePassword,
                        isFullWidth: false,
                        horizontalPadding: 62.2,
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
