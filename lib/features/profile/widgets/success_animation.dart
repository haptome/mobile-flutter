// Purpose: Success animation widget for capture completion
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign - Section 5.2

import 'package:flutter/material.dart';

/// Widget that displays an animated success indicator
/// 
/// This widget shows a smooth checkmark animation when a capture is successful.
/// It includes:
/// - A circular background that scales in
/// - A checkmark that draws itself
/// - Optional fade-out after completion
/// 
/// The animation automatically plays when the widget is mounted.
class SuccessAnimation extends StatefulWidget {
  /// Size of the success indicator
  final double size;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  /// Whether to auto-dismiss after animation
  final bool autoDismiss;

  const SuccessAnimation({
    super.key,
    this.size = 120.0,
    this.onComplete,
    this.autoDismiss = false,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  AnimationController? _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for the circle
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Check animation for the checkmark
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // Initialize fade controller if auto-dismiss is enabled
    if (widget.autoDismiss) {
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }

    // Start animations in sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Start scale animation
    await _scaleController.forward();

    // Start check animation
    await _checkController.forward();

    // Wait a bit before fading out
    if (widget.autoDismiss && _fadeController != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _fadeController!.reverse(from: 1.0);
    }

    // Call completion callback
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50), // Green
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: CheckmarkPainter(
                  progress: _checkAnimation.value,
                ),
              );
            },
          ),
        ),
      ),
    );

    // Apply fade animation if auto-dismiss is enabled
    if (widget.autoDismiss && _fadeController != null) {
      child = FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController!),
        child: child,
      );
    }

    return child;
  }
}

/// Custom painter that draws an animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final checkSize = size.width * 0.4;

    // Define checkmark path
    final path = Path();

    // Start point (left)
    final startPoint = Offset(
      center.dx - checkSize / 2,
      center.dy,
    );

    // Middle point (bottom)
    final middlePoint = Offset(
      center.dx - checkSize / 6,
      center.dy + checkSize / 3,
    );

    // End point (top right)
    final endPoint = Offset(
      center.dx + checkSize / 2,
      center.dy - checkSize / 3,
    );

    // Calculate path based on progress
    if (progress < 0.5) {
      // First half: draw from start to middle
      final t = progress * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (middlePoint.dx - startPoint.dx) * t,
        startPoint.dy + (middlePoint.dy - startPoint.dy) * t,
      );
    } else {
      // Second half: draw from middle to end
      final t = (progress - 0.5) * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(middlePoint.dx, middlePoint.dy);
      path.lineTo(
        middlePoint.dx + (endPoint.dx - middlePoint.dx) * t,
        middlePoint.dy + (endPoint.dy - middlePoint.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
