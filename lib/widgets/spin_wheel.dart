// Purpose: Spin the Wheel widget for lottery
// Author: haptome H.
// Linked Spec Section: Lottery Page

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SpinWheel extends StatefulWidget {
  final List<int> prizes;
  final Function(int prize)? onSpinComplete;

  const SpinWheel({
    super.key,
    this.prizes = const [10, 20, 50, 90, 100, 200, 500, 800, 1000, 1500],
    this.onSpinComplete,
  });

  @override
  State<SpinWheel> createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isSpinning = false;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);

    // Reset animation
    _controller.reset();

    // Random rotation (3-5 full rotations + random angle)
    final random = math.Random();
    final fullRotations = 3 + random.nextInt(3);
    final randomAngle = random.nextDouble() * 360;
    final totalRotation = (fullRotations * 360) + randomAngle;

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward().then((_) {
      _currentRotation = _currentRotation + totalRotation;
      _currentRotation = _currentRotation % 360;

      // Calculate which prize was won
      final segmentAngle = 360 / widget.prizes.length;
      final normalizedAngle = (360 - _currentRotation) % 360;
      final prizeIndex = (normalizedAngle / segmentAngle).floor();
      final prize = widget.prizes[prizeIndex % widget.prizes.length];

      setState(() => _isSpinning = false);
      widget.onSpinComplete?.call(prize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.85;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wheel
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi / 180,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: WheelPainter(
                    prizes: widget.prizes,
                  ),
                ),
              );
            },
          ),
          // Center circle (hub)
          Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary, // Dark green
                  AppColors.primary, // Light green/yellow
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Pointer at top (map pin style)
          Positioned(
            top: -15,
            child: CustomPaint(
              size: const Size(40, 50),
              painter: PointerPainter(),
            ),
          ),
        ],
      ),
    );
  }

  bool get isSpinning => _isSpinning;
}

// Pointer painter (map pin style)
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw pin shape (triangle pointing down)
    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom point
    path.lineTo(0, size.height * 0.4); // Left top
    path.lineTo(size.width / 2, 0); // Top center (white circle will be here)
    path.lineTo(size.width, size.height * 0.4); // Right top
    path.close();

    // Gradient for the pin
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary, // Light green/yellow at top
        AppColors.secondary, // Dark green at bottom
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawPath(path, paint);

    // White circular tip at top
    final whitePaint = Paint()
      ..color = AppColors.backgroundWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, 0),
      8,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WheelPainter extends CustomPainter {
  final List<int> prizes;

  WheelPainter({
    required this.prizes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 360 / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = (i * segmentAngle - 90) * math.pi / 180;
      final sweepAngle = segmentAngle * math.pi / 180;

      // Alternate colors: first segment is light green/yellow, then dark teal/green
      final color = i % 2 == 0 ? AppColors.primary : AppColors.secondary;

      // Draw segment
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = AppColors.backgroundWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${prizes[i]} Birr',
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'sans-serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
