// Purpose: Face detection service using Google ML Kit for liveness verification
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 3.4 - Face Detection Service

import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:get/get.dart';
import '../../../models/detection_result.dart';

/// Service for detecting faces using Google ML Kit
///
/// This service handles:
/// - Face detection using ML Kit
/// - Eye open probability extraction for blink detection
/// - Head orientation (Euler angles) extraction for head turn detection
/// - Conversion of camera frames to ML Kit input format
///
/// Configuration:
/// - Classification enabled for eye open probability
/// - Tracking enabled for consistent face identification
/// - Fast performance mode for real-time processing
///
/// Example usage:
/// ```dart
/// final faceService = FaceDetectionService();
/// await faceService.initialize();
///
/// // Process camera frame
/// final result = await faceService.detectFace(cameraImage);
/// if (result != null) {
///   print('Face detected at: ${result.faceBounds}');
///   print('Left eye open: ${result.leftEyeOpenProbability}');
///   print('Head yaw: ${result.headEulerAngleY}');
/// }
///
/// // Dispose when done
/// faceService.dispose();
/// ```
class FaceDetectionService extends GetxService {
  /// ML Kit face detector instance
  FaceDetector? _detector;

  /// Check if service is initialized
  bool get isInitialized => _detector != null;

  /// Initialize the face detector with ML Kit options
  ///
  /// Configures the detector with:
  /// - Classification enabled for eye open probability
  /// - Tracking enabled for consistent face identification
  /// - Fast performance mode for real-time processing
  /// - Landmarks disabled (not needed for liveness)
  Future<void> initialize() async {
    try {
      // Configure face detector options
      final options = FaceDetectorOptions(
        enableClassification: true, // Required for eye open probability
        enableTracking: true, // Track faces across frames
        enableLandmarks: false, // Not needed for liveness
        performanceMode: FaceDetectorMode.fast, // Fast mode for real-time
        minFaceSize: 0.15, // Minimum face size (15% of image)
      );

      // Create face detector
      _detector = FaceDetector(options: options);
    } catch (e) {
      throw Exception('Failed to initialize face detector: $e');
    }
  }

  /// Detect face in camera image
  ///
  /// Converts the camera image to ML Kit InputImage format,
  /// processes face detection, and extracts relevant features.
  ///
  /// Returns [FaceDetectionResult] if a face is detected, null otherwise.
  ///
  /// [image] - Camera image from frame stream
  Future<FaceDetectionResult?> detectFace(CameraImage image) async {
    if (_detector == null) {
      throw Exception('Face detector not initialized. Call initialize() first.');
    }

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) {
        return null;
      }

      // Process face detection
      final faces = await _detector!.processImage(inputImage);

      // Return null if no faces detected
      if (faces.isEmpty) {
        return null;
      }

      // Use the first detected face (largest/most prominent)
      final face = faces.first;

      // Extract eye open probabilities
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0.5;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0.5;

      // Extract Euler angles for head orientation
      // headEulerAngleY: yaw (left/right rotation)
      // headEulerAngleZ: pitch (up/down rotation)
      final yaw = face.headEulerAngleY ?? 0.0;
      final pitch = face.headEulerAngleZ ?? 0.0;

      // Determine if face is frontal (within ±10 degrees)
      final isFrontal = yaw.abs() <= 10 && pitch.abs() <= 10;

      // Create face detection result
      return FaceDetectionResult(
        faceBounds: face.boundingBox,
        leftEyeOpenProbability: leftEyeOpen,
        rightEyeOpenProbability: rightEyeOpen,
        headEulerAngleY: yaw,
        headEulerAngleZ: pitch,
        isFrontal: isFrontal,
      );
    } catch (e) {
      // Log error but don't throw - return null to indicate no detection
      print('Error detecting face: $e');
      return null;
    }
  }

  /// Convert CameraImage to InputImage format for ML Kit
  ///
  /// Handles YUV420 format conversion and image metadata setup.
  ///
  /// Returns [InputImage] if conversion succeeds, null otherwise.
  ///
  /// [cameraImage] - Camera image from frame stream
  InputImage? _convertToInputImage(CameraImage cameraImage) {
    try {
      // Get image format
      final format = _getInputImageFormat(cameraImage.format.group);
      if (format == null) {
        print('Unsupported image format: ${cameraImage.format.group}');
        return null;
      }

      // Create input image metadata
      final metadata = InputImageMetadata(
        size: Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        ),
        rotation: InputImageRotation.rotation0deg, // Adjust if needed
        format: format,
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      );

      // Create InputImage from bytes
      final bytes = _concatenatePlanes(cameraImage.planes);
      
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  /// Get ML Kit input image format from camera format group
  ///
  /// [formatGroup] - Camera image format group
  ///
  /// Returns corresponding [InputImageFormat] or null if unsupported
  InputImageFormat? _getInputImageFormat(ImageFormatGroup formatGroup) {
    switch (formatGroup) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return null;
    }
  }

  /// Concatenate image planes into a single byte array
  ///
  /// Required for ML Kit InputImage creation from bytes.
  ///
  /// [planes] - List of image planes from CameraImage
  ///
  /// Returns concatenated bytes
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = <int>[];
    for (final plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  /// Dispose face detector and clean up resources
  @override
  void onClose() {
    dispose();
    super.onClose();
  }

  /// Dispose face detector
  void dispose() {
    _detector?.close();
    _detector = null;
  }
}
