// Purpose: Account Verification page
// Author: Auto-generated
// Linked Spec Section: Account Verification Page

import 'package:et_digital_equb/core/widgets/rotating_svg_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconify_design/iconify_design.dart';
import '../../core/widgets/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/app_assets.dart';
import '../../controllers/verification_controller.dart';
import 'id_type_selection_view.dart';
import '../../core/widgets/scaffold_with_bottom_bar.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final VerificationController _controller = Get.put(VerificationController());

  @override
  void initState() {
    super.initState();
    // Refresh KYC status when the view becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.checkKycStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomBar(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // Check if user is in draft or pending status
          if (_controller.isCheckingKycStatus.value) {
            // Show loading state while checking KYC status
            return _buildCheckingStatusScreen();
          } else if (_controller.isDraftOrPending) {
            // Show the checking status screen if user is in draft or pending status
            return _buildCheckingStatusScreen();
          } else if (_controller.isApproved) {
            // Show the approved status screen if user is approved
            return _buildApprovedStatusScreen();
          } else {
            // Show the regular verification form
            return IdTypeSelectionView();
          }
        }),
      ),
    );
  }

  Widget _buildVerifyIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verify_your_identity'.tr,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'verify_identity_desc'.tr,
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
            text: 'start_id_verification'.tr,
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
              // Navigate to ID type selection (new KYC flow)
              await Get.to(() => const IdTypeSelectionView());
            },
          ),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                    'completed'.tr,
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                      'uploading'.tr + '... ${(_controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
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
                  text: 'change'.tr,
                  type: ButtonType.primary,
                  textStyle: AppTextStyles.bodySmall(
                    color: AppColors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                  horizontalPadding: 12,
                  verticalPadding: 8,
                  borderRadius: 8,
                  isFullWidth: true,
                  onPressed: () async {
                    // Navigate to ID type selection (new KYC flow)
                    await Get.to(() => const IdTypeSelectionView());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'remove'.tr,
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
}
  Widget _buildCheckingStatusScreen() {
  return Container(
    width: double.infinity,
    color: AppColors.white,
    child: Column(
      children: [
        // Curved header with overlapping circular progress (Figma: 390x216 @ top:46)
        SizedBox(
          height: 300, // top offset 46 + rect height 216
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    size: const Size(390, 216),
                    painter: CurvedHeader(),
                  ),
                ),
              ),

              // Loader container
              Positioned(
                bottom: 16,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: RotatingSvgLoader(),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Headline & subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              Text(
                'checking_please_wait'.tr,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 11),
              Text(
                'account_being_checked'.tr,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
    ),
  );
}

// Custom painter for dashed border
class CurvedHeader extends CustomPainter {
  final Color color;

  CurvedHeader({this.color = const Color(0xFFEBF0F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height - 15);

    // Bottom curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 60,
      size.width,
      size.height - 15,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvedHeader oldDelegate) =>
      oldDelegate.color != color;
}

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
  Widget _buildApprovedStatusScreen() {
  return Container(
    width: double.infinity,
    color: AppColors.white,
    child: Column(
      children: [
        // Curved header with overlapping circular progress (Figma: 390x216 @ top:46)
        SizedBox(
          height: 300, // top offset 46 + rect height 216
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    size: const Size(390, 216),
                    painter: CurvedHeader(color: const Color(0xFFE3F4E1)),
                  ),
                ),
              ),

              // Loader container
              Positioned(
                bottom: 16,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: IconifyIcon(
                      icon: 'line-md:circle-to-confirm-circle-transition',
                      color: Color(0xFF00796B),
                      size: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Headline & subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              Text(
                'verified'.tr + '!',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 11),
              Text(
                'account_ready'.tr,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
    ),
  );
}
