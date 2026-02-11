// Purpose: Liveness Check Screen with Face Detection and Challenge
// Author: Auto-generated
// Linked Spec Section: KYC ID & Liveness Flow - Liveness Check

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/liveness_controller.dart';
import '../../controllers/id_capture_controller.dart'; // For CaptureState
import '../../models/frame_geometry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/security_utils.dart';
import 'widgets/camera_frame_overlay.dart';
import 'widgets/instruction_overlay.dart';
import 'widgets/challenge_indicator.dart';

class LivenessCheckView extends StatefulWidget {
  const LivenessCheckView({super.key});

  @override
  State<LivenessCheckView> createState() => _LivenessCheckViewState();
}

class _LivenessCheckViewState extends State<LivenessCheckView>
    with WidgetsBindingObserver, SecureScreenMixin {
  LivenessController? controller;
  FrameGeometry? frameGeometry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check if services are available (mobile only)
    try {
      // Initialize controller with dependencies
      controller = Get.put(LivenessController(
        cameraService: Get.find(),
        faceService: Get.find(),
        livenessService: Get.find(),
      ));
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeLiveness();
      });
    } catch (e) {
      // Services not available (likely running on web)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Platform Not Supported',
          'Camera features are only available on mobile devices',
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

  Future<void> _initializeLiveness() async {
    if (controller == null) return;
    
    final screenSize = MediaQuery.of(context).size;
    frameGeometry = FrameGeometry.forFaceDetection(screenSize: screenSize);
    
    await controller!.startLivenessCheck();
    
    // Listen for completion
    ever(controller!.state, (state) {
      if (state == LivenessState.success) {
        _handleSuccess();
      } else if (state == LivenessState.timeout || state == LivenessState.error) {
        _handleError();
      }
    });
  }

  void _handleSuccess() {
    if (controller == null) return;
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      // Navigate to upload/result screen
      Get.back(result: {
        'livenessImage': controller!.capturedImage,
        'challenge': controller!.currentChallenge.value,
      });
    });
  }

  void _handleError() {
    if (controller == null) return;
    
    Get.snackbar(
      'Liveness Check Failed',
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
      controller!.startLivenessCheck();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (controller != null) {
      Get.delete<LivenessController>();
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
        final faceGeometry = frameGeometry;

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

            // Face Frame Overlay (Oval)
            if (faceGeometry != null)
              Positioned.fill(
                child: CameraFrameOverlay(
                  geometry: faceGeometry,
                  state: _mapLivenessStateToCaptureState(state),
                  isOval: true,
                ),
              ),

            // Instruction Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: InstructionOverlay.forLiveness(
                  instruction: controller!.instructionText.value,
                  isError: state == LivenessState.error || state == LivenessState.timeout,
                  isSuccess: state == LivenessState.success,
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

            // Challenge Indicator
            if (state == LivenessState.activeChallenge &&
                controller!.currentChallenge.value != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: ChallengeIndicator(
                  challenge: controller!.currentChallenge.value!,
                ),
              ),

            // Progress Indicator
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: controller!.progress.value,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(controller!.progress.value * 100).toInt()}%',
                    style: AppTextStyles.bodySmall(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Session Timeout Warning
            if (state == LivenessState.timeout)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_off,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Session Timed Out',
                          style: AppTextStyles.h3(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again',
                          style: AppTextStyles.bodyMedium(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            'Go Back',
                            style: AppTextStyles.button(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Helper to map LivenessState to CaptureState for overlay
  CaptureState _mapLivenessStateToCaptureState(LivenessState state) {
    switch (state) {
      case LivenessState.idle:
        return CaptureState.idle;
      case LivenessState.aligningFace:
        return CaptureState.detecting;
      case LivenessState.passiveLiveness:
        return CaptureState.aligned;
      case LivenessState.activeChallenge:
        return CaptureState.aligned;
      case LivenessState.success:
        return CaptureState.success;
      case LivenessState.timeout:
      case LivenessState.error:
        return CaptureState.error;
    }
  }
}
