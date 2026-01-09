import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/country_code_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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
    
  }
  
  

  final List<String> _workStatuses = const [
    'Employed',
    'Self-employed',
    'Student',
    'Unemployed',
  ];

  final List<String> _locations = const [
    'Ethiopia, Addis Abeba',
    'Ethiopia, Dire Dawa',
    'Ethiopia, Hawassa',
    'Ethiopia, Bahir Dar',
    'Ethiopia, Mekelle',
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

      // Call registration API
      await _authController.register(
        fcmToken: null, // TODO: Add FCM token when Firebase is set up
        deviceId: null, // Will use DeviceInfo.getDeviceId() from controller
      );

      // Check if registration was successful
      // Navigation is handled in AuthController after successful registration
      // The controller will navigate to /otp-verify with proper arguments
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
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

  String? _validateWorkStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your work status';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your location';
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
                      'Signup',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackground,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Enter your credential to register',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    AppTextField(
                      hint: 'Full name',
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
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
                        hintText: 'Work status',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.lightError,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.lightError,
                            width: 2.0,
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: AppSizes.textFieldHeight),
                      ),
                      validator: _validateWorkStatus,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      value: _location,
                      dropdownColor: AppColors.white,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
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
                        hintText: 'Location',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.lightError,
                            width: AppSizes.textFieldBorderWidth,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                          borderSide: const BorderSide(
                            color: AppColors.lightError,
                            width: 2.0,
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: AppSizes.textFieldHeight),
                      ),
                      validator: _validateLocation,
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    Center(
                      child: Obx(
                        () => AppButton(
                          text: 'Register',
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
                              padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
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
                            const TextSpan(text: 'Already have an account? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Login',
                                  style: AppTextStyles.bodyMedium(
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
        ],
      ),
    );
  }
}

