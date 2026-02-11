// Purpose: Image quality validation service for KYC document capture
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 3.3 - Image Quality Service

import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../models/quality_check_result.dart';

/// Service for validating image quality before acceptance
///
/// This service performs three quality checks on captured images:
/// 1. Blur detection using Laplacian variance
/// 2. Glare detection by analyzing bright pixel percentage
/// 3. Lighting validation by checking mean brightness
///
/// All checks run on a background isolate to avoid UI jank.
///
/// Quality Thresholds:
/// - Blur: Laplacian variance > 100
/// - Glare: Bright pixels (>240) < 15% of image
/// - Brightness: Mean luminance 60-200
///
/// Example usage:
/// ```dart
/// final qualityService = ImageQualityService();
///
/// final imageFile = await cameraController.takePicture();
/// final result = await qualityService.checkQuality(imageFile);
///
/// if (result.passed) {
///   // Image quality is acceptable
/// } else {
///   // Show error: result.failedChecks
/// }
/// ```
class ImageQualityService {
  /// Blur detection threshold (Laplacian variance)
  /// Images with variance below this are considered blurry
  static const double _blurThreshold = 100.0;

  /// Glare detection threshold (percentage of bright pixels)
  /// Images with more than this percentage of bright pixels have glare
  static const double _glareThreshold = 0.15; // 15%

  /// Brightness threshold for pixel to be considered "bright" (glare)
  static const int _brightPixelThreshold = 240;

  /// Minimum acceptable brightness (mean luminance)
  static const double _minBrightness = 60.0;

  /// Maximum acceptable brightness (mean luminance)
  static const double _maxBrightness = 200.0;

