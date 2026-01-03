// Purpose: Spin button for lottery wheel
// Author: haptome H.
// Linked Spec Section: Lottery Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

class SpinButton extends StatelessWidget {
  final bool isSpinning;
  final VoidCallback onSpin;

  const SpinButton({
    super.key,
    required this.isSpinning,
    required this.onSpin,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: isSpinning ? 'spinning'.tr : 'spin'.tr,
      isLoading: isSpinning,
      onPressed: isSpinning ? null : onSpin,
      minWidth: 200,
    );
  }
}

