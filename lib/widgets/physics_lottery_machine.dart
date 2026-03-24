// Purpose: Ultra-premium physics-based lottery machine with realistic ball physics
// Author: Auto-generated with advanced physics integration

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lottery_ball.dart';

class PhysicsLotteryMachine extends StatefulWidget {
  final List<LotteryBall> balls;
  final bool isDrawing;
  final String selectedBall;
  final VoidCallback? onDrawComplete;

  const PhysicsLotteryMachine({
    super.key,
    required this.balls,
    this.isDrawing = false,
    this.selectedBall = '',
    this.onDrawComplete,
  });

  @override
  State<PhysicsLotteryMachine> createState() => _PhysicsLotteryMachineState();
}

class _PhysicsLotteryMachineState extends State<PhysicsLotteryMachine>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  FragmentProgram? program;
  final List<PhysicsBall> physicsBalls = [];
  final double sphereRadius = 140;
  late Offset center;
  final double cameraDistance = 350;
  PhysicsBall? exitingBall;
  bool exitMode = false;
  
  // Animation controllers for premium effects
  late AnimationController _glowController;
  late AnimationController _ledController;
  late Animation<double> _glowAnimation;
  late Animation<double> _ledAnimation;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _initializeAnimations();
    _initializeBalls();
    _ticker = createTicker(_update)..start();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _ledController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOutSine,
    ));
    
    _ledAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ledController,
      curve: Curves.easeInOut,
    ));
    
    _glowController.repeat(reverse: true);
    _ledController.repeat(reverse: true);
  }

  Future<void> _loadShader() async {
    // Shader loading disabled for better compatibility
    // Custom shader effects can be re-enabled when needed
    try {
      // program = await FragmentProgram.fromAsset('shaders/glass.frag');
    } catch (e) {
      // Shader loading failed, continue without shader effects
      print('Shader loading skipped for compatibility: $e');
    }
  }

  void _initializeBalls() {
    physicsBalls.clear();
    for (int i = 0; i < widget.balls.length; i++) {
      final ball = widget.balls[i];
      physicsBalls.add(PhysicsBall.fromLotteryBall(ball, i));
    }
  }

  @override
  void didUpdateWidget(PhysicsLotteryMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.balls.length != oldWidget.balls.length) {
      _initializeBalls();
    }
    
    if (widget.isDrawing && !oldWidget.isDrawing) {
      _startPhysicsAnimation();
    } else if (!widget.isDrawing && oldWidget.isDrawing) {
      _stopPhysicsAnimation();
    }
    
    if (widget.selectedBall.isNotEmpty && oldWidget.selectedBall.isEmpty) {
      _triggerWinnerSelection();
    }
  }

  void _startPhysicsAnimation() {
    HapticFeedback.mediumImpact();
    exitMode = false;
    exitingBall = null;
    
    // Add random forces to all balls
    for (var ball in physicsBalls) {
      ball.addRandomForce();
    }
  }

  void _stopPhysicsAnimation() {
    // Physics continues naturally, no need to stop
  }

  void _triggerWinnerSelection() {
    HapticFeedback.heavyImpact();
    
    // Find the winning ball
    final winnerNumber = widget.selectedBall;
    for (var ball in physicsBalls) {
      if (ball.number == winnerNumber) {
        exitingBall = ball;
        exitMode = true;
        ball.setAsWinner();
        break;
      }
    }
    
    // Trigger completion callback after animation
    Future.delayed(const Duration(seconds: 2), () {
      widget.onDrawComplete?.call();
    });
  }

  void _update(Duration d) {
    const dt = 0.016;
    
    for (var ball in physicsBalls) {
      ball.applyAir();
      ball.update(dt);
      _handleWallCollision(ball);
    }
    
    _handleBallCollisions();
    
    if (exitMode && exitingBall != null) {
      _animateExit(exitingBall!);
    }
    
    setState(() {});
  }

  void _handleWallCollision(PhysicsBall ball) {
    final toCenter = ball.position - center;
    final dist = toCenter.distance;
    
    if (dist + ball.radius > sphereRadius) {
      final normal = toCenter / dist;
      ball.velocity -= normal * (2 * ball.velocity.dot(normal));
      ball.position = center + normal * (sphereRadius - ball.radius);
      
      // Subtle haptic feedback for wall collisions
      if (widget.isDrawing) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _handleBallCollisions() {
    for (int i = 0; i < physicsBalls.length; i++) {
      for (int j = i + 1; j < physicsBalls.length; j++) {
        final a = physicsBalls[i];
        final b = physicsBalls[j];
        final delta = b.position - a.position;
        final dist = delta.distance;
        final minDist = a.radius + b.radius;
        
        if (dist < minDist && dist > 0) {
          final normal = delta / dist;
          final relVel = a.velocity - b.velocity;
          final speed = relVel.dot(normal);
          
          if (speed < 0) continue;
          
          final impulse = normal * speed * 0.8; // Damping factor
          a.velocity -= impulse;
          b.velocity += impulse;
          
          // Separate balls to prevent overlap
          final overlap = minDist - dist;
          final separation = normal * (overlap * 0.5);
          a.position -= separation;
          b.position += separation;
        }
      }
    }
  }

  void _animateExit(PhysicsBall ball) {
    final exitPoint = Offset(center.dx, center.dy + sphereRadius + 100);
    final dir = exitPoint - ball.position;
    if (dir.distance > 5) {
      ball.velocity = dir * (4.0 / dir.distance);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _glowController.dispose();
    _ledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 420,
      child: LayoutBuilder(
        builder: (context, constraints) {
          center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight / 2 - 20,
          );
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Premium machine base with glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 280,
                    height: 390,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.cyan.withValues(alpha: 0.4 * _glowAnimation.value),
                          Colors.blue.withValues(alpha: 0.3 * _glowAnimation.value),
                          Colors.purple.withValues(alpha: 0.2 * _glowAnimation.value),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.5 * _glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3 * _glowAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        _buildLEDStrips(),
                      ],
                    ),
                  );
                },
              ),
              
              // Physics-based ball container
              ClipOval(
                child: Container(
                  width: sphereRadius * 2,
                  height: sphereRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.3),
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.08),
                        Colors.cyan.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: CustomPaint(
                    size: Size(sphereRadius * 2, sphereRadius * 2),
                    painter: PhysicsKenoPainter(
                      balls: physicsBalls,
                      center: Offset(sphereRadius, sphereRadius),
                      radius: sphereRadius,
                      cameraDistance: cameraDistance,
                      selectedBall: widget.selectedBall,
                    ),
                  ),
                ),
              ),
              
              // Glass effects overlay
              // Positioned.fill(
              //   child: _buildGlassEffects(),
              // ),
              
              // Premium machine top
              // Positioned(
              //   top: 0,
              //   child: Container(
              //     width: 80,
              //     height: 50,
              //     decoration: BoxDecoration(
              //       borderRadius: const BorderRadius.vertical(
              //         top: Radius.circular(40),
              //       ),
              //       gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           Colors.white.withValues(alpha: 0.9),
              //           Colors.grey.shade300,
              //           Colors.grey.shade600,
              //         ],
              //       ),
              //       border: Border.all(
              //         color: Colors.white.withValues(alpha: 0.5),
              //         width: 2,
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.white.withValues(alpha: 0.3),
              //           blurRadius: 10,
              //           spreadRadius: 2,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              
              // Premium machine base
              Positioned(
                bottom: 0,
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade700,
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusLED(Colors.green, !widget.isDrawing),
                          const SizedBox(width: 8),
                          _buildStatusLED(Colors.amber, widget.isDrawing),
                          const SizedBox(width: 8),
                          _buildStatusLED(Colors.red, widget.selectedBall.isNotEmpty),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLEDStrips() {
    return AnimatedBuilder(
      animation: _ledAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.6 * _ledAnimation.value),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Top LED strip
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(8, (index) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: _ledAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5 * _ledAnimation.value),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassEffects() {
    return ClipOval(
      child: Container(
        width: sphereRadius * 2,
        height: sphereRadius * 2,
        child: Stack(
          children: [
            // Primary reflection
            Positioned(
              top: 30,
              left: 50,
              child: Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLED(Color color, bool isActive) {
    return AnimatedBuilder(
      animation: _ledAnimation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? color.withValues(alpha: _ledAnimation.value)
                : color.withValues(alpha: 0.2),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withValues(alpha: 0.5 * _ledAnimation.value),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        );
      },
    );
  }
}

// Physics-based ball class
class PhysicsBall {
  Offset position;
  Offset velocity;
  double z;
  final String number;
  double radius = 12;
  double rotation = 0;
  bool isWinner = false;
  Color color;

  PhysicsBall({
    required this.position,
    required this.velocity,
    required this.z,
    required this.number,
    required this.color,
  });

  factory PhysicsBall.fromLotteryBall(LotteryBall lotteryBall, int index) {
    final r = Random();
    return PhysicsBall(
      position: Offset(
        r.nextDouble() * 200 + 50,
        r.nextDouble() * 200 + 50,
      ),
      velocity: Offset(
        r.nextDouble() * 4 - 2,
        r.nextDouble() * 4 - 2,
      ),
      z: r.nextDouble() * 150,
      number: lotteryBall.number,
      color: lotteryBall.color,
    );
  }

  void applyAir() {
    // Air resistance and random turbulence
    velocity *= 0.995; // Air resistance
    velocity += Offset(
      (Random().nextDouble() - 0.5) * 0.2,
      (Random().nextDouble() - 0.5) * 0.2,
    );
  }

  void update(double dt) {
    position += velocity * dt * 60; // Scale for 60fps
    z += velocity.dy * 0.2;
    z = z.clamp(0, 150);
    rotation += velocity.distance * 0.03;
  }

  void addRandomForce() {
    final r = Random();
    velocity += Offset(
      r.nextDouble() * 8 - 4,
      r.nextDouble() * 8 - 4,
    );
  }

  void setAsWinner() {
    isWinner = true;
    // Add special winner effects
    velocity += Offset(0, -2); // Slight upward movement
  }
}

// Custom painter for physics-based balls
class PhysicsKenoPainter extends CustomPainter {
  final List<PhysicsBall> balls;
  final Offset center;
  final double radius;
  final double cameraDistance;
  final String selectedBall;

  PhysicsKenoPainter({
    required this.balls,
    required this.center,
    required this.radius,
    required this.cameraDistance,
    required this.selectedBall,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sort balls by z-depth for proper rendering
    balls.sort((a, b) => a.z.compareTo(b.z));
    
    for (var ball in balls) {
      _drawBall(canvas, ball);
    }
  }

  void _drawBall(Canvas canvas, PhysicsBall ball) {
    final scale = 1 / (1 + ball.z / cameraDistance);
    final projected = (ball.position - center) * scale + center;
    final scaledRadius = ball.radius * scale;
    
    // Depth-based blur
    final blurAmount = (ball.z / 150) * 4;
    
    // Winner glow effect
    final isSelected = ball.number == selectedBall;
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: isSelected || ball.isWinner
            ? [
                Colors.white,
                Colors.amber,
                Colors.orange,
                Colors.red.withValues(alpha: 0.8),
              ]
            : [
                Colors.white,
                ball.color,
                ball.color.withValues(alpha: 0.8),
                ball.color.withValues(alpha: 0.6),
              ],
      ).createShader(Rect.fromCircle(
        center: projected,
        radius: scaledRadius,
      ))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);

    // Additional glow for selected ball
    if (isSelected || ball.isWinner) {
      final glowPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(projected, scaledRadius * 1.5, glowPaint);
    }

    canvas.save();
    canvas.translate(projected.dx, projected.dy);
    canvas.rotate(ball.rotation);
    canvas.translate(-projected.dx, -projected.dy);
    
    canvas.drawCircle(projected, scaledRadius, paint);
    
    // Draw number
    final textPainter = TextPainter(
      text: TextSpan(
        text: ball.number,
        style: GoogleFonts.orbitron(
          fontSize: scaledRadius * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      projected - Offset(textPainter.width / 2, textPainter.height / 2),
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Extension for vector math operations
extension VectorMath on Offset {
  double dot(Offset other) => dx * other.dx + dy * other.dy;
  Offset operator *(double scalar) => Offset(dx * scalar, dy * scalar);
  Offset operator /(double scalar) => Offset(dx / scalar, dy / scalar);
}