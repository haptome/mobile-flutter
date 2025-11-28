// Purpose: OTP input field with 6 square boxes
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const OtpInputField({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.length <= 6) {
      _updateControllers(widget.initialValue!);
    }
    _focusNodes[0].requestFocus();
  }

  void _updateControllers(String value) {
    for (int i = 0; i < 6; i++) {
      if (i < value.length) {
        _controllers[i].text = value[i];
      } else {
        _controllers[i].clear();
      }
    }
    if (value.length > 0 && value.length <= 6) {
      setState(() => _currentIndex = value.length > 5 ? 5 : value.length);
      if (value.length < 6) {
        _focusNodes[value.length].requestFocus();
      }
    }
  }

  @override
  void didUpdateWidget(OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _updateControllers(widget.initialValue ?? '');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value[value.length - 1];
      widget.onChanged?.call(_getOtpCode());

      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
        setState(() => _currentIndex = index + 1);
      } else {
        _focusNodes[index].unfocus();
        widget.onCompleted?.call(_getOtpCode());
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          setState(() => _currentIndex = index - 1);
        } else {
          _controllers[index].clear();
        }
        widget.onChanged?.call(_getOtpCode());
      }
    }
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 48,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(event, index),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _currentIndex == index
                        ? AppColors.borderActive
                        : AppColors.borderLightGray,
                    width: _currentIndex == index ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.borderLightGray,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.borderActive,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onChanged(value, index),
            ),
          ),
        );
      }),
    );
  }
}

