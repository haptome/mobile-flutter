// Purpose: Liveness detection service for blink and head movement detection
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 3.5 - Liveness Detection Service

import 'dart:collection';
import 'dart:ui';
import 'package:get/get.dart';
import '../../../models/detection_result.dart';

/// Service for detecting liveness through blinks and head movements
///
/// This service handles:
/// - Single and double blink detection using eye open probabilities
/// - Head turn detection (left/right) using yaw angles
/// - Look up/down detection using pitch angles
/// - Passive liveness validation through face stability
/// - Temporal smoothing for reliable signal detection
///
/// Detection Thresholds:
/// - Eye open: probability > 0.7
/// - Eye closed: probability < 0.3
/// - Neutral pose: yaw/pitch ±10°
/// - Head turn target: yaw ±30°
/// - Look up/down target: pitch ±20°
///
/// Example usage:
/// ```dart
/// final livenessService = LivenessDetectionService();
///
/// // Detect single blink
/// livenessService.addFrame(faceResult);
/// if (livenessService.detectBlink()) {
///   print('Blink detected!');
/// }
///
/// // Detect head turn
/// if (livenessService.detectHeadTurn(faceResult, -30, isYaw: true)) {
///   print('Head turned left!');
/// }
///
/// // Validate passive liveness
/// if (livenessService.validateStability(Duration(seconds: 2))) {
///   print('Face is stable!');
/// }
/// ```
class LivenessDetectionService extends GetxService {
  /// Maximum number of frames to keep in history
  static const int _maxFrameHistory = 30;

  /// Frame window size for blink detection
  static const int _blinkFrameWindow = 10;

  /// Minimum frames required for stability check
  static const int _minStabilityFrames = 20;

  /// Neutral pose angle threshold (degrees)
  static const double _neutralPoseThreshold = 10.0;

  /// Angle tolerance for target detection (degrees)
  static const double _angleTolerance = 5.0;

  /// Hold duration for head movement validation (milliseconds)
  static const int _holdDurationMs = 300;

  /// Maximum time between blinks for double blink (milliseconds)
  static const int _doubleBinkMaxGapMs = 2000;

  /// Recent face detection frames
  final Queue<_TimestampedFrame> _frameHistory = Queue();

  /// Temporal smoother for yaw angle
  final _yawSmoother = TemporalSmoother(5);

  /// Temporal smoother for pitch angle
  final _pitchSmoother = TemporalSmoother(5);

  /// Temporal smoother for eye open probability
  final _eyeSmoother = TemporalSmoother(5);

  /// Blink count for double blink detection
  int _blinkCount = 0;

  /// Timer for resetting blink count
  DateTime? _blinkCountResetTime;

  /// Add a face detection frame to the history
  ///
  /// This method should be called for each processed frame.
  /// Frames are stored with timestamps for temporal analysis.
  ///
  /// [frame] - Face detection result from current frame
  void addFrame(FaceDetectionResult frame) {
    final timestampedFrame = _TimestampedFrame(
      frame: frame,
      timestamp: DateTime.now(),
    );

    _frameHistory.add(timestampedFrame);

    // Limit frame history size
    while (_frameHistory.length > _maxFrameHistory) {
      _frameHistory.removeFirst();
    }

    // Add smoothed values
    _yawSmoother.addValue(frame.headEulerAngleY);
    _pitchSmoother.addValue(frame.headEulerAngleZ);
    _eyeSmoother.addValue(frame.averageEyeOpenProbability);
  }

  /// Detect a single blink in recent frames
  ///
  /// A blink is detected when:
  /// 1. Eyes transition from open (>0.7) to closed (<0.3) to open (>0.7)
  /// 2. Both eyes close simultaneously
  /// 3. Transition occurs within the frame window
  ///
  /// Returns true if a blink is detected, false otherwise.
  ///
  /// [frameWindow] - Number of recent frames to analyze (default: 10)
  bool detectBlink({int frameWindow = _blinkFrameWindow}) {
    if (_frameHistory.length < frameWindow) {
      return false;
    }

    // Get recent frames
    final recentFrames = _frameHistory.toList().sublist(
          _frameHistory.length - frameWindow,
        );

    // Track eye state transitions: open -> closed -> open
    bool wasOpen = false;
    bool wasClosed = false;
    bool isOpenAgain = false;

    for (final timestampedFrame in recentFrames) {
      final frame = timestampedFrame.frame;

      // Check if both eyes are open
      if (frame.bothEyesOpen) {
        if (!wasOpen) {
          wasOpen = true;
        } else if (wasClosed) {
          isOpenAgain = true;
          break;
        }
      }

      // Check if both eyes are closed
      if (frame.bothEyesClosed && wasOpen) {
        wasClosed = true;
      }
    }

    // Blink detected if we saw the complete transition
    return wasOpen && wasClosed && isOpenAgain;
  }

