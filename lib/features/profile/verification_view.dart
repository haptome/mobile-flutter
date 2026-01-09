// Purpose: Account Verification page
// Author: Auto-generated
// Linked Spec Section: Account Verification Page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../core/widgets/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/app_assets.dart';
import '../../controllers/verification_controller.dart';
import '../../models/kyc_models.dart';
import 'id_card_camera_view.dart';
import 'liveness_video_view.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final VerificationController _controller = Get.put(VerificationController());

  final List<String> _verificationMethods = const [
    'National ID',
    'Kebele ID',
    'Passport',
    'Selfie',
  ];

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
                                color: AppColors.lightTextPrimary,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                'Account Verification',
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.splashBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                            ), // Balance the back button
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Verify Your Identity Section
                        _buildVerifyIdentitySection(),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Liveness Check Section
                        _buildLivenessSection(),
                        const SizedBox(height: AppSizes.spacingLarge),
                        // Upload Documents Section
                        _buildUploadDocumentsSection(),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],
                    ),
                  ),
                ),
                // Continue Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                    vertical: AppSizes.paddingMedium,
                  ),
                  child: Obx(
                    () => AppButton(
                      text: _controller.isLoading.value
                          ? 'Submitting...'
                          : 'Submit for Review',
                      type: ButtonType.primary,
                      onPressed: _controller.isLoading.value
                          ? null
                          : () {
                              if (_controller.uploadedDocuments.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please upload at least one document',
                                    ),
                                    backgroundColor: AppColors.lightError,
                                  ),
                                );
                                return;
                              }
                              _controller.submitDocuments();
                            },
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

  Widget _buildVerifyIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Your Identity',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'Verify your identity with an ID and a clear selfie.',
          style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Obx(
          () => _controller.verificationFile != null
              ? _buildVerificationFileCard()
              : _buildVerificationContainer(),
        ),
      ],
    );
  }

  Widget _buildUploadDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'Add your documents here, and you can upload up to 5 files.',
          style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Obx(
          () => _controller.uploadedFile != null
              ? _buildUploadedFileCard()
              : _buildUploadContainer(),
        ),
      ],
    );
  }

  Widget _buildVerificationContainer() {
    return Container(
      padding: const EdgeInsets.all(17.5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary, width: 0.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000), // #0000000F
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppAssets.icon('camera.svg'),
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          AppButton(
            text: 'Select Verification Method',
            type: ButtonType.outlined,
            textStyle: AppTextStyles.bodySmall(
              color: AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w600),
            horizontalPadding: 12,
            verticalPadding: 6,
            height: 30,
            borderRadius: 100,
            isFullWidth: false,
            onPressed: _showVerificationMethodBottomSheet,
          ),
          Obx(() {
            if (_controller.selectedVerificationMethod != null) {
              return Column(
                children: [
                  const SizedBox(height: AppSizes.spacingSmall),
                  AppButton(
                    text: 'Open Camera',
                    type: ButtonType.primary,
                    textStyle: AppTextStyles.bodySmall(
                      color: AppColors.white,
                    ).copyWith(fontWeight: FontWeight.w600),
                    horizontalPadding: 12,
                    verticalPadding: 6,
                    height: 30,
                    borderRadius: 100,
                    isFullWidth: false,
                    onPressed: _openCameraForVerification,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildVerificationFileCard() {
    if (_controller.verificationFile == null) return const SizedBox.shrink();

    final fileName = _controller.verificationFile!.name;
    final fileSize = _controller.verificationFile!.size;
    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary, width: 0.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000), // #0000000F
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info row
          Row(
            children: [
              // File icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // File name
              Expanded(
                child: Text(
                  fileName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Completed status
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Obx(
            () => Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor:
                    _controller.isUploading.value &&
                        _controller.currentUploadingFile.value ==
                            _controller.verificationFile?.path
                    ? _controller.uploadProgress.value.clamp(0.0, 1.0)
                    : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Upload progress text
          Obx(
            () =>
                _controller.isUploading.value &&
                    _controller.currentUploadingFile.value ==
                        _controller.verificationFile?.path
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Uploading... ${(_controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall(color: AppColors.primary),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          // File size
          Text(
            '${fileSizeMB}MB',
            style: AppTextStyles.bodySmall(color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Change',
                  type: ButtonType.primary,
                  textStyle: AppTextStyles.bodySmall(
                    color: AppColors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                  horizontalPadding: 12,
                  verticalPadding: 8,
                  borderRadius: 8,
                  isFullWidth: true,
                  onPressed: () => _openCameraForVerification(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Remove',
                  type: ButtonType.outlined,
                  textStyle: AppTextStyles.bodySmall(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w600),
                  horizontalPadding: 12,
                  verticalPadding: 8,
                  borderRadius: 8,
                  isFullWidth: true,
                  onPressed: () {
                    _controller.removeVerificationFile();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    // Request permissions before picking file
    final hasPermissions = await _controller.checkPermissions();
    if (!hasPermissions) {
      final granted = await _controller.requestStoragePermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permissions are required to upload files'),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
        return;
      }
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      print(result);
      if (result != null && result.files.single.path != null) {
        // Show document type selection before uploading
        _showDocumentTypeSelection(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _openCameraForVerification() async {
    if (_controller.selectedVerificationMethod == null) {
      _showVerificationMethodBottomSheet();
      return;
    }

    // Request permissions before opening camera
    final hasPermissions = await _controller.checkPermissions();
    if (!hasPermissions) {
      final granted = await _controller.requestStoragePermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera and storage permissions are required to take photos',
              ),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
        return;
      }
    }

    // Navigate to camera view
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => IdCardCameraView(
          verificationMethod: _controller.selectedVerificationMethod!,
        ),
      ),
    );
    print(result);
    // Handle result from camera/confirmation screen
    if (result != null && result['imagePath'] != null && mounted) {
      // Upload the file
      await _controller.uploadVerificationFile(result['imagePath']);
    }
  }

  Widget _buildUploadContainer() {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: AppColors.primary,
        strokeWidth: 0.4,
        borderRadius: AppSizes.radiusMedium,
        dashWidth: 6.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(17.5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F000000), // #0000000F
              blurRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              AppAssets.icon('upload.svg'),
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            AppButton(
              text: 'Upload File',
              type: ButtonType.outlined,
              textStyle: AppTextStyles.bodySmall(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
              horizontalPadding: 12,
              verticalPadding: 6,
              height: 30,
              width: 169,
              borderRadius: 100,
              isFullWidth: false,
              onPressed: _pickFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard() {
    if (_controller.uploadedFile == null) return const SizedBox.shrink();

    final fileName = _controller.uploadedFile!.name;
    final fileSize = _controller.uploadedFile!.size;
    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000), // #0000000F
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info row
          Row(
            children: [
              // File icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // File name
              Expanded(
                child: Text(
                  fileName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Completed status
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Obx(
            () => Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor:
                    _controller.isUploading.value &&
                        _controller.currentUploadingFile.value ==
                            _controller.uploadedFile?.path
                    ? _controller.uploadProgress.value.clamp(0.0, 1.0)
                    : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Upload progress text
          Obx(
            () =>
                _controller.isUploading.value &&
                    _controller.currentUploadingFile.value ==
                        _controller.uploadedFile?.path
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Uploading... ${(_controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall(color: AppColors.primary),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          // File size
          Text(
            '${fileSizeMB}MB',
            style: AppTextStyles.bodySmall(color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Change',
                  type: ButtonType.primary,
                  textStyle: AppTextStyles.bodySmall(
                    color: AppColors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                  horizontalPadding: 12,
                  verticalPadding: 8,
                  borderRadius: 8,
                  isFullWidth: true,
                  onPressed: _pickFile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Remove',
                  type: ButtonType.outlined,
                  textStyle: AppTextStyles.bodySmall(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w600),
                  horizontalPadding: 12,
                  verticalPadding: 8,
                  borderRadius: 8,
                  isFullWidth: true,
                  onPressed: () {
                    _controller.removeUploadedFile();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentTypeSelection(String filePath) {
    final Map<DocumentType, String> documentTypes = {
      DocumentType.nationalId: 'National ID',
      DocumentType.passport: 'Passport',
      DocumentType.driversLicense: 'Driver\'s License',
      DocumentType.utilityBill: 'Utility Bill',
      DocumentType.bankStatement: 'Bank Statement',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLarge),
              topRight: Radius.circular(AppSizes.radiusLarge),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightTextSecondary, // Use existing color
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  'Select Document Type',
                  style: AppTextStyles.h3(color: AppColors.splashBackground),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  'Choose the type of document you are uploading',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                // Document type options
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: documentTypes.length,
                    itemBuilder: (context, index) {
                      final entry = documentTypes.entries.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(entry.value),
                          onTap: () {
                            // Upload the file with selected document type
                            _controller.uploadDocumentFile(
                              filePath,
                              docType: entry.key,
                            );
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Cancel button
                AppButton(
                  text: 'Cancel',
                  type: ButtonType.outlined,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVerificationMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Select Verification Method',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const Divider(height: 1),
            // Verification method options
            ListView.builder(
              shrinkWrap: true,
              itemCount: _verificationMethods.length,
              itemBuilder: (context, index) {
                final method = _verificationMethods[index];
                final isSelected =
                    method == _controller.selectedVerificationMethod;

                return ListTile(
                  title: Text(
                    method,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: AppColors.black,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    _controller.setVerificationMethod(method);
                    Navigator.of(context).pop();
                    // Open camera for verification
                    await _openCameraForVerification();
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLivenessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liveness Check',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'Record a short video to verify you are a real person.',
          style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Obx(
          () => _controller.livenessCompleted
              ? _buildLivenessCompletedCard()
              : _buildLivenessContainer(),
        ),
      ],
    );
  }

  Widget _buildLivenessContainer() {
    return Container(
      padding: const EdgeInsets.all(17.5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary, width: 0.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppAssets.icon('camera.svg'),
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          AppButton(
            text: 'Start Liveness Check',
            type: ButtonType.primary,
            textStyle: AppTextStyles.bodySmall(
              color: AppColors.white,
            ).copyWith(fontWeight: FontWeight.w600),
            horizontalPadding: 12,
            verticalPadding: 6,
            height: 30,
            borderRadius: 100,
            isFullWidth: false,
            onPressed: () async {
              // Request permissions before starting liveness check
              final hasPermissions = await _controller.checkPermissions();
              if (!hasPermissions) {
                final granted = await _controller.requestStoragePermissions();
                if (!granted) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Camera and storage permissions are required for liveness check',
                        ),
                        backgroundColor: AppColors.lightError,
                      ),
                    );
                  }
                  return;
                }
              }

              // Initiate liveness session first
              await _controller.initiateLivenessCheck();
              if (_controller.livenessSessionId != null) {
                // Navigate to video recording screen
                final result = await Navigator.of(context)
                    .push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (context) => const LivenessVideoView(),
                      ),
                    );
                // Handle result from video recording
                if (result != null && result['videoPath'] != null && mounted) {
                  // Submit the video
                  await _controller.submitLivenessVideo(result['videoPath']);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLivenessCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.green, width: 0.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liveness Check Completed',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your video has been verified',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            text: 'Retake',
            type: ButtonType.outlined,
            textStyle: AppTextStyles.bodySmall(
              color: AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w600),
            horizontalPadding: 12,
            verticalPadding: 6,
            height: 30,
            borderRadius: 100,
            isFullWidth: false,
            onPressed: () {
              _controller.resetLiveness();
            },
          ),
        ],
      ),
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = _createDashPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashPath(Path path, double dashWidth, double dashSpace) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Failed uploads section widget
extension FailedUploadsSection on _VerificationViewState {
  Widget _buildFailedUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Failed Uploads',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (_controller.failedUploads.length > 1)
              TextButton(
                onPressed: () {
                  _controller.clearFailedUploads();
                },
                child: Text(
                  'Clear All',
                  style: AppTextStyles.bodySmall(color: AppColors.lightError),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'Some uploads failed. You can retry them.',
          style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        ..._controller.failedUploads.map((failedUpload) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.lightError.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.lightError,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        failedUpload.filePath.split('/').last,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.splashBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  failedUpload.errorMessage.isNotEmpty
                      ? failedUpload.errorMessage
                      : 'Upload failed',
                  style: AppTextStyles.bodySmall(color: AppColors.lightError),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Retry',
                        type: ButtonType.primary,
                        textStyle: AppTextStyles.bodySmall(
                          color: AppColors.white,
                        ).copyWith(fontWeight: FontWeight.w600),
                        horizontalPadding: 12,
                        verticalPadding: 8,
                        borderRadius: 8,
                        isFullWidth: true,
                        onPressed: () {
                          _controller.retryUpload(failedUpload);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Dismiss',
                        type: ButtonType.outlined,
                        textStyle: AppTextStyles.bodySmall(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w600),
                        horizontalPadding: 12,
                        verticalPadding: 8,
                        borderRadius: 8,
                        isFullWidth: true,
                        onPressed: () {
                          _controller.failedUploads.remove(failedUpload);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
