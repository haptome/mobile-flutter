// Purpose: Section item widget for profile menu items
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const SectionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.textDark,
          size: 24,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_outlined,
          color: AppColors.textLightGray,
        ),
        onTap: onTap,
      ),
    );
  }
}

