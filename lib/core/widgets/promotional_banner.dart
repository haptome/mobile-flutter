// Purpose: Promotional banner carousel
// Author: haptome H.
// Linked Spec Section: Home Screen

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import '../../controllers/home_controller.dart';

class PromotionalBanner extends StatefulWidget {
  const PromotionalBanner({super.key});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    // Get the existing HomeController instance
    _homeController = Get.find<HomeController>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final campaigns = _homeController.marketingCampaigns;
      
      // Show loading indicator while campaigns are loading
      if (_homeController.isLoadingCampaigns.value) {
        return Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // If no campaigns from server, show fallback banners
      if (campaigns.isEmpty) {
        return _buildFallbackBanners();
      }
      
      // Show campaigns from server
      return Column(
        children: [
          // Banner carousel
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                return _buildServerBanner(campaigns[index]);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Pagination dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(campaigns.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.primary // Green for active
                      : AppColors.lightTextPrimary,
                  border: Border.all(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.borderLightGray,
                    width: 1,
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildServerBanner(Map<String, dynamic> campaign) {
    final title = campaign['title'] as String? ?? '';
    final description = campaign['description'] as String? ?? '';
    final imageUrl = campaign['image_url'] as String? ?? '';
    
    return GestureDetector(
      onTap: () => _homeController.onCampaignTap(campaign),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image if available
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.primary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
            
            // Overlay gradient for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Text content
            Positioned(
              left: 20,
              right: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (title.isNotEmpty && description.isNotEmpty)
                    const SizedBox(height: 8),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.lightTextPrimary.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBanners() {
    return Column(
      children: [
        // Banner carousel
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 3, // Three fallback banners
            itemBuilder: (context, index) {
              return _buildFallbackBanner(index);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? AppColors.primary // Green for active
                    : AppColors.lightTextPrimary,
                border: Border.all(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.borderLightGray,
                  width: 1,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFallbackBanner(int index) {
    if (index == 0) {
      // M-PESA banner
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary, // Green background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Person image placeholder (left side)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Icon(
                  Iconsax.user,
                  size: 60,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
            // Text content (center-right)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mpesa_is_live'.tr,
                    style: const TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 180,
                    child: Text(
                      'mpesa_subtitle'.tr,
                      style: TextStyle(
                        color: AppColors.lightTextPrimary.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Other fallback banners (placeholder)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Banner ${index + 1}',
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }
}
