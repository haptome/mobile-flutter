// Purpose: Controller for orchestrating liveness check flow
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 4.2 - Liveness Controller

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../core/services/camera_service.dart';
import '../core/services/face_detection_service.dart';
import '../core/services/liveness_detection_service.dart';
import '../core/utils/adaptive_frame_processor.dart';
import '../models/liveness_challenge.dart';
import '../models/detection_result.dart';

/// Enum representing the current state of the liveness check flow
enum LivenessState {
  /// Initial state before starting
  idle,

  /// Waiting for user to align their face in the frame
  aligningFace,

  /// Performing passive liveness check (face stability)
  passiveLiveness,

  /// Performing active challenge (blink, head turn, etc.)
  activeChallenge,

  /// Liveness check completed successfully
  success,

  /// Session timed out
  timeout,

  /// Error occurred during liveness check
  error,
}

/// Controller for orchestrating the liveness check flow
///
/// This controller manages:
/// - Camera initialization and frame streaming
/// - Face detection and tracking
/// - Passive liveness validation (face stability)
/// - Active challenge generation and monitoring
/// - Session timeout management
/// - State management with reactive updates
///
/// Flow:
/// 1. Initialize camera and services
/// 2. Detect and align face
/// 3. Validate passive liveness (2-3s stability)
/// 4. Generate random challenge
/// 5. Monitor for challenge completion
/// 6. Capture liveness image on success
class LivenessController extends GetxController {
  /// Camera service for frame streaming
  final CameraService _cameraService;

  /// Face detection service
  final FaceDetectionService _faceService;

  /// Liveness detection service
  final LivenessDetectionService _livenessService;

  /// Adaptive frame processor for performance optimization
  final AdaptiveFrameProcessor _frameProcessor;

  /// Current state of the liveness check
  final state = LivenessState.idle.obs;

  /// Current active challenge (null during passive liveness)
  final currentChallenge = Rx<LivenessChallenge?>(null);

  /// Whether a face is currently detected
  final faceDetected = false.obs;

  /// Current instruction text for the user
  final instructionText = ''.obs;

  /// Progress percentage (0.0 to 1.0)
  final progress = 0.0.obs;

  /// Error message (if any)
  final errorMessage = ''.obs;

  /// Recent face detection results for temporal analysis
  final List<FaceDetectionResult> _recentFrames = [];

  /// Subscription to camera frame stream
  StreamSubscription<CameraImage>? _frameSubscription;

  /// Session timeout timer (60 seconds)
  Timer? _sessionTimer;

  /// Passive liveness start time
  DateTime? _passiveLivenessStartTime;

  /// Challenge start time
  DateTime? _challengeStartTime;

  /// Captured liveness image
  XFile? capturedImage;

  /// Session timeout duration
  static const Duration _sessionTimeout = Duration(seconds: 60);

  /// Passive liveness required duration
  static const Duration _passiveLivenessDuration = Duration(seconds: 2);

  /// Maximum frames to keep in history
  static const int _maxFrameHistory = 30;

  /// Constructor with dependency injection
  LivenessController({
    CameraService? cameraService,
    FaceDetectionService? faceService,
    LivenessDetectionService? livenessService,
    AdaptiveFrameProcessor? frameProcessor,
  })  : _cameraService = cameraService ?? Get.find<CameraService>(),
        _faceService = faceService ?? Get.find<FaceDetectionService>(),
        _livenessService = livenessService ?? Get.find<LivenessDetectionService>(),
        _frameProcessor = frameProcessor ?? AdaptiveFrameProcessor();

  /// Get the camera controller for UI rendering
  CameraController? get cameraController => _cameraService.controller;

  /// Start the liveness check flow
  Future<void> startLivenessCheck() async {
    try {
      print('[LivenessController] Starting liveness check...');
      _reset();
      state.value = LivenessState.aligningFace;
      instructionText.value = 'Position your face in the frame';
      progress.value = 0.0;

      print('[LivenessController] Initializing camera...');
      await _cameraService.initialize(
        direction: CameraLensDirection.front,
        resolution: ResolutionPreset.medium,
      );
      print('[LivenessController] Camera initialized successfully');
      print('[LivenessController] Camera controller initialized: ${_cameraService.controller?.value.isInitialized}');

      print('[LivenessController] Initializing face detection service...');
      await _faceService.initialize();
      print('[LivenessController] Face detection service initialized');
      
      _startSessionTimer();
      _startFrameProcessing();
      print('[LivenessController] Liveness check started successfully');
      
      // Force UI update
      update();
    } catch (e) {
      print('[LivenessController] Error starting liveness check: $e');
      _handleError('Failed to start liveness check: $e');
    }
  }

