// Purpose: Custom bottom bar widget for tab navigation
// Author: Generated for IndexedStack navigation

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../app_assets.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({Key? key, this.index = 0, required this.items})
    : super(key: key);

  final int index;
  final List<BottomBarItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: 60, // Standard bottom bar height
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) => _buildItemView(i: index, item: items.elementAt(index)),
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildItemView({required int i, required BottomBarItem item}) =>
      Expanded(
        child: GestureDetector(
          onTap: () {
            if (item.onClick != null) item.onClick!(i);
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 32,
                child: Text(
                  item.label,
                  style: i == this.index
                      ? TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        )
                      : const TextStyle(
                          color: AppColors.textLightGray,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                ),
              ),
              Positioned(
                top: 8,
                child: SvgPicture.asset(
                  i == this.index ? item.selectedIcon : item.unselectedIcon,
                  width: item.iconSize,
                  height: item.iconSize,
                  colorFilter: i == this.index
                      ? const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        )
                      : const ColorFilter.mode(
                          AppColors.textLightGray,
                          BlendMode.srcIn,
                        ),
                ),
              ),
            ],
          ),
        ),
      );
}

class BottomBarItem {
  final String selectedIcon;
  final String unselectedIcon;
  final String label;
  final double iconSize;
  final Function(int index)? onClick;

  BottomBarItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    this.iconSize = 24,
    this.onClick,
  });
}
