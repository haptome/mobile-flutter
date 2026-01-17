// Purpose: Form field widget for account settings
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isDropdown ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: isDropdown
                ? BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.borderLightGray,
                      width: 1,
                    ),
                  )
                : null,
            child: Row(
              children: [
                // if (prefix != null) ...[prefix!, const SizedBox(width: 12)],
                Expanded(
                  child: isDropdown
                      ? Text(
                          value ?? hintText ?? '',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: value != null
                                ? AppColors.black
                                : AppColors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : TextField(
                          // key: ValueKey(
                          //   value,
                          // ), // Force rebuild when value changes
                          controller: TextEditingController(text: value)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: value?.length ?? 0),
                            ),
                          onChanged: onChanged,
                          keyboardType: keyboardType,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppColors.black,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: AppColors.black.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            prefix: (prefix != null) ? prefix! : null,
                            suffix: (suffix != null) ? suffix! : null,
                            isDense: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
                // if (suffix != null) ...[const SizedBox(width: 12), suffix!],
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
