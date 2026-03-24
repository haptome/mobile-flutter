import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/deep_link_service.dart';

/// Custom splash screen that displays with a smooth animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with slower duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 2 seconds for animation
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start the animation
    _animationController.forward();

    // Check authentication and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete (2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Get AuthService and check authentication
    final authService = AuthService.to;

    // Wait a bit more for viewing (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Navigate based on authentication state
    if (authService.isAuthenticated.value &&
        authService.currentUser.value != null) {
      // User is authenticated, go to home
      Get.offAllNamed(AppRoutes.home);
    } else {
      // User is not authenticated, go to login
      Get.offAllNamed(AppRoutes.login);
    }

    // Process any deep link that arrived during cold start
    DeepLinkService.to.processPendingLink();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.asset(
                        AppAssets.logo,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacingXLarge),
              // App name with yellow circle - animated with delay
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Delay the text animation slightly
                  final textOpacity = _fadeAnimation.value.clamp(0.0, 1.0);
                  final textScale = _scaleAnimation.value.clamp(0.0, 1.0);

                  return Opacity(
                    opacity: textOpacity,
                    child: Transform.scale(
                      scale: textScale,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ET DIGITAL EQUB',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
