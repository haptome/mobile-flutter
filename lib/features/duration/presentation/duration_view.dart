// Purpose: Duration page view
// Author: Auto-generated
// Linked Spec Section: Duration Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../controllers/duration_controller.dart';
import '../../../../models/group_model.dart';

class DurationView extends StatefulWidget {
  const DurationView({super.key});

  @override
  State<DurationView> createState() => _DurationViewState();
}

class _DurationViewState extends State<DurationView> {
  int _currentNavIndex = 0;
  final DurationController _controller = Get.put(DurationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    // Frequency Filter Cards
                    Obx(() => _buildFrequencyCards()),
                    const SizedBox(height: AppSizes.spacingMedium),
                    // Groups List
                    Obx(() {
                      if (_controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (_controller.errorMessage.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  _controller.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _controller.loadGroups(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (_controller.filteredGroups.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: Text(
                              'No groups found for selected duration.',
                            ),
                          ),
                        );
                      }
                      return _buildGroupsList();
                    }),
                    const SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),
            // Bottom Navigation
            AppBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == _currentNavIndex) return;
                setState(() {
                  _currentNavIndex = index;
                });
                final route = [
                  AppRoutes.home,
                  AppRoutes.ekubs,
                  AppRoutes.transactions,
                  AppRoutes.profile,
                ][index];
                Get.offAllNamed(route);
              },
              items: const [
                BottomNavItem(
                  iconPath: AppAssets.homeIcon,
                  label: 'Home',
                  route: '/home',
                ),
                BottomNavItem(
                  iconPath: AppAssets.personsIcon,
                  label: 'Your Ekubs',
                  route: '/ekubs',
                ),
                BottomNavItem(
                  iconPath: AppAssets.transactionIcon,
                  label: 'Transactions',
                  route: '/transactions',
                ),
                BottomNavItem(
                  iconPath: AppAssets.profileIcon,
                  label: 'Profile',
                  route: '/profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.lightTextPrimary,
                ),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Duration',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.splashBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyCards() {
    final frequencies = ['daily', 'weekly', 'monthly'];
    final counts = _controller.getFrequencyCounts();
    final availableFrequencies = frequencies
        .where((f) => (counts[f] ?? 0) > 0)
        .toList();

    if (availableFrequencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        children: [
          // All option
          Expanded(
            child: _buildFrequencyCard(
              'All',
              counts.values.fold(0, (sum, count) => sum + count),
              isSelected: _controller.selectedFrequency.value == 'all',
              onTap: () => _controller.onFrequencyTap('all'),
            ),
          ),
          // Frequency options
          ...availableFrequencies.take(2).map((frequency) {
            final count = counts[frequency] ?? 0;
            final label = frequency[0].toUpperCase() + frequency.substring(1);
            return Expanded(
              child: _buildFrequencyCard(
                label,
                count,
                isSelected: _controller.selectedFrequency.value == frequency,
                onTap: () => _controller.onFrequencyTap(frequency),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFrequencyCard(
    String label,
    int count, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall),
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingMedium,
          horizontal: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0x40000000),
            width: isSelected ? 2 : 0.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xfff7f7e6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0F000000),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_today,
                  size: AppSizes.iconMedium,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff232729),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (count > 0)
              Text(
                '$count groups',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: AppColors.textLightGray,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Groups (${_controller.filteredGroups.length})',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          ..._controller.filteredGroups.map((group) {
            return _buildGroupCard(group);
          }),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Group group) {
    return GestureDetector(
      onTap: () => _controller.onGroupTap(group),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.splashBackground,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: group.type == 'public'
                        ? Colors.green
                        : group.type == 'private'
                        ? Colors.orange
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.type.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            if (group.category != null)
              Text(
                group.category!.name,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.textLightGray,
                ),
              ),
            const SizedBox(height: AppSizes.spacingSmall),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textLightGray),
                const SizedBox(width: 4),
                Text(
                  '${group.currentMembers}/${group.targetMembers} Members',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textLightGray,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Icon(Icons.money, size: 16, color: AppColors.textLightGray),
                const SizedBox(width: 4),
                Text(
                  '${group.contributionAmount.toStringAsFixed(0)} ETB ${group.frequency}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textLightGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
