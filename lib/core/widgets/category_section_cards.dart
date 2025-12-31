// Purpose: Section cards widget for displaying categories with iconify
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'category_small_card.dart';
import 'section_header.dart';
import '../theme/app_sizes.dart';
import '../../models/category_model.dart' as category_models;

/// Reusable section component with header and category cards
class CategorySectionCards extends StatelessWidget {
  final String title;
  final List<category_models.Category> categories;
  final VoidCallback? onViewAll;
  final Function(category_models.Category)? onCategoryTap;

  const CategorySectionCards({
    super.key,
    required this.title,
    required this.categories,
    this.onViewAll,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onViewAll: onViewAll),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
          ),
          child: Row(
            children: [
              ...categories.take(3).map((category) {
                return CategorySmallCard(
                  iconUrl:
                      category.iconUrl ?? 'material-symbols:category-outline',
                  label: category.name,
                  onTap: onCategoryTap != null
                      ? () => onCategoryTap!(category)
                      : null,
                );
              }),
              // Fill remaining slots if less than 3 categories
              for (int i = categories.length; i < 3; i++)
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
      ],
    );
  }
}
