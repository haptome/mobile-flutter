// Purpose: Filter bottom sheet widget
// Author: haptome H.
// Linked Spec Section: Ekub Type Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class FilterBottomSheet extends StatelessWidget {
  final RxString selectedFilter;
  final Function(String) onFilterSelected;

  const FilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filterKeys = [
      'all',
      '3_month_filter',
      '6_month_filter',
      '1_year_filter',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
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
          // Filter options
          ListView.builder(
            shrinkWrap: true,
            itemCount: filterKeys.length,
            itemBuilder: (context, index) {
              final filterKey = filterKeys[index];
              final filter = filterKey.tr;
              final isSelected = filterKey == selectedFilter.value || (filterKey == 'all' && selectedFilter.value == 'all');

              return ListTile(
                title: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.black,
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

