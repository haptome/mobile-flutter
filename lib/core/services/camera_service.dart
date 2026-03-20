// Purpose: Core service for managing camera lifecycle and frame streaming
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 3.1 - Camera Service

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

/// Core service for managing camera lifecycle and frame streaming
///
/// This service handles:
/// - Camera initialization with configurable resolution
/// - Real-time frame streaming for detection
/// - Picture capture
/// - FPS tracking for adaptive processing
/// - Proper resource disposal
///
/// Example usage:
/// ```dart
/// final cameraService = CameraService();
/// await cameraService.initialize(
///   direction: CameraLensDirection.back,
///   resolution: ResolutionPreset.medium,
/// );
///
/// // Listen to frame stream
/// cameraService.frameStream.listen((frame) {
///   // Process frame for detection
/// });
///
/// // Capture image
/// final image = await cameraService.takePicture();
///
/// // Dispose when done
/// cameraService.dispose();
/// ```
class CameraService extends GetxService {
  /// Camera controller instance
  CameraController? _controller;

  /// Stream controller for camera frames
  StreamController<CameraImage>? _frameStreamController;

  /// FPS tracking variables
  int _frameCount = 0;
  DateTime? _lastFpsCheck;
  double _currentFps = 0.0;

  /// Timer for FPS calculation
  Timer? _fpsTimer;

  /// Get the camera controller
  CameraController? get controller => _controller;

  /// Get current FPS
  double get currentFps => _currentFps;

  /// Check if camera is initialized
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Get frame stream for real-time processing
  Stream<CameraImage> get frameStream {
    _frameStreamController ??= StreamController<CameraImage>.broadcast();
    return _frameStreamController!.stream;
  }

  /// Initialize camera with specified configuration
  ///
  /// [direction] - Camera lens direction (front or back)
  /// [resolution] - Resolution preset (use medium for performance)
  /// [enableAudio] - Whether to enable audio (default: false)
  ///
  /// Throws exception if camera initialization fails
  Future<void> initialize({
    required CameraLensDirection direction,
    ResolutionPreset resolution = ResolutionPreset.medium,
    bool enableAudio = false,
  }) async {
    try {
      // Dispose any existing controller first
      if (_controller != null) {
        dispose();
        // Longer delay to ensure camera is fully released (especially on Android)
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Get available cameras
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Find camera with specified direction
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == direction,
        orElse: () => cameras.first,
      );

      print('[CameraService] Initializing camera: ${camera.name}, direction: ${camera.lensDirection}');

      // Create camera controller
      _controller = CameraController(
        camera,
        resolution,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.yuv420, // For frame processing
      );

      // Initialize controller
      await _controller!.initialize();
      
      print('[CameraService] Camera initialized successfully: ${_controller!.value.isInitialized}');

      // Start frame streaming
      _startFrameStreaming();

      // Start FPS tracking
      _startFpsTracking();
    } catch (e) {
      print('[CameraService] Error initializing camera: $e');
      throw Exception('Failed to initialize camera: $e');
    }
  }

  /// Start streaming camera frames
  void _startFrameStreaming() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    _frameStreamController ??= StreamController<CameraImage>.broadcast();

    _controller!.startImageStream((CameraImage image) {
      // Track frame count for FPS calculation
      _frameCount++;

      // Add frame to stream if there are listeners
      if (_frameStreamController != null && 
          !_frameStreamController!.isClosed &&
          _frameStreamController!.hasListener) {
        _frameStreamController!.add(image);
      }
    });
  }

  /// Start FPS tracking
  void _startFpsTracking() {
    _lastFpsCheck = DateTime.now();
    _frameCount = 0;

    // Calculate FPS every second
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (_lastFpsCheck != null) {
        final elapsed = now.difference(_lastFpsCheck!).inMilliseconds / 1000.0;
        if (elapsed > 0) {
          _currentFps = _frameCount / elapsed;
        }
      }
      _lastFpsCheck = now;
      _frameCount = 0;
    });
  }

  /// Stop frame streaming
  Future<void> stopFrameStreaming() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  /// Take a picture
  ///
  /// Returns [XFile] containing the captured image
  ///
  /// Throws exception if camera is not initialized or capture fails
  Future<XFile> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera is not initialized');
    }

    // Stop image streaming before taking picture
    final wasStreaming = _controller!.value.isStreamingImages;
    if (wasStreaming) {
      await stopFrameStreaming();
    }

    try {
      // Capture image
      final image = await _controller!.takePicture();

      // Resume streaming if it was active
      if (wasStreaming) {
        _startFrameStreaming();
      }

      return image;
    } catch (e) {
      // Resume streaming even if capture failed
      if (wasStreaming) {
        _startFrameStreaming();
      }
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Dispose camera resources
  @override
  void onClose() {
    dispose();
    super.onClose();
  }

  /// Dispose camera and clean up resources
  void dispose() {
    // Stop FPS timer
    _fpsTimer?.cancel();
    _fpsTimer = null;

    // Close frame stream
    _frameStreamController?.close();
    _frameStreamController = null;

    // Dispose camera controller
    _controller?.dispose();
    _controller = null;

    // Reset tracking variables
    _frameCount = 0;
    _lastFpsCheck = null;
    _currentFps = 0.0;
  }
}
