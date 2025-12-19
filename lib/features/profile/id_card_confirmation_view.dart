// Purpose: ID Card Confirmation Screen
// Author: Auto-generated
// Linked Spec Section: Verification - ID Card Confirmation

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/app_assets.dart';
import '../../core/routes/app_routes.dart';

class IdCardConfirmationView extends StatefulWidget {
  final String imagePath;
  final String verificationMethod;

  const IdCardConfirmationView({
    super.key,
    required this.imagePath,
    required this.verificationMethod,
  });

  @override
  State<IdCardConfirmationView> createState() => _IdCardConfirmationViewState();
}

class _IdCardConfirmationViewState extends State<IdCardConfirmationView> {
  int _currentNavIndex = 3; // Profile is index 3

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Background pattern image (no gradient overlay for confirmation screen)
          Positioned.fill(
            child: Image.asset(
              AppAssets.authBackground,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  decoration: BoxDecoration(
                    // Fallback pattern if image fails
                    color: Colors.grey.shade50,
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                      vertical: AppSizes.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.black,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Photo ID Card',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please point the camera at the ID card',
                                    style: AppTextStyles.bodyMedium(
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48), // Balance the back button
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Captured image preview
                        Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.backgroundLightGray,
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: AppColors.textLightGray,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Try Again',
                                type: ButtonType.outlined,
                                textColor: AppColors.black,
                                backgroundColor: AppColors.white,
                                borderRadius: 100,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingMedium),
                            Expanded(
                              child: AppButton(
                                text: 'Continue',
                                type: ButtonType.primary,
                                backgroundColor: AppColors.primary,
                                borderRadius: 100,
                                onPressed: () {
                                  // Return result to verification view
                                  Navigator.of(context).pop({
                                    'imagePath': widget.imagePath,
                                    'verificationMethod': widget.verificationMethod,
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

