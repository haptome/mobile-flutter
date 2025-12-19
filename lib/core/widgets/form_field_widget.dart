// Purpose: Form field widget for account settings
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FormFieldWidget extends StatelessWidget {
  final String label;
  final String? value;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool isDropdown;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const FormFieldWidget({
    super.key,
    required this.label,
    this.value,
    this.hintText,
    this.prefix,
    this.suffix,
    this.isDropdown = false,
    this.onTap,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isDropdown ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderLightGray,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (prefix != null) ...[
                  prefix!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: isDropdown
                      ? Text(
                          value ?? hintText ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: value != null
                                ? AppColors.black
                                : AppColors.textLightGray,
                          ),
                        )
                      : TextField(
                          key: ValueKey(value), // Force rebuild when value changes
                          controller: TextEditingController(text: value)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: value?.length ?? 0),
                            ),
                          onChanged: onChanged,
                          keyboardType: keyboardType,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: const TextStyle(
                              color: AppColors.textLightGray,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 12),
                  suffix!,
                ],
                if (isDropdown && suffix == null)
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.black,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

