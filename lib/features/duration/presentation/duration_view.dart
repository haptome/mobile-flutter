// Purpose: Duration page view
// Author: Auto-generated
// Linked Spec Section: Duration Page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/small_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';

class DurationView extends StatefulWidget {
  const DurationView({super.key});

  @override
  State<DurationView> createState() => _DurationViewState();
}

class _DurationViewState extends State<DurationView> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Background image with gradient overlay
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.authBackground,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.lightBackground);
                  },
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0024, 0.2921, 0.5801, 0.8322],
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.9),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        // Cards Grid
                        _buildCardsGrid(),
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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      route,
                      (route) => false,
                    );
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
        ],
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
                onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildCardsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        children: [
          SmallCard(
            iconPath: AppAssets.calendarIcon,
            label: '3 Months',
            iconBackgroundColor: const Color(0xfff7f7e6),
            iconColor: Theme.of(context).colorScheme.secondary,
            iconBoxShadow: [
              BoxShadow(
                color: const Color(0x0F000000), // #0000000F
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          SmallCard(
            iconPath: AppAssets.calendarIcon,
            label: '6 Months',
            iconBackgroundColor: const Color(0xfff7f7e6),
            iconColor: Theme.of(context).colorScheme.secondary,
            iconBoxShadow: [
              BoxShadow(
                color: const Color(0x0F000000), // #0000000F
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          SmallCard(
            iconPath: AppAssets.calendarIcon,
            label: '1 Year',
            iconBackgroundColor: const Color(0xfff7f7e6),
            iconColor: Theme.of(context).colorScheme.secondary,
            iconBoxShadow: [
              BoxShadow(
                color: const Color(0x0F000000), // #0000000F
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