  /// Check image quality
  ///
  /// Runs all quality checks on the provided image file.
  /// Processing is done on a background isolate to avoid blocking the UI.
  ///
  /// [imageFile] - The captured image file to validate
  ///
  /// Returns [QualityCheckResult] with all check results
  Future<QualityCheckResult> checkQuality(XFile imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Run quality checks on background isolate
      final result = await _runQualityChecksOnIsolate(bytes);

      return result;
    } catch (e) {
      // Return failed result on error
      return QualityCheckResult(
        isSharp: false,
        hasNoGlare: false,
        hasGoodLighting: false,
        blurScore: 0.0,
        glarePercentage: 1.0,
        brightness: 0.0,
      );
    }
  }

  /// Run quality checks on a background isolate
  ///
  /// This prevents UI jank by offloading heavy image processing
  /// to a separate isolate.
  Future<QualityCheckResult> _runQualityChecksOnIsolate(
    List<int> imageBytes,
  ) async {
    final receivePort = ReceivePort();

    // Convert to Uint8List for isolate
    final uint8List = Uint8List.fromList(imageBytes);

    // Spawn isolate
    await Isolate.spawn(
      _qualityCheckIsolate,
      _IsolateParams(
        imageBytes: uint8List,
        sendPort: receivePort.sendPort,
      ),
    );

    // Wait for result
    final result = await receivePort.first as QualityCheckResult;

    return result;
  }

  /// Isolate entry point for quality checks
  ///
  /// This function runs on a background isolate and performs all
  /// quality checks without blocking the main UI thread.
  static void _qualityCheckIsolate(_IsolateParams params) {
    try {
      // Decode image
      final image = img.decodeImage(params.imageBytes);
      if (image == null) {
        params.sendPort.send(
          QualityCheckResult(
            isSharp: false,
            hasNoGlare: false,
            hasGoodLighting: false,
            blurScore: 0.0,
            glarePercentage: 1.0,
            brightness: 0.0,
          ),
        );
        return;
      }

      // Run all quality checks
      final blurScore = _calculateBlurScore(image);
      final glarePercentage = _calculateGlarePercentage(image);
      final brightness = _calculateBrightness(image);

      // Determine pass/fail for each check
      final isSharp = blurScore > _blurThreshold;
      final hasNoGlare = glarePercentage < _glareThreshold;
      final hasGoodLighting = brightness >= _minBrightness && 
                              brightness <= _maxBrightness;

      // Send result back to main isolate
      params.sendPort.send(
        QualityCheckResult(
          isSharp: isSharp,
          hasNoGlare: hasNoGlare,
          hasGoodLighting: hasGoodLighting,
          blurScore: blurScore,
          glarePercentage: glarePercentage,
          brightness: brightness,
        ),
      );
    } catch (e) {
      // Send failed result on error
      params.sendPort.send(
        QualityCheckResult(
          isSharp: false,
          hasNoGlare: false,
          hasGoodLighting: false,
          blurScore: 0.0,
          glarePercentage: 1.0,
          brightness: 0.0,
        ),
      );
    }
  }

  /// Calculate blur score using Laplacian variance
  ///
  /// The Laplacian operator detects edges in an image. A sharp image
  /// has strong edges and high variance, while a blurry image has
  /// weak edges and low variance.
  ///
  /// Algorithm:
  /// 1. Convert image to grayscale
  /// 2. Apply Laplacian operator (edge detection)
  /// 3. Calculate variance of Laplacian values
  /// 4. Higher variance = sharper image
  ///
  /// [image] - The image to analyze
  ///
  /// Returns the Laplacian variance (blur score)
  static double _calculateBlurScore(img.Image image) {
    // Convert to grayscale if needed
    final grayscale = image.numChannels > 1 
        ? img.grayscale(image) 
        : image;

    final width = grayscale.width;
    final height = grayscale.height;

    // Laplacian kernel (3x3)
    // Detects edges in all directions
    final laplacianKernel = [
      [0, 1, 0],
      [1, -4, 1],
      [0, 1, 0],
    ];

    // Apply Laplacian operator
    final laplacianValues = <double>[];

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double sum = 0.0;

        // Apply kernel
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = grayscale.getPixel(x + kx, y + ky);
            final intensity = pixel.r.toDouble(); // Grayscale, so R=G=B
            sum += intensity * laplacianKernel[ky + 1][kx + 1];
          }
        }

        laplacianValues.add(sum);
      }
    }

    // Calculate variance of Laplacian values
    if (laplacianValues.isEmpty) return 0.0;

    final mean = laplacianValues.reduce((a, b) => a + b) / laplacianValues.length;
    final variance = laplacianValues
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b) / laplacianValues.length;

    return variance;
  }

  /// Calculate glare percentage (bright pixel percentage)
  ///
  /// Glare occurs when parts of the image are overexposed due to
  /// reflections or bright lighting. This is detected by counting
  /// pixels with very high brightness values.
  ///
  /// Algorithm:
  /// 1. Convert image to grayscale
  /// 2. Count pixels with brightness > threshold (240)
  /// 3. Calculate percentage of bright pixels
  ///
  /// [image] - The image to analyze
  ///
  /// Returns the percentage of bright pixels (0.0 to 1.0)
  static double _calculateGlarePercentage(img.Image image) {
    // Convert to grayscale if needed
    final grayscale = image.numChannels > 1 
        ? img.grayscale(image) 
        : image;

    final width = grayscale.width;
    final height = grayscale.height;
    final totalPixels = width * height;

    int brightPixelCount = 0;

    // Count bright pixels
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final brightness = pixel.r; // Grayscale, so R=G=B

        if (brightness > _brightPixelThreshold) {
          brightPixelCount++;
        }
      }
    }

    // Calculate percentage
    return totalPixels > 0 ? brightPixelCount / totalPixels : 0.0;
  }

  /// Calculate mean brightness of the image
  ///
  /// Brightness is measured as the mean luminance value across all pixels.
  /// Too dark (< 60) or too bright (> 200) images are rejected.
  ///
  /// Algorithm:
  /// 1. Convert image to grayscale
  /// 2. Calculate mean of all pixel values
  ///
  /// [image] - The image to analyze
  ///
  /// Returns the mean brightness (0-255)
  static double _calculateBrightness(img.Image image) {
    // Convert to grayscale if needed
    final grayscale = image.numChannels > 1 
        ? img.grayscale(image) 
        : image;

    final width = grayscale.width;
    final height = grayscale.height;
    final totalPixels = width * height;

    double sum = 0.0;

    // Sum all pixel values
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = grayscale.getPixel(x, y);
        sum += pixel.r.toDouble(); // Grayscale, so R=G=B
      }
    }

    // Calculate mean
    return totalPixels > 0 ? sum / totalPixels : 0.0;
  }
}

/// Parameters for the quality check isolate
class _IsolateParams {
  final Uint8List imageBytes;
  final SendPort sendPort;

  _IsolateParams({
    required this.imageBytes,
    required this.sendPort,
  });
}
