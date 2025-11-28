// Purpose: Custom numeric keypad widget
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLightGray,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Keypad hint (optional - can be removed if not needed)
          const SizedBox(height: 8),
          // Number grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12, // 0-9 numbers + 2 empty spaces for backspace
            itemBuilder: (context, index) {
              if (index == 9) {
                // Empty space
                return const SizedBox.shrink();
              } else if (index == 10) {
                // Zero button
                return _KeypadButton(
                  label: '0',
                  onTap: () => onNumberTap('0'),
                );
              } else if (index == 11) {
                // Backspace button
                return _KeypadButton(
                  isBackspace: true,
                  onTap: onBackspace,
                );
              } else {
                // Numbers 1-9
                final number = (index + 1).toString();
                return _KeypadButton(
                  label: number,
                  onTap: () => onNumberTap(number),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final bool isBackspace;
  final VoidCallback onTap;

  const _KeypadButton({
    this.label,
    this.isBackspace = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLightGray,
              width: 1,
            ),
          ),
          child: Center(
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textDark,
                    size: 24,
                  )
                : Text(
                    label ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

