import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../controllers/set_password_controller.dart';
import '../../../core/services/auth_service.dart';

class SetPasswordBottomSheet {
  static Future<void> show({
    required BuildContext context,
    bool hasExistingPassword = false,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.64)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return _SetPasswordBottomSheetContent(
              hasExistingPassword: hasExistingPassword,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}

class _SetPasswordBottomSheetContent extends StatefulWidget {
  final bool hasExistingPassword;
  final ScrollController scrollController;

  const _SetPasswordBottomSheetContent({
    required this.hasExistingPassword,
    required this.scrollController,
  });

  @override
  State<_SetPasswordBottomSheetContent> createState() =>
      _SetPasswordBottomSheetContentState();
}

class _SetPasswordBottomSheetContentState
    extends State<_SetPasswordBottomSheetContent> {
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

          // Close the bottom sheet after a brief delay to allow the snackbar to show
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            Navigator.of(context).pop(); // Close the bottom sheet
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.64)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle for dragging
              Container(
                width: 37.44,
                height: 5.2,
                margin: const EdgeInsets.symmetric(vertical: 6.24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(104),
                ),
              ),

              // Title
              Container(
                alignment: Alignment.centerLeft,
                child: TranslatedText(
                  'set_password_title'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle
              Container(
                alignment: Alignment.centerLeft,
                child: TranslatedText(
                  'set_password_subtitle'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Password Field
                      AnimatedCrossFade(
                        firstChild: Container(height: 0, width: 0),

                        secondChild: Column(
                          children: [
                            TranslatedText(
                              'current_password'.tr,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AppTextField(
                              hint: 'current_password'.tr,
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
                            const SizedBox(height: 12),
                          ],
                        ),
                        crossFadeState: _hasExistingPassword
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      // New Password Field
                      TranslatedText(
                        'new_password'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        hint: 'new_password'.tr,
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
                      const SizedBox(height: 12),

                      // Confirm Password Field
                      TranslatedText(
                        'rewrite_password'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        hint: 'confirm_new_password'.tr,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Save Button
              Center(
                child: Obx(() => AppButton(
                  text: _hasExistingPassword ? 'Change Password' : 'Save',
                  onPressed: _controller.isLoading ? null : _handleChangePassword,
                  isLoading: _controller.isLoading,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  'set_password_title'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashBackground,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),

                // Subtitle
                TranslatedText(
                  'create_strong_password'.tr,
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
                            _obscureCurrentPassword = !_obscureCurrentPassword;
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(() => AppButton(
                    text: _hasExistingPassword
                        ? 'Change Password'
                        : 'Set Password',
                    onPressed: _controller.isLoading ? null : _handleChangePassword,
                    isLoading: _controller.isLoading,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
