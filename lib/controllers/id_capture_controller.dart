// Purpose: Controller for orchestrating ID document capture flow
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 4.1 - ID Capture Controller

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/camera_service.dart';
import '../core/services/edge_detection_service.dart';
import '../core/services/image_quality_service.dart';
import '../core/utils/adaptive_frame_processor.dart';
import '../models/id_type.dart';
import '../models/frame_geometry.dart';
import '../models/capture_result.dart';
import '../models/detection_result.dart';
import '../models/quality_check_result.dart';

/// Enum representing the current state of the ID capture flow
enum CaptureState {
  /// Initial state, camera not yet started
  idle,

  /// Actively detecting document edges in frames
  detecting,

  /// Document is aligned within frame, waiting for stability
  aligned,

  /// Capturing the image
  capturing,

  /// Validating image quality
  validating,

  /// Capture successful
  success,

  /// Error occurred
  error,
}

/// Controller for orchestrating the ID capture flow
///
/// This controller manages the complete ID document capture process:
/// - Camera initialization and frame streaming
/// - Real-time edge detection
/// - Auto-capture when document is aligned and stable
/// - Manual capture fallback
/// - Image quality validation
/// - Front/back side switching
///
/// The controller uses reactive state management (GetX) to update the UI
/// in real-time as the capture state changes.
///
/// Example usage:
/// ```dart
/// final controller = Get.put(IDCaptureController(
///   cameraService: Get.find<CameraService>(),
///   edgeService: Get.find<EdgeDetectionService>(),
///   qualityService: Get.find<ImageQualityService>(),
/// ));
///
/// // Start capture for National ID
/// await controller.startCapture(IDType.nationalId);
///
/// // Listen to state changes
/// ever(controller.state, (state) {
///   if (state == CaptureState.success) {
///     // Navigate to next screen
///   }
/// });
/// ```
class IDCaptureController extends GetxController {
  // Dependencies (injected)
  final CameraService _cameraService;
  final EdgeDetectionService _edgeService;
  final ImageQualityService _qualityService;

  // Constructor with dependency injection
  IDCaptureController({
    required CameraService cameraService,
    required EdgeDetectionService edgeService,
    required ImageQualityService qualityService,
    this.testMode = false, // Add test mode flag
  })  : _cameraService = cameraService,
        _edgeService = edgeService,
        _qualityService = qualityService;

  // Test mode flag - when true, skips quality validation
  final bool testMode;

  // Reactive state variables
  /// Currently selected ID type
  final selectedIDType = Rx<IDType?>(null);

  /// Whether capturing front side (true) or back side (false)
  final isFrontSide = true.obs;

  /// Current capture state
  final state = CaptureState.idle.obs;

  /// Current frame geometry for the overlay
  final frameGeometry = Rx<FrameGeometry?>(null);

  /// Latest edge detection result
  final detectionResult = Rx<EdgeDetectionResult?>(null);

  /// Captured front side result
  final frontCaptureResult = Rx<CaptureResult?>(null);

  /// Captured back side result (null for passports)
  final backCaptureResult = Rx<CaptureResult?>(null);

  /// Error message (if any)
  final errorMessage = ''.obs;

  // Private state variables
  StreamSubscription<CameraImage>? _frameSubscription;
  Timer? _stabilityTimer;
  final _frameProcessor = AdaptiveFrameProcessor();
  bool _isProcessingFrame = false;
  bool _isCapturing = false;

  /// Get the camera controller for UI rendering
  CameraController? get cameraController => _cameraService.controller;

  /// Check if camera is initialized
  bool get isCameraInitialized => _cameraService.isInitialized;

  /// Get current FPS for debugging
  double get currentFps => _cameraService.currentFps;

  /// Check if back side is required for current ID type
  bool get requiresBackSide {
    if (selectedIDType.value == null) return false;
    final idTypeInfo = IDTypeInfo.forType(selectedIDType.value!);
    return idTypeInfo.requiresBackSide;
  }

  /// Check if both sides have been captured (or only front if back not required)
  bool get isComplete {
    if (selectedIDType.value == null) return false;
    if (!requiresBackSide) {
      return frontCaptureResult.value != null;
    }
    return frontCaptureResult.value != null && backCaptureResult.value != null;
  }

