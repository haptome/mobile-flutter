// Purpose: ID Capture Screen with Auto-Capture
// Author: Auto-generated
// Linked Spec Section: KYC ID & Liveness Flow - ID Capture

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/id_capture_controller.dart';
import '../../models/id_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/security_utils.dart';
import 'widgets/camera_frame_overlay.dart';
import 'widgets/instruction_overlay.dart';
import 'widgets/success_animation.dart';
import 'id_card_confirmation_view.dart';

class IdCaptureView extends StatefulWidget {
  final IDType idType;

  const IdCaptureView({super.key, required this.idType});

  @override
  State<IdCaptureView> createState() => _IdCaptureViewState();
}

class _IdCaptureViewState extends State<IdCaptureView>
    with WidgetsBindingObserver, SecureScreenMixin {
  IDCaptureController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check if services are available (mobile only)
    try {
      // Initialize controller with dependencies
      // Set testMode to true to skip quality validation for testing
      controller = Get.put(IDCaptureController(
        cameraService: Get.find(),
        edgeService: Get.find(),
        qualityService: Get.find(),
        testMode: false, // Enable test mode to bypass quality checks
      ));
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeCapture();
      });
    } catch (e) {
      // Services not available (likely running on web)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'platform_not_supported'.tr,
          'camera_mobile_only'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      });
    }
  }

  Future<void> _initializeCapture() async {
    if (controller == null) return;
    
    final screenSize = MediaQuery.of(context).size;
    
    await controller!.startCapture(widget.idType, screenSize);
    
    // Listen for capture completion
    ever(controller!.state, (state) {
      if (state == CaptureState.success) {
        _handleCaptureSuccess();
      } else if (state == CaptureState.error) {
        _handleCaptureError();
      }
    });
  }

  void _handleCaptureSuccess() {
    if (controller == null) return;
    
    // Show success animation briefly
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (controller!.isFrontSide.value &&
          IDTypeInfo.fromType(widget.idType).requiresBackSide) {
        // Controller will handle switching to back side automatically
      } else {
        // All sides captured, navigate to confirmation screen
        final captureResult = controller!.isFrontSide.value 
            ? controller!.frontCaptureResult.value 
            : controller!.backCaptureResult.value;
            
        if (captureResult != null) {
          // Dispose camera before navigating
          controller!.onClose();
          
          Get.off(() => IdCardConfirmationView(
            imagePath: captureResult.path,
            verificationMethod: 'id_card',
          ));
        }
      }
    });
  }

  void _handleCaptureError() {
    if (controller == null) return;
    
    Get.snackbar(
      'capture_failed'.tr,
      controller!.errorMessage.value,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null) return;
    
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      controller!.onClose();
    } else if (state == AppLifecycleState.resumed) {
      final screenSize = MediaQuery.of(context).size;
      controller!.startCapture(widget.idType, screenSize);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (controller != null) {
      Get.delete<IDCaptureController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if controller not initialized
    if (controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final cameraController = controller!.cameraController;
        final state = controller!.state.value;
        final frameGeometry = controller!.frameGeometry.value;

        return Stack(
          children: [
            // Camera Preview
            if (cameraController != null &&
                cameraController.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(cameraController),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            // Camera Frame Overlay
            if (frameGeometry != null)
              Positioned.fill(
                child: CameraFrameOverlay(
                  geometry: frameGeometry,
                  state: state,
                ),
              ),

            // Instruction Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: InstructionOverlay.forIDCapture(
                  state: state,
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            // Manual Capture Button
            if (state != CaptureState.success)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      // Capture button
                      GestureDetector(
                        onTap: () => controller!.manualCapture(),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'tap_capture_manually'.tr,
                        style: AppTextStyles.bodySmall(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Success Animation
            if (state == CaptureState.success)
              const Positioned.fill(
                child: SuccessAnimation(),
              ),
          ],
        );
      }),
    );
  }
}
