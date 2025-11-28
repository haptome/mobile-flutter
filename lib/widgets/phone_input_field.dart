// Purpose: Phone input field with country code picker
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'country_code_picker.dart';

class PhoneInputField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final CountryCode? selectedCountry;
  final Function(CountryCode)? onCountrySelected;

  const PhoneInputField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.selectedCountry,
    this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final country = selectedCountry ??
        const CountryCode(
          name: 'Ethiopia',
          code: 'ET',
          dialCode: '+251',
          flag: '🇪🇹',
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLightGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Country code picker
          if (onCountrySelected != null)
            CountryCodePicker(
              selectedCountry: country,
              onCountrySelected: onCountrySelected!,
            ),
          // Phone input field
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              validator: validator,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintText: 'enter_phone_number'.tr,
                hintStyle: const TextStyle(
                  color: AppColors.textLightGray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
