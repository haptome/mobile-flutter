// Purpose: Utility class for adaptive frame processing based on FPS
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 7.1 - Performance Optimizations

/// Utility class for adaptive frame processing
///
/// This class helps optimize frame processing by dynamically adjusting
/// the frame skip interval based on current FPS to maintain performance
/// on low-end devices.
///
/// Strategy:
/// - High-end devices (>25 FPS): Process every frame
/// - Mid-range devices (15-25 FPS): Process every 2nd frame
/// - Low-end devices (<15 FPS): Process every 3rd frame
///
/// Example usage:
/// ```dart
/// final processor = AdaptiveFrameProcessor();
///
/// cameraService.frameStream.listen((frame) {
///   if (processor.shouldProcessFrame(cameraService.currentFps)) {
///     // Process this frame
///     processFrame(frame);
///   }
/// });
/// ```
class AdaptiveFrameProcessor {
  /// Current frame count
  int _frameCount = 0;

  /// Current skip interval (how many frames to skip)
  int _skipInterval = 1;

  /// Get current skip interval
  int get skipInterval => _skipInterval;

  /// Get current frame count
  int get frameCount => _frameCount;

  /// Determine if the current frame should be processed
  ///
  /// [currentFPS] - Current frames per second from camera
  ///
  /// Returns true if this frame should be processed, false if it should be skipped
  ///
  /// The skip interval is automatically adjusted based on FPS:
  /// - FPS > 25: Process every frame (interval = 1)
  /// - FPS 15-25: Process every 2nd frame (interval = 2)
  /// - FPS < 15: Process every 3rd frame (interval = 3)
  bool shouldProcessFrame(double currentFPS) {
    _frameCount++;

    // Adjust skip interval based on FPS
    if (currentFPS > 25) {
      _skipInterval = 1; // Process every frame
    } else if (currentFPS > 15) {
      _skipInterval = 2; // Process every 2nd frame
    } else {
      _skipInterval = 3; // Process every 3rd frame
    }

    // Check if this frame should be processed
    return _frameCount % _skipInterval == 0;
  }

  /// Reset the frame counter
  ///
  /// Useful when starting a new capture session or changing camera modes
  void reset() {
    _frameCount = 0;
    _skipInterval = 1;
  }
}