  /// Start the capture flow for a specific ID type
  ///
  /// [idType] - The type of ID document to capture
  /// [screenSize] - The screen size for calculating frame geometry
  ///
  /// This method:
  /// 1. Initializes the camera
  /// 2. Calculates frame geometry based on ID type
  /// 3. Starts frame processing for edge detection
  /// 4. Sets up auto-capture logic
  Future<void> startCapture(IDType idType, Size screenSize) async {
    try {
      // Set ID type
      selectedIDType.value = idType;

      // Calculate frame geometry
      frameGeometry.value = FrameGeometry.forIDCapture(
        screenSize: screenSize,
        idType: idType,
      );

      // Initialize camera
      await _cameraService.initialize(
        direction: CameraLensDirection.back,
        resolution: ResolutionPreset.medium,
      );

      // Start frame processing
      _startFrameProcessing();

      // Update state
      state.value = CaptureState.detecting;
    } catch (e) {
      errorMessage.value = 'Failed to initialize camera: $e';
      state.value = CaptureState.error;
    }
  }

  /// Start processing camera frames for edge detection
  void _startFrameProcessing() {
    // Reset frame processor
    _frameProcessor.reset();

    // Subscribe to frame stream
    _frameSubscription = _cameraService.frameStream.listen((frame) {
      _processFrame(frame);
    });
  }

  /// Process a single camera frame
  ///
  /// This method:
  /// 1. Checks if frame should be processed (adaptive FPS)
  /// 2. Runs edge detection
  /// 3. Updates detection result
  /// 4. Triggers auto-capture if aligned and stable
  void _processFrame(CameraImage frame) {
    // Skip if already processing a frame
    if (_isProcessingFrame) return;

    // Skip if currently capturing
    if (_isCapturing) return;

    // Check if we should process this frame (adaptive based on FPS)
    if (!_frameProcessor.shouldProcessFrame(_cameraService.currentFps)) {
      return;
    }

    // Mark as processing
    _isProcessingFrame = true;

    try {
      // Run edge detection
      if (frameGeometry.value != null) {
        final result = _edgeService.detectEdges(
          frame,
          frameGeometry.value!,
        );

        // Update detection result
        detectionResult.value = result;

        // Handle alignment state
        if (result != null && result.isAligned) {
          _handleAlignedState();
        } else {
          _handleNotAlignedState();
        }
      }
    } finally {
      // Mark as done processing
      _isProcessingFrame = false;
    }
  }

  /// Handle state when document is aligned
  void _handleAlignedState() {
    // Update state to aligned if not already
    if (state.value == CaptureState.detecting) {
      state.value = CaptureState.aligned;

      // Start stability timer (500ms)
      _startStabilityTimer();
    }
  }

  /// Handle state when document is not aligned
  void _handleNotAlignedState() {
    // Cancel stability timer if running
    _cancelStabilityTimer();

    // Update state back to detecting if was aligned
    if (state.value == CaptureState.aligned) {
      state.value = CaptureState.detecting;
    }
  }

  /// Start stability timer for auto-capture
  ///
  /// The document must remain aligned for 500ms before auto-capture triggers
  void _startStabilityTimer() {
    // Cancel existing timer if any
    _cancelStabilityTimer();

    // Start new timer
    _stabilityTimer = Timer(const Duration(milliseconds: 500), () {
      // Check if still aligned
      if (state.value == CaptureState.aligned) {
        _attemptAutoCapture();
      }
    });
  }