  /// Start processing camera frames
  void _startFrameProcessing() {
    _frameSubscription = _cameraService.frameStream.listen(
      _processFrame,
      onError: (error) {
        _handleError('Frame processing error: $error');
      },
    );
  }

  /// Process a single camera frame
  Future<void> _processFrame(CameraImage image) async {
    if (!_frameProcessor.shouldProcessFrame(_cameraService.currentFps)) {
      return;
    }

    try {
      final faceResult = await _faceService.detectFace(image);
      faceDetected.value = faceResult != null;

      if (faceResult == null) {
        _handleNoFaceDetected();
        return;
      }

      _livenessService.addFrame(faceResult);
      _recentFrames.add(faceResult);
      if (_recentFrames.length > _maxFrameHistory) {
        _recentFrames.removeAt(0);
      }

      print('[LivenessController] Frame processed - state: ${state.value}, faceDetected: true');

      switch (state.value) {
        case LivenessState.aligningFace:
          _processAligningFace(faceResult);
          break;
        case LivenessState.passiveLiveness:
          _processPassiveLiveness(faceResult);
          break;
        case LivenessState.activeChallenge:
          _processActiveChallenge(faceResult);
          break;
        case LivenessState.idle:
        case LivenessState.success:
        case LivenessState.timeout:
        case LivenessState.error:
          break;
      }
    } catch (e) {
      print('Error processing frame: $e');
    }
  }

  /// Handle case when no face is detected
  void _handleNoFaceDetected() {
    if (state.value == LivenessState.aligningFace) {
      instructionText.value = 'Position your face in the frame';
    } else if (state.value == LivenessState.passiveLiveness ||
        state.value == LivenessState.activeChallenge) {
      state.value = LivenessState.aligningFace;
      instructionText.value = 'Position your face in the frame';
      _passiveLivenessStartTime = null;
      _challengeStartTime = null;
      progress.value = 0.0;
    }
  }

  /// Process frame during face alignment phase
  void _processAligningFace(FaceDetectionResult faceResult) {
    print('[LivenessController] Processing aligning face - isFrontal: ${faceResult.isFrontal}, isSuitable: ${faceResult.isSuitableForLiveness}');
    
    if (faceResult.isFrontal && faceResult.isSuitableForLiveness) {
      print('[LivenessController] Face aligned! Moving to passive liveness');
      state.value = LivenessState.passiveLiveness;
      instructionText.value = 'Hold still';
      _passiveLivenessStartTime = DateTime.now();
      progress.value = 0.2;
    } else {
      instructionText.value = 'Look straight at the camera';
    }
  }

  /// Process frame during passive liveness phase
  void _processPassiveLiveness(FaceDetectionResult faceResult) {
    final isStable = _livenessService.validateStability(_passiveLivenessDuration);
    
    print('[LivenessController] Passive liveness - isStable: $isStable, frameCount: ${_livenessService.frameCount}');

    if (isStable) {
      print('[LivenessController] Passive liveness validated! Generating challenge');
      _generateChallenge();
      state.value = LivenessState.activeChallenge;
      _challengeStartTime = DateTime.now();
      progress.value = 0.5;
    } else {
      if (_passiveLivenessStartTime != null) {
        final elapsed = DateTime.now().difference(_passiveLivenessStartTime!);
        final progressPercent = elapsed.inMilliseconds / 
            _passiveLivenessDuration.inMilliseconds;
        progress.value = 0.2 + (progressPercent * 0.3).clamp(0.0, 0.3);
      }

      if (!faceResult.isFrontal) {
        instructionText.value = 'Look straight at the camera';
      } else {
        instructionText.value = 'Hold still';
      }
    }
  }