  /// Detect a double blink (two blinks in quick succession)
  ///
  /// A double blink is detected when:
  /// 1. Two single blinks are detected
  /// 2. The blinks occur within 2 seconds of each other
  ///
  /// Returns true if a double blink is detected, false otherwise.
  ///
  /// [frameWindow] - Number of recent frames to analyze for each blink
  bool detectDoubleBlink({int frameWindow = _blinkFrameWindow}) {
    final now = DateTime.now();

    // Reset blink count if too much time has passed
    if (_blinkCountResetTime != null &&
        now.difference(_blinkCountResetTime!).inMilliseconds >
            _doubleBinkMaxGapMs) {
      _blinkCount = 0;
      _blinkCountResetTime = null;
    }

    // Detect single blink
    if (detectBlink(frameWindow: frameWindow)) {
      _blinkCount++;
      _blinkCountResetTime = now;

      // Check if we have two blinks
      if (_blinkCount >= 2) {
        // Reset for next detection
        _blinkCount = 0;
        _blinkCountResetTime = null;
        return true;
      }
    }

    return false;
  }

  /// Detect head turn (left or right)
  ///
  /// A head turn is detected when:
  /// 1. Head starts from neutral pose (yaw ±10°)
  /// 2. Head reaches target angle (±30° for turns)
  /// 3. Head holds the position briefly (300ms)
  ///
  /// [current] - Current face detection result
  /// [targetAngle] - Target yaw angle (negative for left, positive for right)
  /// [isYaw] - Whether to use yaw (true) or pitch (false) angle
  ///
  /// Returns true if head turn is detected, false otherwise.
  bool detectHeadTurn(
    FaceDetectionResult current,
    double targetAngle, {
    required bool isYaw,
  }) {
    if (_frameHistory.isEmpty) {
      return false;
    }

    // Get smoothed angle
    final currentAngle = isYaw
        ? _yawSmoother.currentValue
        : _pitchSmoother.currentValue;

    // Check if target angle is reached (with tolerance)
    final targetReached = (currentAngle - targetAngle).abs() <= _angleTolerance;

    if (!targetReached) {
      return false;
    }

    // Validate that head was in neutral pose recently
    final hasNeutralPose = _hasRecentNeutralPose(isYaw: isYaw);

    if (!hasNeutralPose) {
      return false;
    }

    // Validate hold duration
    final holdDuration = _validateHoldDuration(
      targetAngle,
      isYaw: isYaw,
    );

    return holdDuration;
  }

  /// Detect look up or down movement
  ///
  /// A look up/down is detected when:
  /// 1. Head starts from neutral pose (pitch ±10°)
  /// 2. Head reaches target angle (±20° for up/down)
  /// 3. Head holds the position briefly (300ms)
  ///
  /// [current] - Current face detection result
  /// [targetAngle] - Target pitch angle (negative for up, positive for down)
  ///
  /// Returns true if look up/down is detected, false otherwise.
  bool detectLookUpDown(
    FaceDetectionResult current,
    double targetAngle,
  ) {
    return detectHeadTurn(
      current,
      targetAngle,
      isYaw: false,
    );
  }

  /// Validate passive liveness through face stability
  ///
  /// Passive liveness is validated when:
  /// 1. Face is detected continuously for the specified duration
  /// 2. Face position remains relatively stable
  /// 3. Micro-movements are detected (not a static image)
  ///
  /// [duration] - Required stability duration
  ///
  /// Returns true if passive liveness is validated, false otherwise.
  bool validateStability(Duration duration) {
    if (_frameHistory.length < _minStabilityFrames) {
      return false;
    }

    final now = DateTime.now();
    final requiredStartTime = now.subtract(duration);

    // Get frames within the duration window
    final stableFrames = _frameHistory.where((timestampedFrame) {
      return timestampedFrame.timestamp.isAfter(requiredStartTime);
    }).toList();

    // Check if we have enough frames for the duration
    if (stableFrames.length < _minStabilityFrames) {
      return false;
    }

    // Calculate face position variance to detect stability
    final positions = stableFrames.map((tf) => tf.frame.center).toList();
    final variance = _calculatePositionVariance(positions);

    // Face should be stable but not completely static
    // Variance should be low but not zero (to detect micro-movements)
    const minVariance = 5.0; // Minimum movement to prove not static
    const maxVariance = 50.0; // Maximum movement to prove stability

    final isStable = variance >= minVariance && variance <= maxVariance;

    return isStable;
  }

