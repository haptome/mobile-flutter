// Purpose: Edge detection service for ID document detection in camera frames
// Author: KYC ID & Liveness Flow Redesign
// Linked Spec Section: Design 3.2 - Edge Detection Service

import 'dart:math' as math;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../models/detection_result.dart';
import '../../models/frame_geometry.dart';

/// Service for detecting document edges in camera frames
///
/// This service processes camera frames to detect ID documents using:
/// - YUV420 to grayscale conversion
/// - Gaussian blur for noise reduction
/// - Canny edge detection
/// - Contour detection to find quadrilaterals
/// - Aspect ratio validation
/// - Overlap calculation with target frame
///
/// Example usage:
/// ```dart
/// final edgeService = EdgeDetectionService();
///
/// cameraService.frameStream.listen((frame) {
///   final result = edgeService.detectEdges(frame, targetFrame);
///   if (result != null && result.isAligned) {
///     // Document is properly aligned
///   }
/// });
/// ```
class EdgeDetectionService {
  /// Canny edge detection thresholds
  static const double _cannyLowThreshold = 50.0;
  static const double _cannyHighThreshold = 150.0;

  /// Aspect ratio tolerance (±15%)
  static const double _aspectRatioTolerance = 0.15;

  /// Minimum overlap percentage for alignment
  static const double _minOverlapPercentage = 0.85;

  /// Minimum confidence threshold
  static const double _minConfidence = 0.6;

  /// Detect edges in a camera frame
  ///
  /// [image] - Camera frame in YUV420 format
  /// [targetFrame] - Target frame geometry for alignment validation
  ///
  /// Returns [EdgeDetectionResult] if edges are detected, null otherwise
  EdgeDetectionResult? detectEdges(
    CameraImage image,
    FrameGeometry targetFrame,
  ) {
    try {
      // Step 1: Convert YUV420 to grayscale
      final grayscale = _convertYUV420ToGrayscale(image);
      if (grayscale == null) return null;

      // Step 2: Apply Gaussian blur
      final blurred = _applyGaussianBlur(grayscale);

      // Step 3: Apply Canny edge detection
      final edges = _cannyEdgeDetection(blurred);

      // Step 4: Find largest quadrilateral contour
      final corners = _findLargestQuadrilateral(edges);
      if (corners == null || corners.length != 4) return null;

      // Step 5: Validate aspect ratio
      final detectedAspectRatio = _calculateAspectRatio(corners);
      final isValidAspectRatio = _validateAspectRatio(
        detectedAspectRatio,
        targetFrame.aspectRatio,
      );

      // Step 6: Calculate overlap with target frame
      final detectedRect = _cornersToRect(corners);
      final overlapPercentage = _calculateOverlap(detectedRect, targetFrame.frameRect);

      // Calculate confidence based on edge strength and contour quality
      final confidence = _calculateConfidence(
        corners,
        isValidAspectRatio,
        overlapPercentage,
      );

      // Check if aligned (good overlap and valid aspect ratio)
      final isAligned = isValidAspectRatio &&
          overlapPercentage >= _minOverlapPercentage &&
          confidence >= _minConfidence;

      return EdgeDetectionResult(
        corners: corners,
        confidence: confidence,
        isAligned: isAligned,
        overlapPercentage: overlapPercentage,
      );
    } catch (e) {
      // Return null on any error to allow graceful degradation
      return null;
    }
  }