  /// Process frame during active challenge phase
  void _processActiveChallenge(FaceDetectionResult faceResult) {
    if (currentChallenge.value == null) {
      return;
    }

    final challenge = currentChallenge.value!;
    bool challengeCompleted = false;

    print('[LivenessController] Processing challenge: ${challenge.type}');

    if (challenge.isBlinkChallenge()) {
      challengeCompleted = _checkBlinkChallenge(challenge);
      print('[LivenessController] Blink challenge completed: $challengeCompleted');
    } else if (challenge.isHeadMovement()) {
      challengeCompleted = _checkHeadMovementChallenge(challenge, faceResult);
      print('[LivenessController] Head movement challenge completed: $challengeCompleted');
    }

    if (challengeCompleted) {
      print('[LivenessController] Challenge completed successfully!');
      _handleChallengeSuccess();
    } else {
      if (_challengeStartTime != null) {
        final elapsed = DateTime.now().difference(_challengeStartTime!);
        final progressPercent = elapsed.inMilliseconds / 
            challenge.timeout.inMilliseconds;
        progress.value = 0.5 + (progressPercent * 0.5).clamp(0.0, 0.5);

        if (elapsed > challenge.timeout) {
          _handleError('Challenge timeout. Please try again.');
        }
      }
    }
  }

  /// Check if blink challenge is completed
  bool _checkBlinkChallenge(LivenessChallenge challenge) {
    if (challenge.type == ChallengeType.blinkOnce) {
      return _livenessService.detectBlink();
    } else if (challenge.type == ChallengeType.blinkTwice) {
      return _livenessService.detectDoubleBlink();
    }
    return false;
  }

  /// Check if head movement challenge is completed
  bool _checkHeadMovementChallenge(
    LivenessChallenge challenge,
    FaceDetectionResult faceResult,
  ) {
    final targetAngle = challenge.getTargetAngle();
    if (targetAngle == null) {
      return false;
    }

    if (challenge.usesYaw()) {
      return _livenessService.detectHeadTurn(
        faceResult,
        targetAngle,
        isYaw: true,
      );
    } else if (challenge.usesPitch()) {
      return _livenessService.detectLookUpDown(
        faceResult,
        targetAngle,
      );
    }

    return false;
  }

  /// Generate a random challenge
  void _generateChallenge() {
    currentChallenge.value = LivenessChallenge.random();
    instructionText.value = currentChallenge.value!.instruction;
  }

  /// Handle successful challenge completion
  Future<void> _handleChallengeSuccess() async {
    try {
      await _frameSubscription?.cancel();
      _frameSubscription = null;

      capturedImage = await _cameraService.takePicture();

      state.value = LivenessState.success;
      instructionText.value = 'Verification complete!';
      progress.value = 1.0;

      _sessionTimer?.cancel();
    } catch (e) {
      _handleError('Failed to capture liveness image: $e');
    }
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer = Timer(_sessionTimeout, () {
      if (state.value != LivenessState.success) {
        state.value = LivenessState.timeout;
        instructionText.value = 'Session timed out. Please try again.';
        errorMessage.value = 'Session timed out';
        _cleanup();
      }
    });
  }

  /// Handle error
  void _handleError(String message) {
    state.value = LivenessState.error;
    errorMessage.value = message;
    instructionText.value = 'An error occurred';
    _cleanup();
  }

  /// Reset controller state
  void _reset() {
    state.value = LivenessState.idle;
    currentChallenge.value = null;
    faceDetected.value = false;
    instructionText.value = '';
    progress.value = 0.0;
    errorMessage.value = '';
    capturedImage = null;
    _recentFrames.clear();
    _passiveLivenessStartTime = null;
    _challengeStartTime = null;
    _livenessService.reset();
  }

  /// Clean up resources
  void _cleanup() {
    _frameSubscription?.cancel();
    _frameSubscription = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// Retry liveness check after error or timeout
  Future<void> retry() async {
    _cleanup();
    await startLivenessCheck();
  }

  /// Cancel liveness check
  void cancel() {
    _cleanup();
    state.value = LivenessState.idle;
  }

  @override
  void onClose() {
    _cleanup();
    _cameraService.dispose();
    _faceService.dispose();
    _livenessService.reset();
    super.onClose();
  }
}
