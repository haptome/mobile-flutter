// Purpose: Custom back button widget
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        color: AppColors.black,
        size: 24,
      ),
      onPressed: onPressed ?? () => Get.back(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

