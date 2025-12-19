// Purpose: Country code picker with flags
// Author: haptome H.
// Linked Spec Section: Login Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class CountryCodePicker extends StatefulWidget {
  final CountryCode selectedCountry;
  final Function(CountryCode) onCountrySelected;

  const CountryCodePicker({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  late CountryCode _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
  }

  void _showCountryPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Grab handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'select_country'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const Divider(height: 1),
            // Country list
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = country.code == _selectedCountry.code;

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.dialCode,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                      widget.onCountrySelected(country);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AppColors.borderLightGray,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedCountry.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedCountry.dialCode,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.textLightGray,
            ),
          ],
        ),
      ),
    );
  }

  static const List<CountryCode> _countries = [
    CountryCode(
      name: 'Ethiopia',
      code: 'ET',
      dialCode: '+251',
      flag: '🇪🇹',
    ),
    CountryCode(
      name: 'Kenya',
      code: 'KE',
      dialCode: '+254',
      flag: '🇰🇪',
    ),
    CountryCode(
      name: 'Tanzania',
      code: 'TZ',
      dialCode: '+255',
      flag: '🇹🇿',
    ),
    CountryCode(
      name: 'Uganda',
      code: 'UG',
      dialCode: '+256',
      flag: '🇺🇬',
    ),
    CountryCode(
      name: 'Sudan',
      code: 'SD',
      dialCode: '+249',
      flag: '🇸🇩',
    ),
    CountryCode(
      name: 'Djibouti',
      code: 'DJ',
      dialCode: '+253',
      flag: '🇩🇯',
    ),
    CountryCode(
      name: 'Eritrea',
      code: 'ER',
      dialCode: '+291',
      flag: '🇪🇷',
    ),
    CountryCode(
      name: 'Somalia',
      code: 'SO',
      dialCode: '+252',
      flag: '🇸🇴',
    ),
    CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
  ];
}