  /// Convert YUV420 camera image to grayscale
  ///
  /// YUV420 format has Y plane (luminance) which is already grayscale
  /// We extract the Y plane and convert it to an image
  img.Image? _convertYUV420ToGrayscale(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      // Get Y plane (luminance) - this is already grayscale
      final yPlane = image.planes[0];
      final yBytes = yPlane.bytes;

      // Create grayscale image
      final grayscale = img.Image(width: width, height: height);

      // Copy Y plane data to image
      // Handle row stride (padding) if present
      final int rowStride = yPlane.bytesPerRow;
      final int pixelStride = yPlane.bytesPerPixel ?? 1;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int index = y * rowStride + x * pixelStride;
          if (index < yBytes.length) {
            final int luminance = yBytes[index];
            // Set RGB to same value for grayscale
            grayscale.setPixelRgba(x, y, luminance, luminance, luminance, 255);
          }
        }
      }

      return grayscale;
    } catch (e) {
      return null;
    }
  }

  /// Apply Gaussian blur to reduce noise
  ///
  /// Uses a 5x5 Gaussian kernel for smoothing
  img.Image _applyGaussianBlur(img.Image image) {
    // Use image package's built-in Gaussian blur
    // Radius of 2 approximates a 5x5 kernel
    return img.gaussianBlur(image, radius: 2);
  }

  /// Apply Canny edge detection
  ///
  /// Simplified Canny implementation:
  /// 1. Calculate gradients using Sobel operator
  /// 2. Apply non-maximum suppression
  /// 3. Apply double threshold
  /// 4. Edge tracking by hysteresis
  img.Image _cannyEdgeDetection(img.Image image) {
    final int width = image.width;
    final int height = image.height;

    // Step 1: Calculate gradients using Sobel operator
    final gradients = _calculateGradients(image);
    final magnitudes = gradients['magnitudes'] as List<List<double>>;
    final directions = gradients['directions'] as List<List<double>>;

    // Step 2: Non-maximum suppression
    final suppressed = _nonMaximumSuppression(magnitudes, directions);

    // Step 3 & 4: Double threshold and edge tracking
    final edges = _doubleThresholdAndHysteresis(suppressed);

    // Convert edge map to image
    final edgeImage = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final value = edges[y][x] ? 255 : 0;
        edgeImage.setPixelRgba(x, y, value, value, value, 255);
      }
    }

    return edgeImage;
  }

  /// Calculate gradients using Sobel operator
  Map<String, dynamic> _calculateGradients(img.Image image) {
    final int width = image.width;
    final int height = image.height;

    // Sobel kernels
    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];
    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];

    final magnitudes = List.generate(height, (_) => List<double>.filled(width, 0.0));
    final directions = List.generate(height, (_) => List<double>.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0.0;
        double gy = 0.0;

        // Apply Sobel kernels
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixel(x + kx, y + ky);
            final intensity = pixel.r.toDouble(); // Grayscale, so R=G=B

            gx += intensity * sobelX[ky + 1][kx + 1];
            gy += intensity * sobelY[ky + 1][kx + 1];
          }
        }

        magnitudes[y][x] = math.sqrt(gx * gx + gy * gy);
        directions[y][x] = math.atan2(gy, gx);
      }
    }

    return {'magnitudes': magnitudes, 'directions': directions};
  }

  /// Non-maximum suppression
  List<List<double>> _nonMaximumSuppression(
    List<List<double>> magnitudes,
    List<List<double>> directions,
  ) {
    final int height = magnitudes.length;
    final int width = magnitudes[0].length;
    final suppressed = List.generate(height, (_) => List<double>.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final angle = directions[y][x] * 180 / math.pi;
        final magnitude = magnitudes[y][x];

        double neighbor1 = 0.0;
        double neighbor2 = 0.0;

        // Determine neighbors based on gradient direction
        if ((angle >= -22.5 && angle < 22.5) || (angle >= 157.5 || angle < -157.5)) {
          // Horizontal edge
          neighbor1 = magnitudes[y][x + 1];
          neighbor2 = magnitudes[y][x - 1];
        } else if ((angle >= 22.5 && angle < 67.5) || (angle >= -157.5 && angle < -112.5)) {
          // Diagonal edge (/)
          neighbor1 = magnitudes[y + 1][x - 1];
          neighbor2 = magnitudes[y - 1][x + 1];
        } else if ((angle >= 67.5 && angle < 112.5) || (angle >= -112.5 && angle < -67.5)) {
          // Vertical edge
          neighbor1 = magnitudes[y + 1][x];
          neighbor2 = magnitudes[y - 1][x];
        } else {
          // Diagonal edge (\)
          neighbor1 = magnitudes[y + 1][x + 1];
          neighbor2 = magnitudes[y - 1][x - 1];
        }

        // Keep only local maxima
        if (magnitude >= neighbor1 && magnitude >= neighbor2) {
          suppressed[y][x] = magnitude;
        }
      }
    }

    return suppressed;
  }

  /// Double threshold and edge tracking by hysteresis
  List<List<bool>> _doubleThresholdAndHysteresis(List<List<double>> suppressed) {
    final int height = suppressed.length;
    final int width = suppressed[0].length;
    final edges = List.generate(height, (_) => List<bool>.filled(width, false));

    // Apply double threshold
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final magnitude = suppressed[y][x];
        if (magnitude >= _cannyHighThreshold) {
          edges[y][x] = true;
        } else if (magnitude >= _cannyLowThreshold) {
          // Weak edge - check if connected to strong edge
          if (_isConnectedToStrongEdge(suppressed, x, y)) {
            edges[y][x] = true;
          }
        }
      }
    }

    return edges;
  }

  /// Check if a weak edge is connected to a strong edge
  bool _isConnectedToStrongEdge(List<List<double>> suppressed, int x, int y) {
    final int height = suppressed.length;
    final int width = suppressed[0].length;

    // Check 8-connected neighbors
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
          if (suppressed[ny][nx] >= _cannyHighThreshold) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Find largest quadrilateral contour in edge image
  ///
  /// Simplified contour detection:
  /// 1. Find edge pixels
  /// 2. Group into contours
  /// 3. Find largest contour
  /// 4. Approximate to quadrilateral
  List<Offset>? _findLargestQuadrilateral(img.Image edges) {
    // Find all edge pixels
    final edgePixels = <Offset>[];
    for (int y = 0; y < edges.height; y++) {
      for (int x = 0; x < edges.width; x++) {
        final pixel = edges.getPixel(x, y);
        if (pixel.r > 128) {
          // Edge pixel
          edgePixels.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    if (edgePixels.isEmpty) return null;

    // Find convex hull of edge pixels (simplified approach)
    // For a real implementation, use a proper convex hull algorithm
    // Here we'll use a simplified approach: find extreme points

    // Find extreme points (top-left, top-right, bottom-right, bottom-left)
    final corners = _findExtremePoints(edgePixels);

    return corners.length == 4 ? corners : null;
  }

  /// Find extreme points to form a quadrilateral
  List<Offset> _findExtremePoints(List<Offset> points) {
    if (points.isEmpty) return [];

    // Find bounding box corners
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    // Find actual corner points closest to bounding box corners
    final topLeft = _findClosestPoint(points, Offset(minX, minY));
    final topRight = _findClosestPoint(points, Offset(maxX, minY));
    final bottomRight = _findClosestPoint(points, Offset(maxX, maxY));
    final bottomLeft = _findClosestPoint(points, Offset(minX, maxY));

    return [topLeft, topRight, bottomRight, bottomLeft];
  }

  /// Find point closest to target
  Offset _findClosestPoint(List<Offset> points, Offset target) {
    Offset closest = points[0];
    double minDistance = (points[0] - target).distance;

    for (final point in points) {
      final distance = (point - target).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closest = point;
      }
    }

    return closest;
  }

  /// Calculate aspect ratio from corners
  double _calculateAspectRatio(List<Offset> corners) {
    if (corners.length != 4) return 0.0;

    // Calculate width (average of top and bottom edges)
    final topWidth = (corners[1] - corners[0]).distance;
    final bottomWidth = (corners[2] - corners[3]).distance;
    final width = (topWidth + bottomWidth) / 2;

    // Calculate height (average of left and right edges)
    final leftHeight = (corners[3] - corners[0]).distance;
    final rightHeight = (corners[2] - corners[1]).distance;
    final height = (leftHeight + rightHeight) / 2;

    return height > 0 ? width / height : 0.0;
  }

  /// Validate aspect ratio against expected ratio
  bool _validateAspectRatio(double detected, double expected) {
    if (detected == 0.0 || expected == 0.0) return false;

    final ratio = detected / expected;
    final tolerance = 1.0 + _aspectRatioTolerance;

    return ratio >= (1.0 / tolerance) && ratio <= tolerance;
  }

  /// Convert corners to rectangle
  Rect _cornersToRect(List<Offset> corners) {
    if (corners.length != 4) return Rect.zero;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final corner in corners) {
      minX = math.min(minX, corner.dx);
      maxX = math.max(maxX, corner.dx);
      minY = math.min(minY, corner.dy);
      maxY = math.max(maxY, corner.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Calculate overlap percentage between detected rectangle and target frame
  double _calculateOverlap(Rect detected, Rect target) {
    final intersection = detected.intersect(target);
    if (intersection.isEmpty) return 0.0;

    final intersectionArea = intersection.width * intersection.height;
    final detectedArea = detected.width * detected.height;

    if (detectedArea == 0) return 0.0;

    return intersectionArea / detectedArea;
  }

  /// Calculate confidence score
  double _calculateConfidence(
    List<Offset> corners,
    bool isValidAspectRatio,
    double overlapPercentage,
  ) {
    double confidence = 0.0;

    // Base confidence from having 4 corners
    if (corners.length == 4) {
      confidence += 0.3;
    }

    // Confidence from aspect ratio validation
    if (isValidAspectRatio) {
      confidence += 0.3;
    }

    // Confidence from overlap percentage
    confidence += overlapPercentage * 0.4;

    return confidence.clamp(0.0, 1.0);
  }
}
