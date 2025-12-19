import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/section_cards.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/warning_banner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../core/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  PageController? _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  
  final List<String> _bannerImages = [
    AppAssets.electronics,
    AppAssets.mpesa,
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselController?.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_carouselController != null && _carouselController!.hasClients) {
        _currentCarouselIndex = (_currentCarouselIndex + 1) % _bannerImages.length;
        _carouselController!.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Container(
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

                    // Warning Banner
                    const WarningBanner(
                      message:
                          'You haven\'t yet verified your account. Verify now to access all features.',
                    ),

                    // Ekub Type Section
                    SectionCards(
                      title: 'Ekub Type',
                      onViewAll: () {
                        Navigator.of(context).pushNamed('/ekub-type');
                      },
                      cards: const [
                        CardItem(
                          iconPath: AppAssets.driversIcon,
                          label: 'For Drivers',
                        ),
                        CardItem(
                          iconPath: AppAssets.merchantIcon,
                          label: 'For Merchant',
                        ),
                        CardItem(
                          iconPath: AppAssets.employeeIcon,
                          label: 'For Employee',
                        ),
                      ],
                    ),

                    // In-Kind Section
                    SectionCards(
                      title: 'In-Kind',
                      onViewAll: () {
                        Navigator.of(context).pushNamed('/in-kind');
                      },
                      cards: const [
                        CardItem(
                          iconPath: AppAssets.driversIcon,
                          label: 'Cars',
                        ),
                        CardItem(
                          iconPath: AppAssets.televisionIcon,
                          label: 'Television',
                        ),
                        CardItem(
                          iconPath: AppAssets.fridgeIcon,
                          label: 'Fridge',
                        ),
                      ],
                    ),

                    // Advertisement Banner
                    _buildAdBanner(),

                    // Duration Section
                    SectionCards(
                      title: 'Duration',
                      onViewAll: () {
                        Navigator.of(context).pushNamed('/duration');
                      },
                      cards: [
                        CardItem(
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
                        CardItem(
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
                        CardItem(
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

                    const SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            AppBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == _currentNavIndex) return; // Don't navigate if already on this screen
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
                  (route) => false, // Remove all previous routes
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'NB',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Selam, Nibertu!',
                style: AppTextStyles.h4(
                  color: AppColors.black,
                  isDark: false,
                ).copyWith(
               fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.black,
                ),
                onPressed: () {
                  // Handle notifications
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: AppSizes.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    Text(
                      'Eng',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.black,
                        isDark: false,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingXSmall),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    if (_carouselController == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingXSmall,
      ),
      child: Column(
        children: [
          // Carousel with images
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _carouselController,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    child: Image.asset(
                      _bannerImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lightBorder,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Dots indicator below the image
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _bannerImages.length,
              (index) => _buildDot(isActive: index == _currentCarouselIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
    );
  }
}

