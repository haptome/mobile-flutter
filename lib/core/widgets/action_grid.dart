// Purpose: 3x2 action grid widget
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'action_grid_item.dart';

class ActionGrid extends StatelessWidget {
  final Function(String action)? onActionTap;

  const ActionGrid({
    super.key,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0;
    final spacing = 12.0;
    final itemWidth = (screenWidth - (padding * 2) - spacing) / 2;
    final itemHeight = itemWidth * 0.8;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: itemWidth / itemHeight,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: false,
        children: [
          ActionGridItem(
            icon: Icons.payment_outlined,
            label: 'payment'.tr,
            onTap: () => onActionTap?.call('payment'),
          ),
          ActionGridItem(
            icon: Icons.calendar_today_outlined,
            label: 'upcoming'.tr,
            onTap: () => onActionTap?.call('upcoming'),
          ),
          ActionGridItem(
            icon: Icons.confirmation_number_outlined,
            label: 'lottery'.tr,
            onTap: () => onActionTap?.call('lottery'),
          ),
          ActionGridItem(
            icon: Icons.access_time_outlined,
            label: 'current_ekub'.tr,
            onTap: () => onActionTap?.call('current_ekub'),
          ),
          ActionGridItem(
            icon: Icons.check_circle_outline,
            label: 'completed'.tr,
            onTap: () => onActionTap?.call('completed'),
          ),
          ActionGridItem(
            icon: Icons.help_outline,
            label: 'help'.tr,
            onTap: () => onActionTap?.call('help'),
          ),
        ],
      ),
    );
  }
}
