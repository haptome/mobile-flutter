import 'package:flutter/material.dart';
import 'small_card.dart';
import 'section_header.dart';
import '../theme/app_sizes.dart';

/// Card item data model
class CardItem {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? iconBoxShadow;
  final Color? iconColor;

  const CardItem({
    required this.iconPath,
    required this.label,
    this.onTap,
    this.iconBackgroundColor,
    this.iconBoxShadow,
    this.iconColor,
  });
}

/// Reusable section component with header and cards
class SectionCards extends StatelessWidget {
  final String title;
  final List<CardItem> cards;
  final VoidCallback? onViewAll;

  const SectionCards({
    super.key,
    required this.title,
    required this.cards,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onViewAll: onViewAll,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Row(
            children: cards.map((card) {
              return SmallCard(
                iconPath: card.iconPath,
                label: card.label,
                onTap: card.onTap,
                iconBackgroundColor: card.iconBackgroundColor,
                iconBoxShadow: card.iconBoxShadow,
                iconColor: card.iconColor,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
      ],
    );
  }
}

