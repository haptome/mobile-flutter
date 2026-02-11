// Purpose: Frame geometry model for camera overlays in ID capture and liveness checks
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'dart:ui';

import 'package:flutter/material.dart';
import 'id_type.dart';

/// Model representing the geometry of a camera frame overlay
/// Used for both ID document capture and face detection frames
class FrameGeometry {
  /// The rectangular bounds of the frame
  final Rect frameRect;

  /// The aspect ratio of the frame (width/height)
  final double aspectRatio;

  /// The corner radius for rounded corners
  final double cornerRadius;

  /// The screen size used for calculations
  final Size screenSize;

  const FrameGeometry({
    required this.frameRect,
    required this.aspectRatio,
    required this.cornerRadius,
    required this.screenSize,
  });

  /// Calculate the area of the frame in square pixels
  double get frameArea => frameRect.width * frameRect.height;

  /// Get the center point of the frame
  Offset get center => frameRect.center;

  /// Get the width of the frame
  double get width => frameRect.width;

  /// Get the height of the frame
  double get height => frameRect.height;

  /// Get the left position of the frame
  double get left => frameRect.left;

  /// Get the top position of the frame
  double get top => frameRect.top;

  /// Get the right position of the frame
  double get right => frameRect.right;

  /// Get the bottom position of the frame
  double get bottom => frameRect.bottom;

  /// Calculate frame geometry for ID document capture
  /// 
  /// The frame is sized based on the ID type's aspect ratio and positioned
  /// in the center of the screen. Maximum dimensions are constrained to
  /// 85% of screen width and 60% of screen height.
  static FrameGeometry forIDCapture({
    required Size screenSize,
    required IDType idType,
  }) {
    final idTypeInfo = IDTypeInfo.forType(idType);
    final aspectRatio = idTypeInfo.aspectRatio;

    // Maximum dimensions
    final maxWidth = screenSize.width * 0.85;
    final maxHeight = screenSize.height * 0.6;

    double frameWidth, frameHeight;

    if (aspectRatio > 1) {
      // Wide rectangle (National ID, Driver License)
      frameWidth = maxWidth;
      frameHeight = frameWidth / aspectRatio;

      // Ensure height doesn't exceed maximum
      if (frameHeight > maxHeight) {
        frameHeight = maxHeight;
        frameWidth = frameHeight * aspectRatio;
      }
    } else {
      // Tall rectangle (Passport)
      frameHeight = maxHeight;
      frameWidth = frameHeight * aspectRatio;

      // Ensure width doesn't exceed maximum
      if (frameWidth > maxWidth) {
        frameWidth = maxWidth;
        frameHeight = frameWidth / aspectRatio;
      }
    }

    // Center the frame on screen
    final left = (screenSize.width - frameWidth) / 2;
    final top = (screenSize.height - frameHeight) / 2;

    return FrameGeometry(
      frameRect: Rect.fromLTWH(left, top, frameWidth, frameHeight),
      aspectRatio: aspectRatio,
      cornerRadius: 16.0,
      screenSize: screenSize,
    );
  }

  /// Calculate frame geometry for face detection (liveness check)
  /// 
  /// Creates an oval frame centered on screen with diameter equal to
  /// 70% of screen width. The corner radius is set to half the diameter
  /// to create a circular/oval shape.
  static FrameGeometry forFaceDetection({
    required Size screenSize,
  }) {
    final diameter = screenSize.width * 0.7;
    final left = (screenSize.width - diameter) / 2;
    final top = (screenSize.height - diameter) / 2;

    return FrameGeometry(
      frameRect: Rect.fromLTWH(left, top, diameter, diameter),
      aspectRatio: 1.0,
      cornerRadius: diameter / 2, // Makes it circular/oval
      screenSize: screenSize,
    );
  }

  /// Check if a point is inside the frame
  bool containsPoint(Offset point) {
    return frameRect.contains(point);
  }

  /// Calculate the overlap percentage between a detected rectangle and this frame
  /// Returns a value between 0.0 and 1.0
  double calculateOverlap(Rect detectedRect) {
    final intersection = frameRect.intersect(detectedRect);
    if (intersection.isEmpty) {
      return 0.0;
    }

    final intersectionArea = intersection.width * intersection.height;
    final detectedArea = detectedRect.width * detectedRect.height;

    // Return the percentage of the detected rectangle that overlaps with the frame
    return intersectionArea / detectedArea;
  }

  /// Create a copy of this geometry with updated values
  FrameGeometry copyWith({
    Rect? frameRect,
    double? aspectRatio,
    double? cornerRadius,
    Size? screenSize,
  }) {
    return FrameGeometry(
      frameRect: frameRect ?? this.frameRect,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      screenSize: screenSize ?? this.screenSize,
    );
  }

  @override
  String toString() {
    return 'FrameGeometry(rect: $frameRect, aspectRatio: $aspectRatio, '
        'cornerRadius: $cornerRadius, screenSize: $screenSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FrameGeometry &&
        other.frameRect == frameRect &&
        other.aspectRatio == aspectRatio &&
        other.cornerRadius == cornerRadius &&
        other.screenSize == screenSize;
  }

  @override
  int get hashCode {
    return Object.hash(
      frameRect,
      aspectRatio,
      cornerRadius,
      screenSize,
    );
  }
}
