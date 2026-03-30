import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/country_code_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/device_info.dart';
import '../../../../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  final String? prefilledPhone;
  const SignupScreen({super.key, this.prefilledPhone});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AuthController _authController;
  String? _workStatus;
  String? _location;

  @override
  void initState() {
    super.initState();
    // Initialize AuthController if not already registered
    if (!Get.isRegistered<AuthController>()) {
      _authController = Get.put(AuthController());
    } else {
      _authController = Get.find<AuthController>();
    }

    // Pre-fill phone if passed from login redirect
    final phone = widget.prefilledPhone ?? Get.arguments?['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      // Strip country code prefix if present (e.g. +251 → just the 9 digits)
      final digits = phone.startsWith('+251')
          ? phone.substring(4)
          : phone.startsWith('251')
              ? phone.substring(3)
              : phone;
      _phoneController.text = digits;
    }
  }

  final List<String> _workStatuses = const [
    'Employed',
    'Self-employed',
    'Student',
    'Unemployed',
  ];

  final List<String> _locations = const [
    'Addis Abeba',
    'Dire Dawa',
    'Hawassa',
    'Bahir Dar',
    'Mekelle',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Trigger validation for all fields
    // Trigger validation for all fields
    if (_formKey.currentState!.validate()) {
      // Update controller values
      // Phone number should be just the digits (without country code)
      // The controller will add the country code when building the full phone
      _authController.phone.value = _phoneController.text.trim();
      _authController.fullName.value = _fullNameController.text.trim();

      // Ensure country code is set to Ethiopia (default)
      // PhoneInputField uses +251, so we ensure controller matches
      if (_authController.selectedCountry.value.dialCode != '+251') {
        _authController.selectedCountry.value = const CountryCode(
          name: 'Ethiopia',
          code: 'ET',
          dialCode: '+251',
          flag: '🇪🇹',
        );
      }

      // Map work status to backend enum format
      // Backend expects: 'employed', 'self_employed', 'student', 'unemployed', 'retired'
      String? workStatusValue;
      if (_workStatus != null) {
        switch (_workStatus!.toLowerCase()) {
          case 'employed':
            workStatusValue = 'employed';
            break;
          case 'self-employed':
            workStatusValue = 'self_employed';
            break;
          case 'student':
            workStatusValue = 'student';
            break;
          case 'unemployed':
            workStatusValue = 'unemployed';
            break;
          default:
            workStatusValue = 'employed'; // Default fallback
        }
      }
      _authController.workStatus.value = workStatusValue ?? '';

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

      // Call registration API
      await _authController.register(
        fcmToken: fcmToken,
        deviceId: DeviceInfo.getDeviceId(),
      );

      // Check if registration was successful
      // Navigation is handled in AuthController after successful registration
      // The controller will navigate to /otp-verify with proper arguments
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please_enter_name'.tr;
    }
    if (value.trim().length < 3) {
      return 'name_min_length'.tr;
    }
    return null;
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

  String? _validateWorkStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_select_work_status'.tr;
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_select_location'.tr;
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
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.lightTextPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'signup'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashBackground,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  'enter_credential_register'.tr,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                AppTextField(
                  hint: 'full_name'.tr,
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                SizedBox(height: screenHeight * 0.02),
                PhoneInputField(
                  hint: '94 825 228 5',
                  controller: _phoneController,
                  validator: _validatePhone,
                  onSubmitted: (_) => _handleRegister(),
                  maxLength: 9,
                ),
                SizedBox(height: screenHeight * 0.02),

                SizedBox(height: screenHeight * 0.02),
                DropdownButtonFormField<String>(
                  value: _workStatus,
                  dropdownColor: AppColors.white,
                  style: const TextStyle(fontSize: 14, color: AppColors.black),
                  items: _workStatuses
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _workStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'work_status'.tr,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.lightError,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.lightError,
                        width: 2.0,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.textFieldHeight,
                    ),
                  ),
                  validator: _validateWorkStatus,
                ),
                SizedBox(height: screenHeight * 0.02),
                DropdownButtonFormField<String>(
                  value: _location,
                  dropdownColor: AppColors.white,
                  style: const TextStyle(fontSize: 14, color: AppColors.black),
                  items: _locations
                      .map(
                        (location) => DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'location'.tr,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.lightError,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.textFieldRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.lightError,
                        width: 2.0,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.textFieldHeight,
                    ),
                  ),
                  validator: _validateLocation,
                ),

                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Obx(
                    () => AppButton(
                      text: 'register'.tr,
                      onPressed: _handleRegister,
                      isLoading: _authController.isLoading.value,
                      isFullWidth: false,
                      horizontalPadding: 62.2,
                    ),
                  ),
                ),
                // Show error message if any
                Obx(
                  () => _authController.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: AppSizes.spacingSmall,
                          ),
                          child: Text(
                            _authController.errorMessage.value,
                            style: AppTextStyles.bodySmall(
                              color: AppColors.lightError,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                      ),
                      children: [
                        TextSpan(text: 'already_have_account'.tr),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'login'.tr,
                              style:
                                  AppTextStyles.bodyMedium(
                                    color: AppColors.splashBackground,
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