  /// Cancel stability timer
  void _cancelStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  /// Attempt auto-capture
  ///
  /// This method:
  /// 1. Captures the image
  /// 2. Validates quality
  /// 3. If passed: saves result and moves to next step
  /// 4. If failed: shows error and returns to detecting
  Future<void> _attemptAutoCapture() async {
    if (_isCapturing) return;

    try {
      _isCapturing = true;
      state.value = CaptureState.capturing;

      // Stop frame streaming temporarily
      await _cameraService.stopFrameStreaming();

      // Capture image
      final imageFile = await _cameraService.takePicture();

      // Validate quality (skip in test mode)
      state.value = CaptureState.validating;
      final qualityResult = testMode
          ? const QualityCheckResult(
              isSharp: true,
              hasNoGlare: true,
              hasGoodLighting: true,
              blurScore: 200.0,
              glarePercentage: 0.0,
              brightness: 128.0,
            )
          : await _qualityService.checkQuality(imageFile);

      if (qualityResult.passed) {
        // Quality check passed - save result
        final captureResult = CaptureResult(
          imageFile: imageFile,
          idType: selectedIDType.value!,
          isFrontSide: isFrontSide.value,
          qualityCheck: qualityResult,
          timestamp: DateTime.now(),
        );

        // Save to appropriate side
        if (isFrontSide.value) {
          frontCaptureResult.value = captureResult;
        } else {
          backCaptureResult.value = captureResult;
        }

        // Update state to success
        state.value = CaptureState.success;

        // Wait a moment to show success animation
        await Future.delayed(const Duration(milliseconds: 1000));

        // Check if we need to capture back side
        if (isFrontSide.value && requiresBackSide) {
          // Switch to back side
          await _switchToBackSide();
        }
        // Otherwise, capture is complete (handled by UI)
      } else {
        // Quality check failed - show error and retry
        errorMessage.value = qualityResult.message;
        state.value = CaptureState.error;

        // Wait a moment to show error
        await Future.delayed(const Duration(milliseconds: 2000));

        // Return to detecting state
        state.value = CaptureState.detecting;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
      state.value = CaptureState.error;

      // Wait a moment to show error
      await Future.delayed(const Duration(milliseconds: 2000));

      // Return to detecting state
      state.value = CaptureState.detecting;
      errorMessage.value = '';
    } finally {
      _isCapturing = false;

      // Resume frame streaming if still in detecting state
      if (state.value == CaptureState.detecting) {
        _startFrameProcessing();
      }
    }
  }

  /// Switch to capturing back side of document
  Future<void> _switchToBackSide() async {
    // Update side flag
    isFrontSide.value = false;

    // Reset state
    state.value = CaptureState.detecting;
    detectionResult.value = null;

    // Resume frame processing
    _startFrameProcessing();
  }

  /// Manual capture fallback
  ///
  /// Allows user to manually trigger capture if auto-capture is not working
  /// This bypasses edge detection but still validates quality
  Future<void> manualCapture() async {
    if (_isCapturing) return;

    try {
      _isCapturing = true;
      state.value = CaptureState.capturing;

      // Cancel any pending timers
      _cancelStabilityTimer();

      // Stop frame streaming temporarily
      await _cameraService.stopFrameStreaming();

      // Capture image
      final imageFile = await _cameraService.takePicture();

      // Validate quality (skip in test mode)
      state.value = CaptureState.validating;
      final qualityResult = testMode
          ? const QualityCheckResult(
              isSharp: true,
              hasNoGlare: true,
              hasGoodLighting: true,
              blurScore: 200.0,
              glarePercentage: 0.0,
              brightness: 128.0,
            )
          : await _qualityService.checkQuality(imageFile);

      if (qualityResult.passed) {
        // Quality check passed - save result
        final captureResult = CaptureResult(
          imageFile: imageFile,
          idType: selectedIDType.value!,
          isFrontSide: isFrontSide.value,
          qualityCheck: qualityResult,
          timestamp: DateTime.now(),
        );

        // Save to appropriate side
        if (isFrontSide.value) {
          frontCaptureResult.value = captureResult;
        } else {
          backCaptureResult.value = captureResult;
        }

        // Update state to success
        state.value = CaptureState.success;

        // Wait a moment to show success animation
        await Future.delayed(const Duration(milliseconds: 1000));

        // Check if we need to capture back side
        if (isFrontSide.value && requiresBackSide) {
          // Switch to back side
          await _switchToBackSide();
        }
        // Otherwise, capture is complete (handled by UI)
      } else {
        // Quality check failed - show error and retry
        errorMessage.value = qualityResult.message;
        state.value = CaptureState.error;

        // Wait a moment to show error
        await Future.delayed(const Duration(milliseconds: 2000));

        // Return to detecting state
        state.value = CaptureState.detecting;
        errorMessage.value = '';

        // Resume frame streaming
        _startFrameProcessing();
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
      state.value = CaptureState.error;

      // Wait a moment to show error
      await Future.delayed(const Duration(milliseconds: 2000));

      // Return to detecting state
      state.value = CaptureState.detecting;
      errorMessage.value = '';

      // Resume frame streaming
      _startFrameProcessing();
    } finally {
      _isCapturing = false;
    }
  }

  /// Retry capture after error
  ///
  /// Resets state and resumes frame processing
  void retryCapture() {
    errorMessage.value = '';
    state.value = CaptureState.detecting;
    detectionResult.value = null;

    // Resume frame processing
    _startFrameProcessing();
  }

  /// Reset controller to initial state
  ///
  /// Useful for starting a new capture session
  void reset() {
    // Cancel subscriptions and timers
    _cancelStabilityTimer();
    _frameSubscription?.cancel();
    _frameSubscription = null;

    // Reset state
    selectedIDType.value = null;
    isFrontSide.value = true;
    state.value = CaptureState.idle;
    frameGeometry.value = null;
    detectionResult.value = null;
    frontCaptureResult.value = null;
    backCaptureResult.value = null;
    errorMessage.value = '';

    // Reset flags
    _isProcessingFrame = false;
    _isCapturing = false;
    _frameProcessor.reset();
  }

  /// Clean up resources when controller is disposed
  @override
  void onClose() {
    // Cancel subscriptions and timers
    _cancelStabilityTimer();
    _frameSubscription?.cancel();

    // Dispose camera service
    _cameraService.dispose();

    super.onClose();
  }
}
