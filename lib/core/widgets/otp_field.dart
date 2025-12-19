import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Simple OTP input field with 4 or 6 digits, spacing, and focus handling
class OtpField extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final bool autofocus;
  final String? errorText;

  const OtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autofocus = false,
    this.errorText,
  }) : assert(length == 4 || length == 6, 'OTP length must be either 4 or 6');

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    _otpValues = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final pastedValue = value.substring(0, widget.length);
      for (int i = 0; i < pastedValue.length && i < widget.length; i++) {
        _controllers[i].text = pastedValue[i];
        _otpValues[i] = pastedValue[i];
        if (i < widget.length - 1) {
          _focusNodes[i + 1].requestFocus();
        }
      }
      _checkCompletion();
      return;
    }

    _otpValues[index] = value;
    _checkCompletion();

    // Move to next field when value is entered
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Move to previous field when value is deleted
    else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _checkCompletion() {
    final otp = _otpValues.join('');
    widget.onChanged?.call(otp);
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            widget.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < widget.length - 1 ? AppSizes.spacingSmall : 0,
                ),
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  autofocus: widget.autofocus && index == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: AppTextStyles.h3(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    isDark: isDark,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.textFieldBorder,
                        width: AppSizes.textFieldBorderWidth,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.textFieldBorder,
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
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                    counterText: '',
                  ),
                  onChanged: (value) => _onChanged(value, index),
                  onTap: () {
                    _controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    );
                  },
                  onEditingComplete: () {
                    if (index < widget.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption(
              color: AppColors.lightError,
              isDark: isDark,
            ),
          ),
        ],
      ],
    );
  }
}

