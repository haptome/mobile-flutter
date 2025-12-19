// Purpose: Horizontally scrollable Ekub progress cards with pagination
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ekub_progress_card.dart';

class EkubProgressCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> ekubs;
  final Function(String ekubId)? onEkubTap;

  const EkubProgressCarousel({
    super.key,
    required this.ekubs,
    this.onEkubTap,
  });

  @override
  State<EkubProgressCarousel> createState() => _EkubProgressCarouselState();
}

class _EkubProgressCarouselState extends State<EkubProgressCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ekubs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ekubs.length,
            itemBuilder: (context, index) {
              final ekub = widget.ekubs[index];
              return EkubProgressCard(
                title: ekub['title'] ?? '',
                frequency: ekub['frequency'] ?? '',
                amount: ekub['amount'] ?? '',
                completedRounds: ekub['completedRounds'] ?? 0,
                totalRounds: ekub['totalRounds'] ?? 1,
                onTap: () => widget.onEkubTap?.call(ekub['id'] ?? ''),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.ekubs.length,
            (index) => _buildDot(index == _currentPage),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

