// Purpose: ID Card Confirmation Screen
// Author: Auto-generated
// Linked Spec Section: Verification - ID Card Confirmation

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/services/cloudinary_service.dart';

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
  bool _imageExists = false;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkImageExists();
  }

  Future<void> _checkImageExists() async {
    try {
      final file = File(widget.imagePath);
      _imageExists = await file.exists();
    } catch (e) {
      _imageExists = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadAndComplete() async {
    if (!_imageExists) {
      Get.snackbar(
        'error'.tr,
        'image_file_not_found'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get Cloudinary service
      final cloudinaryService = Get.find<CloudinaryService>();

      // Upload to Cloudinary
      final uploadResult = await cloudinaryService.uploadImage(
        filePath: widget.imagePath,
        folder: 'kyc/id_documents',
      );

      if (!uploadResult.success || uploadResult.secureUrl == null) {
        throw Exception(uploadResult.error ?? 'Upload failed');
      }

      // Show success message
      Get.snackbar(
        'success'.tr,
        'id_uploaded_successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Navigate back to profile after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Get.until((route) => route.isFirst);
      
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'upload_failed'.tr + ': $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body:  SafeArea(
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
                                    'photo_id_card'.tr,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'point_camera_id'.tr,
                                    style: AppTextStyles.bodyMedium(
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                            ), // Balance the back button
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Captured image preview
                        Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _isLoading
                                  ? Container(
                                      height: 400,
                                      color: AppColors.backgroundLightGray,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : _imageExists
                                  ? Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 400,
                                          color: AppColors.backgroundLightGray,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  size: 48,
                                                  color:
                                                      AppColors.textLightGray,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'failed_load_image'.tr,
                                                  style:
                                                      AppTextStyles.bodyMedium(
                                                        color: AppColors
                                                            .textLightGray,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 400,
                                      color: AppColors.backgroundLightGray,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.image_not_supported,
                                              size: 48,
                                              color: AppColors.textLightGray,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'image_file_not_found'.tr,
                                              style: AppTextStyles.bodyMedium(
                                                color: AppColors.textLightGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                text: 'try_again'.tr,
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
                                text: 'continue'.tr,
                                type: ButtonType.primary,
                                backgroundColor: AppColors.primary,
                                borderRadius: 100,
                                isLoading: _isUploading,
                                onPressed: _isUploading ? null : _uploadAndComplete,
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
    );
  }
}
