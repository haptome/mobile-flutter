// Purpose: Segmented control tab selector widget for FAQ tabs
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLightGray, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;
            final isLast = index == tabs.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors
                              .primary // Olive green/yellowish-green
                        : AppColors.lightBackground,
                    border: !isLast
                        ? Border(
                            right: BorderSide(
                              color: AppColors.borderLightGray,
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Bold for all tabs
                      color: isSelected
                          ? AppColors.lightTextPrimary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