  /// Check if there was a recent neutral pose
  ///
  /// [isYaw] - Whether to check yaw (true) or pitch (false) angle
  ///
  /// Returns true if neutral pose was detected recently, false otherwise.
  bool _hasRecentNeutralPose({required bool isYaw}) {
    // Check last 15 frames for neutral pose
    final recentFrames = _frameHistory.length > 15
        ? _frameHistory.toList().sublist(_frameHistory.length - 15)
        : _frameHistory.toList();

    for (final timestampedFrame in recentFrames) {
      final frame = timestampedFrame.frame;
      final angle = isYaw ? frame.headEulerAngleY : frame.headEulerAngleZ;

      if (angle.abs() <= _neutralPoseThreshold) {
        return true;
      }
    }

    return false;
  }

  /// Validate that the target angle is held for the required duration
  ///
  /// [targetAngle] - Target angle to validate
  /// [isYaw] - Whether to check yaw (true) or pitch (false) angle
  ///
  /// Returns true if hold duration is met, false otherwise.
  bool _validateHoldDuration(
    double targetAngle, {
    required bool isYaw,
  }) {
    if (_frameHistory.length < 5) {
      return false;
    }

    // Get last 5 frames
    final recentFrames = _frameHistory.toList().sublist(
          _frameHistory.length - 5,
        );

    // Check if all recent frames are at target angle
    for (final timestampedFrame in recentFrames) {
      final frame = timestampedFrame.frame;
      final angle = isYaw ? frame.headEulerAngleY : frame.headEulerAngleZ;

      if ((angle - targetAngle).abs() > _angleTolerance) {
        return false;
      }
    }

    // Check time span of recent frames
    final firstTimestamp = recentFrames.first.timestamp;
    final lastTimestamp = recentFrames.last.timestamp;
    final duration = lastTimestamp.difference(firstTimestamp).inMilliseconds;

    return duration >= _holdDurationMs;
  }

  /// Calculate position variance for stability detection
  ///
  /// [positions] - List of face center positions
  ///
  /// Returns variance value
  double _calculatePositionVariance(List<Offset> positions) {
    if (positions.isEmpty) {
      return 0.0;
    }

    // Calculate mean position
    final meanX = positions.fold<double>(
          0,
          (sum, pos) => sum + pos.dx,
        ) /
        positions.length;
    final meanY = positions.fold<double>(
          0,
          (sum, pos) => sum + pos.dy,
        ) /
        positions.length;

    // Calculate variance
    final variance = positions.fold<double>(
      0,
      (sum, pos) {
        final dx = pos.dx - meanX;
        final dy = pos.dy - meanY;
        return sum + (dx * dx + dy * dy);
      },
    ) / positions.length;

    return variance;
  }

  /// Clear frame history and reset state
  void reset() {
    _frameHistory.clear();
    _yawSmoother.reset();
    _pitchSmoother.reset();
    _eyeSmoother.reset();
    _blinkCount = 0;
    _blinkCountResetTime = null;
  }

  /// Get the number of frames in history
  int get frameCount => _frameHistory.length;

  /// Get the smoothed yaw angle
  double get smoothedYaw => _yawSmoother.currentValue;

  /// Get the smoothed pitch angle
  double get smoothedPitch => _pitchSmoother.currentValue;

  /// Get the smoothed eye open probability
  double get smoothedEyeOpen => _eyeSmoother.currentValue;

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}

/// Temporal smoother for signal smoothing
///
/// Uses a sliding window average to smooth noisy signals
/// from face detection (angles, probabilities, etc.)
///
/// Example usage:
/// ```dart
/// final smoother = TemporalSmoother(5);
/// smoother.addValue(10.5);
/// smoother.addValue(11.2);
/// print(smoother.currentValue); // Average of recent values
/// ```
class TemporalSmoother {
  /// Window size for averaging
  final int windowSize;

  /// Queue of recent values
  final Queue<double> _values = Queue();

  /// Create a temporal smoother with specified window size
  ///
  /// [windowSize] - Number of values to average
  TemporalSmoother(this.windowSize);

  /// Add a new value to the smoother
  ///
  /// [value] - New value to add
  ///
  /// Returns the smoothed value (average of recent values)
  double addValue(double value) {
    _values.add(value);

    // Limit window size
    while (_values.length > windowSize) {
      _values.removeFirst();
    }

    return currentValue;
  }

  /// Get the current smoothed value (average)
  double get currentValue {
    if (_values.isEmpty) {
      return 0.0;
    }

    final sum = _values.fold<double>(0, (sum, value) => sum + value);
    return sum / _values.length;
  }

  /// Reset the smoother
  void reset() {
    _values.clear();
  }

  /// Get the number of values in the window
  int get valueCount => _values.length;
}

/// Internal class to store face detection frames with timestamps
class _TimestampedFrame {
  final FaceDetectionResult frame;
  final DateTime timestamp;

  _TimestampedFrame({
    required this.frame,
    required this.timestamp,
  });
}
