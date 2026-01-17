import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Phone input field with country flag and code
class PhoneInputField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? errorText;
  final String countryCode;
  final String countryFlag;
  final int? maxLength;

  const PhoneInputField({
    super.key,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.errorText,
    this.countryCode = '+251',
    this.countryFlag = 'assets/icons/ethiopia.svg',
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = AppTextStyles.bodyMedium(isDark: isDark);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      style: textStyle.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(countryFlag, width: 24, height: 24),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                countryCode,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
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
          borderSide: const BorderSide(color: AppColors.lightError, width: 2.0),
        ),
        errorText: errorText,
        counterText: '',
        constraints: const BoxConstraints(minHeight: AppSizes.textFieldHeight),
      ),
    );
  }
}
