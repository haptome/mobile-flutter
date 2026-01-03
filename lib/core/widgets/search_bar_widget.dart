// Purpose: Search bar with filter button
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLightGray, width: 1),
              ),
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText ?? 'search'.tr,
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                    color: AppColors.textLightGray,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter button
          if (onFilterTap != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLightGray, width: 1),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.filter_list_outlined,
                  color: AppColors.lightTextPrimary,
                ),
                onPressed: onFilterTap,
              ),
            ),
        ],
      ),
    );
  }
}
