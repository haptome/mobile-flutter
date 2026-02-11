// Purpose: Camera frame overlay widget for ID capture
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign - Section 5.2

import 'package:flutter/material.dart';
import '../../../models/frame_geometry.dart';
import '../../../controllers/id_capture_controller.dart';

/// Widget that renders a camera frame overlay with a transparent cutout
/// 
/// This widget creates a dark semi-transparent mask over the camera preview
/// with a transparent frame cutout where the ID document should be placed.
/// The frame appearance changes based on the capture state:
/// - idle/detecting: White frame, no animation
/// - aligned: White frame with pulsing animation
/// - success: Green frame with checkmark
/// 
/// The frame geometry is dynamic and calculated based on the ID type.
class CameraFrameOverlay extends StatefulWidget {
  /// The geometry defining the frame position and size
  final FrameGeometry geometry;

  /// The current capture state
  final CaptureState state;

  /// Whether to show the frame as an oval (for face detection)
  final bool isOval;

  const CameraFrameOverlay({
    super.key,
    required this.geometry,
    required this.state,
    this.isOval = false,
  });

  @override
  State<CameraFrameOverlay> createState() => _CameraFrameOverlayState();
}

class _CameraFrameOverlayState extends State<CameraFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FramePainter(
        frameRect: widget.geometry.frameRect,
        cornerRadius: widget.geometry.cornerRadius,
        state: widget.state,
        pulseAnimation: widget.state == CaptureState.aligned
            ? _pulseAnimation
            : null,
        isOval: widget.isOval,
      ),
    );
  }
}

/// Custom painter that draws the frame overlay
class FramePainter extends CustomPainter {
  final Rect frameRect;
  final double cornerRadius;
  final CaptureState state;
  final Animation<double>? pulseAnimation;
  final bool isOval;

  FramePainter({
    required this.frameRect,
    required this.cornerRadius,
    required this.state,
    this.pulseAnimation,
    this.isOval = false,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark mask with cutout
    _drawMask(canvas, size);

    // Draw frame border
    _drawFrameBorder(canvas);

    // Draw checkmark on success
    if (state == CaptureState.success) {
      _drawCheckmark(canvas);
    }
  }

  void _drawMask(Canvas canvas, Size size) {
    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Create path for the entire screen
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create path for the frame cutout
    final framePath = Path();
    if (isOval) {
      framePath.addOval(frameRect);
    } else {
      framePath.addRRect(
        RRect.fromRectAndRadius(
          frameRect,
          Radius.circular(cornerRadius),
        ),
      );
    }

    // Subtract frame from screen to create cutout
    final maskPath = Path.combine(
      PathOperation.difference,
      screenPath,
      framePath,
    );

    canvas.drawPath(maskPath, maskPaint);
  }

  void _drawFrameBorder(Canvas canvas) {
    // Determine frame color based on state
    Color frameColor;
    switch (state) {
      case CaptureState.success:
        frameColor = const Color(0xFF4CAF50); // Green
        break;
      case CaptureState.error:
        frameColor = const Color(0xFFF44336); // Red
        break;
      default:
        frameColor = Colors.white;
    }

    // Apply pulse scale if aligned
    final scale = pulseAnimation?.value ?? 1.0;
    final scaledRect = Rect.fromCenter(
      center: frameRect.center,
      width: frameRect.width * scale,
      height: frameRect.height * scale,
    );

    final borderPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    if (isOval) {
      canvas.drawOval(scaledRect, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          scaledRect,
          Radius.circular(cornerRadius),
        ),
        borderPaint,
      );
    }
  }

  void _drawCheckmark(Canvas canvas) {
    final checkPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final center = frameRect.center;
    final checkSize = 40.0;

    // Draw checkmark path
    final checkPath = Path()
      ..moveTo(center.dx - checkSize / 2, center.dy)
      ..lineTo(center.dx - checkSize / 6, center.dy + checkSize / 3)
      ..lineTo(center.dx + checkSize / 2, center.dy - checkSize / 3);

    canvas.drawPath(checkPath, checkPaint);

    // Draw white circle background
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, checkSize * 0.8, circlePaint);

    // Redraw checkmark on top
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant FramePainter oldDelegate) {
    return oldDelegate.frameRect != frameRect ||
        oldDelegate.state != state ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.isOval != isOval;
  }
}
