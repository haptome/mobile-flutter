// Purpose: Price range filter bottom sheet widget
// Author: haptome H.
// Linked Spec Section: In-Kind Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class PriceRangeFilterBottomSheet extends StatelessWidget {
  final RxString selectedFilter;
  final Function(String) onFilterSelected;

  const PriceRangeFilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filterKeys = [
      'all',
      'range_1k_10k',
      'range_10k_50k',
      'range_50k_100k',
      'range_100k_1m',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              'equb_range'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Divider(height: 1),
          // Filter options
          ListView.builder(
            shrinkWrap: true,
            itemCount: filterKeys.length,
            itemBuilder: (context, index) {
              final filterKey = filterKeys[index];
              final filter = filterKey == 'all' 
                  ? 'all'.tr 
                  : 'equb_range'.tr + ': ${filterKey.tr}';
              final isSelected = filterKey == selectedFilter.value || (filterKey == 'all' && selectedFilter.value == 'all');

              return ListTile(
                title: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textDark,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  onFilterSelected(filterKey);
                  Get.back();
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

