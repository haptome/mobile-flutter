import 'dart:async';
import 'package:et_digital_equb/controllers/your_ekubs_controller.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/category_section_cards.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/warning_banner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/app_assets.dart';
import '../../../../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _homeController;
  PageController? _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<String> _bannerImages = [AppAssets.electronics, AppAssets.mpesa];

  @override
  void initState() {
    super.initState();
    // Initialize controller if not already registered
    if (!Get.isRegistered<HomeController>()) {
      _homeController = Get.put(HomeController());
    } else {
      _homeController = Get.find<HomeController>();
    }
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
        _currentCarouselIndex =
            (_currentCarouselIndex + 1) % _bannerImages.length;
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
    final authService = AuthService.to;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(authService),

                    // Warning Banner
                    Obx(() {
                      return Offstage(
                        offstage: _homeController.isAccountVerified.value,
                        child: const WarningBanner(
                          message:
                              'You haven\'t yet verified your account. Verify now to access all features.',
                        ),
                      );
                    }),
                    _buildAdBanner(),

                    // Ekub Type Section - Show cash categories from API
                    Obx(() {
                      if (_homeController.isLoadingCategories.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return CategorySectionCards(
                        title: 'Ekub For',
                        shadow: false,
                        categories: _homeController.cashCategories,
                        onViewAll: () {
                          Get.toNamed('/ekub-type');
                        },
                        onCategoryTap: (category) {
                          Get.toNamed('/category-detail', arguments: category);
                        },
                      );
                    }),

                    // In-Kind Section - Show in-kind categories from API
                    Obx(() {
                      if (_homeController.isLoadingInKindCategories.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      if (_homeController.inKindCategories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return CategorySectionCards(
                        title: 'In-Kind',
                        categories: _homeController.inKindCategories,
                        onViewAll: _homeController.onViewAllInKind,
                        onCategoryTap: _homeController.onInKindCategoryTap,
                        shadow: true,
                      );
                    }),

                    // Advertisement Banner

                    // Duration Section - Show groups by frequency
                    Obx(() {
                      if (_homeController.isLoadingDuration.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingLarge),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final frequencies = ['daily', 'weekly', 'monthly'];
                      final availableFrequencies = frequencies
                          .where(
                            (f) =>
                                (_homeController.durationGroupsCount[f] ?? 0) >
                                0,
                          )
                          .toList();

                      if (availableFrequencies.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Duration',
                            onViewAll: _homeController.onViewAllDuration,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingLarge,
                            ),
                            child: Row(
                              children: availableFrequencies.take(3).map((
                                frequency,
                              ) {
                                final count =
                                    _homeController
                                        .durationGroupsCount[frequency] ??
                                    0;
                                final label =
                                    frequency[0].toUpperCase() +
                                    frequency.substring(1);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _homeController.onDurationTap(
                                      frequency,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.spacingSmall,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSizes.paddingMedium,
                                        horizontal: AppSizes.paddingSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMedium,
                                        ),
                                        border: Border.all(
                                          color: const Color(0x40000000),
                                          width: 0.4,
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
                                                  color: const Color(
                                                    0x0F000000,
                                                  ),
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
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppSizes.spacingSmall,
                                          ),
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
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingMedium),
                        ],
                      );
                    }),

                    const SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(authService) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final user = authService.currentUser.value;
            final userName = user?.fullName ?? 'User';
            final initials =
                user?.fullName
                    ?.split(' ')
                    .map((n) => n[0])
                    .take(2)
                    .join()
                    .toUpperCase() ??
                'NB';
            return Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                SizedBox(
                  width: 200,
                  child: Text(
                    'Selam, ${userName}!',
                    style: AppTextStyles.h4(
                      color: const Color.fromARGB(255, 100, 80, 80),
                      isDark: false,
                    ).copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),
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
        border: isActive
            ? null
            : Border.all(color: AppColors.primary, width: 1),
      ),
    );
  }
}
