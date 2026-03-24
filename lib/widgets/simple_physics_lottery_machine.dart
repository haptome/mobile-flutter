// Purpose: Advanced Keno-style lottery machine with realistic physics
// Author: Auto-generated

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lottery_ball.dart';
import '../core/theme/app_colors.dart';

class SimplePhysicsLotteryMachine extends StatefulWidget {
  final List<LotteryBall> balls;
  final bool isDrawing;
  final String selectedBall;
  final VoidCallback? onDrawComplete;

  const SimplePhysicsLotteryMachine({
    super.key,
    required this.balls,
    this.isDrawing = false,
    this.selectedBall = '',
    this.onDrawComplete,
  });

  @override
  State<SimplePhysicsLotteryMachine> createState() => _SimplePhysicsLotteryMachineState();
}

class _SimplePhysicsLotteryMachineState extends State<SimplePhysicsLotteryMachine>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  final List<PhysicsBall> physicsBalls = [];
  final double sphereRadius = 140;
  late Offset center;
  PhysicsBall? exitingBall;
  bool exitMode = false;
  
  // Enhanced animation controllers for production-grade effects
  late AnimationController _glowController;
  late AnimationController _ledController;
  late AnimationController _airFlowController;
  late AnimationController _machineVibrateController;
  late Animation<double> _glowAnimation;
  late Animation<double> _ledAnimation;
  late Animation<double> _airFlowAnimation;
  late Animation<double> _vibrateAnimation;
  
  // Keno machine state
  bool _isInDrawMode = false;
  double _airPressure = 0.0;
  final List<Offset> _airVents = [];
  Timer? _drawSequenceTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeBalls();
    _initializeAirVents();
    _ticker = createTicker(_update)..start();
  }

  void _initializeAnimations() {
    // Main glow effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // LED status indicators
    _ledController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Air flow simulation
    _airFlowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Machine vibration during draw
    _machineVibrateController = AnimationController(
      duration: const Duration(milliseconds: 100),
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
    
    _airFlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _airFlowController,
      curve: Curves.easeInOutQuad,
    ));
    
    _vibrateAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _machineVibrateController,
      curve: Curves.elasticInOut,
    ));
    
    // Start ambient animations
    _glowController.repeat(reverse: true);
    _ledController.repeat(reverse: true);
  }

  void _initializeAirVents() {
    // Create air vent positions around the sphere
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi) / 8;
      _airVents.add(Offset(
        cos(angle) * (sphereRadius - 20),
        sin(angle) * (sphereRadius - 20),
      ));
    }
  }

  void _initializeBalls() {
    print('🎰 MACHINE DEBUG: _initializeBalls called with ${widget.balls.length} balls');
    physicsBalls.clear();
    
    if (widget.balls.isEmpty) {
      print('🎰 MACHINE DEBUG: No balls provided, skipping initialization');
      return;
    }
    
    for (int i = 0; i < widget.balls.length; i++) {
      final ball = widget.balls[i];
      final r = Random();
      
      // Position balls at the bottom of the sphere with better visibility
      // Use a more spread out pattern for better visibility
      final angle = (i * 2 * pi / widget.balls.length) + (r.nextDouble() * 0.3);
      final bottomRadius = sphereRadius * 0.4; // Smaller radius for better clustering
      final bottomY = sphereRadius * 0.4; // Higher up for better visibility
      
      // Create ball with realistic bottom positioning
      final physicsBall = PhysicsBall(
        position: Offset(
          cos(angle) * (bottomRadius * 0.5 + r.nextDouble() * bottomRadius * 0.3), // More controlled spread
          bottomY + (r.nextDouble() * 30), // Slightly more vertical spread
        ),
        velocity: Offset.zero, // Start stationary
        z: 0.0, // On ground
        number: ball.number,
        color: _getEnhancedBallColor(ball.color, ball.number), // Enhanced colors for visibility
      );
      
      // Ensure ball starts in stationary state
      physicsBall.isStationary = true;
      physicsBall.isOnGround = true;
      
      physicsBalls.add(physicsBall);
    }
    
    print('🎰 MACHINE DEBUG: Created ${physicsBalls.length} physics balls at bottom with enhanced colors');
  }

  /// Enhanced ball colors for better visibility against brand background
  Color _getEnhancedBallColor(Color originalColor, String number) {
    final int numValue = int.tryParse(number) ?? 0;
    
    // Use high-contrast colors that work well against dark teal background
    final enhancedColors = [
      const Color(0xFFFFD700), // Bright gold
      const Color(0xFFFF6B35), // Bright orange
      const Color(0xFF00E676), // Bright green
      const Color(0xFF2196F3), // Bright blue
      const Color(0xFFE91E63), // Bright pink
      const Color(0xFF9C27B0), // Bright purple
      const Color(0xFFFF9800), // Bright amber
      const Color(0xFF4CAF50), // Bright green
      const Color(0xFFFF5722), // Deep orange
      const Color(0xFF03DAC6), // Bright cyan
      const Color(0xFFFFEB3B), // Bright yellow
      const Color(0xFFFF1744), // Bright red
      const Color(0xFF00BCD4), // Bright cyan
      const Color(0xFF8BC34A), // Light green
      const Color(0xFFFF4081), // Pink accent
    ];
    
    return enhancedColors[numValue % enhancedColors.length];
  }

  @override
  void didUpdateWidget(SimplePhysicsLotteryMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    print('🎰 MACHINE DEBUG: didUpdateWidget called');
    print('🎰 MACHINE DEBUG: widget.isDrawing = ${widget.isDrawing}, oldWidget.isDrawing = ${oldWidget.isDrawing}');
    print('🎰 MACHINE DEBUG: widget.balls.length = ${widget.balls.length}, oldWidget.balls.length = ${oldWidget.balls.length}');
    
    if (widget.balls.length != oldWidget.balls.length) {
      print('🎰 MACHINE DEBUG: Reinitializing balls');
      _initializeBalls();
    }
    
    if (widget.isDrawing && !oldWidget.isDrawing) {
      print('🎰 MACHINE DEBUG: Starting Keno draw sequence');
      _startKenoDrawSequence();
    } else if (!widget.isDrawing && oldWidget.isDrawing) {
      print('🎰 MACHINE DEBUG: Stopping Keno draw sequence');
      _stopKenoDrawSequence();
    }
    
    if (widget.selectedBall.isNotEmpty && oldWidget.selectedBall.isEmpty) {
      print('🎰 MACHINE DEBUG: Triggering winner selection');
      _triggerWinnerSelection();
    }
  }

  void _startKenoDrawSequence() {
    HapticFeedback.mediumImpact();
    
    // Total animation duration: 4000ms (4 seconds)
    // Air pressure will smoothly increase from 0 to 2.0 over this period
    
    _airFlowController.forward();
    _machineVibrateController.repeat();
    
    // Start air pressure animation - smooth progression over 4 seconds
    _animateAirPressure();
    
    // Phase timings within 4 seconds:
    // 0-1000ms: Gradual pressure buildup (0 → 1.0)
    Timer(const Duration(milliseconds: 1000), () {
      for (var ball in physicsBalls) {
        ball.addAirForce(_airPressure);
      }
    });
    
    // 1000-2500ms: Peak pressure phase (1.0 → 2.0)
    Timer(const Duration(milliseconds: 2500), () {
      for (var ball in physicsBalls) {
        ball.addTurbulence();
        ball.addRandomForce();
      }
    });
    
    // 2500-4000ms: Pressure reduction for selection (2.0 → 0.5)
    Timer(const Duration(milliseconds: 4000), () {
      _airPressure = 0.5; // Final selection pressure
      for (var ball in physicsBalls) {
        ball.prepareForSelection();
      }
    });
  }

  void _animateAirPressure() {
    // Smooth air pressure animation over 4 seconds
    const totalDuration = 4000; // 4 seconds in milliseconds
    const updateInterval = 50; // Update every 50ms for smooth animation
    int elapsed = 0;
    
    _drawSequenceTimer = Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      elapsed += updateInterval;
      
      if (elapsed >= totalDuration) {
        timer.cancel();
        return;
      }
      
      // Calculate pressure based on animation curve
      final progress = elapsed / totalDuration;
      _airPressure = _calculatePressureCurve(progress);
      
      // Update machine state
      _isInDrawMode = _airPressure > 0.1;
    });
  }

  double _calculatePressureCurve(double progress) {
    // Custom pressure curve for realistic animation
    if (progress <= 0.25) {
      // 0-1s: Gradual buildup (0 → 1.0)
      return progress * 4.0; // Linear increase to 1.0
    } else if (progress <= 0.625) {
      // 1-2.5s: Peak pressure (1.0 → 2.0)
      final phaseProgress = (progress - 0.25) / 0.375;
      return 1.0 + phaseProgress; // Linear increase from 1.0 to 2.0
    } else {
      // 2.5-4s: Pressure reduction (2.0 → 0.5)
      final phaseProgress = (progress - 0.625) / 0.375;
      return 2.0 - (1.5 * phaseProgress); // Linear decrease from 2.0 to 0.5
    }
  }

  void _stopKenoDrawSequence() {
    _isInDrawMode = false;
    _airPressure = 0.0;
    _airFlowController.reverse();
    _machineVibrateController.stop();
    _drawSequenceTimer?.cancel();
    
    // Allow balls to settle naturally with gravity to the bottom
    // They will become stationary automatically when air pressure drops
    
    // After a delay, ensure all balls settle to bottom
    Timer(const Duration(seconds: 2), () {
      _settleBallsToBottom();
    });
  }

  void _settleBallsToBottom() {
    for (var ball in physicsBalls) {
      if (!ball.isWinner) {
        ball.resetToGround();
        // resetToGround() already handles positioning, no need to set position again
      }
    }
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
        
        // Create dramatic winner effect
        _createWinnerCelebration(ball);
        break;
      }
    }
    
    // Trigger completion callback after animation
    Future.delayed(const Duration(seconds: 3), () {
      widget.onDrawComplete?.call();
    });
  }

  void _createWinnerCelebration(PhysicsBall winnerBall) {
    // Stop all other balls gradually
    for (var ball in physicsBalls) {
      if (ball != winnerBall) {
        ball.slowDown();
      }
    }
    
    // Create spotlight effect on winner
    winnerBall.addSpotlightEffect();
    
    // Haptic celebration sequence
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (timer.tick > 5) {
        timer.cancel();
        return;
      }
      HapticFeedback.lightImpact();
    });
  }

  void _update(Duration d) {
    const dt = 0.016;
    
    // Apply air flow effects during draw
    if (_isInDrawMode) {
      _applyAirFlowEffects();
    }
    
    for (var ball in physicsBalls) {
      // Use new physics system that includes gravity and stationary states
      ball.applyPhysics(dt, _airPressure);
      ball.update(dt);
      _handleWallCollision(ball);
      
      // Apply air vent forces only if ball is not stationary
      if (_isInDrawMode && !ball.isStationary) {
        _applyAirVentForces(ball);
      }
    }
    
    _handleBallCollisions();
    
    if (exitMode && exitingBall != null) {
      _animateWinnerExit(exitingBall!);
    }
    
    setState(() {});
  }

  void _applyAirFlowEffects() {
    final flowStrength = _airFlowAnimation.value * _airPressure;
    
    for (var ball in physicsBalls) {
      // Create swirling air currents (more intense)
      final angle = DateTime.now().millisecondsSinceEpoch * 0.002; // Faster swirl
      final swirl = Offset(
        cos(angle + ball.position.dx * 0.02) * flowStrength * 2, // Doubled strength
        sin(angle + ball.position.dy * 0.02) * flowStrength * 2, // Doubled strength
      );
      ball.velocity += swirl * 1.0; // Doubled application
    }
  }

  void _applyAirVentForces(PhysicsBall ball) {
    for (var vent in _airVents) {
      final ventPos = center + vent;
      final distance = (ball.position - ventPos).distance;
      
      if (distance < 60) { // Increased range
        final force = (ventPos - ball.position).normalized() * (_airPressure * 4); // Doubled force
        ball.velocity += force * 0.6; // Increased force application
      }
    }
  }

  void _handleWallCollision(PhysicsBall ball) {
    // Skip wall collision for stationary balls
    if (ball.isStationary) return;
    
    final toCenter = ball.position - center;
    final dist = toCenter.distance;
    
    if (dist + ball.radius > sphereRadius) {
      final normal = toCenter / dist;
      ball.velocity -= normal * (2.2 * ball.velocity.dot(normal)); // Increased bounce energy
      ball.position = center + normal * (sphereRadius - ball.radius);
      
      // Add some random energy to wall bounces
      final r = Random();
      ball.velocity += Offset(
        (r.nextDouble() - 0.5) * 1.5,
        (r.nextDouble() - 0.5) * 1.5,
      );
      
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
        
        // Skip collision if both balls are stationary
        if (a.isStationary && b.isStationary) continue;
        
        final delta = b.position - a.position;
        final dist = delta.distance;
        final minDist = a.radius + b.radius;
        
        if (dist < minDist && dist > 0) {
          final normal = delta / dist;
          final relVel = a.velocity - b.velocity;
          final speed = relVel.dot(normal);
          
          if (speed < 0) continue;
          
          final impulse = normal * speed * 0.9; // Increased bounce factor for more energy
          
          // Wake up stationary balls on collision
          if (a.isStationary) {
            a.isStationary = false;
            a.isOnGround = false;
          }
          if (b.isStationary) {
            b.isStationary = false;
            b.isOnGround = false;
          }
          
          a.velocity -= impulse;
          b.velocity += impulse;
          
          // Separate balls to prevent overlap
          final overlap = minDist - dist;
          final separation = normal * (overlap * 0.5);
          a.position -= separation;
          b.position += separation;
          
          // Add some random energy to collisions for more chaos
          final r = Random();
          final randomBoost = Offset(
            (r.nextDouble() - 0.5) * 2,
            (r.nextDouble() - 0.5) * 2,
          );
          a.velocity += randomBoost;
          b.velocity -= randomBoost;
        }
      }
    }
  }

  void _animateWinnerExit(PhysicsBall ball) {
    // Create dramatic exit trajectory
    final exitPoint = Offset(center.dx, center.dy - sphereRadius - 50);
    final dir = exitPoint - ball.position;
    
    if (dir.distance > 5) {
      // Faster acceleration towards exit
      ball.velocity = ball.velocity * 0.9 + dir.normalized() * 5.0; // Increased exit speed
    } else {
      // Ball has reached exit point
      ball.position = exitPoint;
      ball.velocity = Offset.zero;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _glowController.dispose();
    _ledController.dispose();
    _airFlowController.dispose();
    _machineVibrateController.dispose();
    _drawSequenceTimer?.cancel();
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
                      // gradient: LinearGradient(
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   // colors: [
                      //   //   AppColors.primary.withValues(alpha: 0.4 * _glowAnimation.value), // Brand yellow-green
                      //   //   AppColors.lightTextPrimary.withValues(alpha: 0.3 * _glowAnimation.value), // Teal
                      //   //   AppColors.splashBackground.withValues(alpha: 0.2 * _glowAnimation.value), // Dark teal
                      //   //   Colors.black.withValues(alpha: 0.9),
                      //   // ],
                      // ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: AppColors.primary.withValues(alpha: 0.5 * _glowAnimation.value), // Brand glow
                      //     blurRadius: 30,
                      //     spreadRadius: 8,
                      //   ),
                      //   BoxShadow(
                      //     color: AppColors.lightTextPrimary.withValues(alpha: 0.3 * _glowAnimation.value), // Teal glow
                      //     blurRadius: 50,
                      //     spreadRadius: 15,
                      //   ),
                      // ],
                    ),
                  );
                },
              ),
              
              // Physics-based ball container with enhanced effects
              AnimatedBuilder(
                animation: Listenable.merge([_airFlowAnimation, _vibrateAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _vibrateAnimation.value * (_isInDrawMode ? 2 : 0),
                      _vibrateAnimation.value * (_isInDrawMode ? 1 : 0),
                    ),
                    child: ClipOval(
                      child: Container(
                        width: sphereRadius * 2,
                        height: sphereRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.3),
                            colors: [
                              
                              Colors.white.withValues(alpha: 0.15 + (_airFlowAnimation.value * 0.1)),
                              Colors.white.withValues(alpha: 0.08 + (_airFlowAnimation.value * 0.05)),
                              AppColors.primary.withValues(alpha: 0.05 + (_airFlowAnimation.value * 0.1)), // Brand color
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4 + (_airFlowAnimation.value * 0.2)),
                            width: 3,
                          ),
                          boxShadow: _isInDrawMode ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3 * _airFlowAnimation.value), // Brand glow
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ] : null,
                        ),
                        child: CustomPaint(
                          size: Size(sphereRadius * 2, sphereRadius * 2),
                          painter: SimplePhysicsKenoPainter(
                            balls: physicsBalls,
                            center: Offset(sphereRadius, sphereRadius),
                            radius: sphereRadius,
                            selectedBall: widget.selectedBall,
                            airPressure: _airPressure,
                            airVents: _airVents,
                            vibrateOffset: _vibrateAnimation.value * (_isInDrawMode ? 1 : 0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
              //     height: 78,
              //     decoration: BoxDecoration(
              //       borderRadius: const BorderRadius.vertical(
              //         top: Radius.circular(40),
              //       ),
              //       gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           Colors.white.withValues(alpha: 0.9),
              //           Colors.grey.shade300.withValues(alpha: 0.9),
              //           Colors.grey.shade600.withValues(alpha: 0.9),
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
              
              // Enhanced machine base with status display
              Positioned(
                bottom: 0,
                child: Container(
                  width: 300,
                  height: 40,
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
                      // Text(
                      //   'LOTTERY MACHINE',
                      //   style: GoogleFonts.orbitron(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: AppColors.primary, // Brand yellow-green
                      //     letterSpacing: 3,
                      //   ),
                      // ),
                      // const SizedBox(height: 2),
                      // // Text(
                      // //   'LOTTERY MACHINE',
                      // //   style: GoogleFonts.orbitron(
                      // //     fontSize: 10,
                      // //     fontWeight: FontWeight.w600,
                      // //     color: Colors.white70,
                      // //     letterSpacing: 2,
                      // //   ),
                      // // ),
                      // const SizedBox(height: 6),
                      
                      // Enhanced status display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusIndicator('READY', AppColors.primary, !widget.isDrawing && widget.selectedBall.isEmpty),
                          const SizedBox(width: 12),
                          _buildStatusIndicator('DRAW', AppColors.lightTextPrimary, widget.isDrawing),
                          const SizedBox(width: 12),
                          _buildStatusIndicator('WIN', AppColors.splashBackground, widget.selectedBall.isNotEmpty),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Air pressure indicator with smooth animation
                      Container(
                        width: 200,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey.shade800,
                        ),
                        child: AnimatedBuilder(
                          animation: _airFlowAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (_airPressure / 2.0).clamp(0.0, 1.0), // Scale to max pressure of 2.0
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: _airPressure < 1.0 
                                        ? [AppColors.primary, AppColors.lightTextPrimary] // Low pressure - brand colors
                                        : _airPressure < 1.5
                                            ? [AppColors.lightTextPrimary, AppColors.splashBackground] // Medium pressure  
                                            : [AppColors.splashBackground, AppColors.primary], // High pressure
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Pressure value display
                      // Text(
                      //   'Air Pressure: ${_airPressure.toStringAsFixed(1)}',
                      //   style: GoogleFonts.orbitron(
                      //     fontSize: 8,
                      //     color: _airPressure > 0 ? AppColors.primary : Colors.grey.shade600, // Brand color when active
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
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

  Widget _buildStatusIndicator(String label, Color color, bool isActive) {
    return AnimatedBuilder(
      animation: _ledAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Enhanced physics-based ball class with realistic gravity and air pressure physics
class PhysicsBall {
  Offset position;
  Offset velocity;
  double z;
  final String number;
  double radius = 12;
  double rotation = 0;
  bool isWinner = false;
  Color color;
  
  // Enhanced physics properties
  double airResistance = 0.995;
  double bounceDamping = 0.8;
  bool hasSpotlight = false;
  double spotlightIntensity = 0.0;
  double shine = 0.0;
  Offset lastPosition = Offset.zero;
  double speed = 0.0;
  bool isSlowingDown = false;
  
  // Realistic physics constants
  static const double gravity = 9.8; // Gravity acceleration
  static const double groundFriction = 0.95; // Friction when on ground
  static const double minMovementThreshold = 0.1; // Minimum velocity to consider moving
  
  // Physics state
  bool isOnGround = false;
  bool isStationary = false;
  double groundLevel = 0.0;

  PhysicsBall({
    required this.position,
    required this.velocity,
    required this.z,
    required this.number,
    required this.color,
  }) {
    lastPosition = position;
    groundLevel = 0.0; // Bottom of the sphere
  }

  factory PhysicsBall.fromLotteryBall(LotteryBall lotteryBall, int index) {
    final r = Random();
    
    // Position balls at the bottom of the sphere in a visible pattern
    final angle = (index * 2 * pi / 25) + (r.nextDouble() * 0.3); // Spread around bottom
    final bottomRadius = 80.0; // Smaller radius for better visibility
    
    // Start balls at rest on the bottom of the sphere in visible area
    return PhysicsBall(
      position: Offset(
        cos(angle) * (bottomRadius * 0.7), // Controlled spread at bottom
        60 + (r.nextDouble() * 40), // Bottom area between y=60 and y=100
      ),
      velocity: Offset.zero, // Start completely stationary
      z: 0.0, // Start on ground level
      number: lotteryBall.number,
      color: lotteryBall.color,
    );
  }

  void applyPhysics(double dt, [double airPressure = 0.0]) {
    // Apply gravity first
    _applyGravity(dt);
    
    // Apply air effects based on pressure
    _applyAirEffects(airPressure);
    
    // Check if ball should be stationary
    _checkStationaryState(airPressure);
    
    // Apply ground physics
    _applyGroundPhysics();
  }

  void _applyGravity(double dt) {
    if (!isOnGround && !isStationary) {
      // Apply downward gravitational force
      velocity = Offset(velocity.dx, velocity.dy + gravity * dt * 10); // Scale for screen coordinates
    }
  }

  void _applyAirEffects(double airPressure) {
    if (airPressure > 0) {
      // Air pressure creates upward and turbulent forces
      final upwardForce = airPressure * 15; // Strong upward force
      velocity = Offset(velocity.dx, velocity.dy - upwardForce);
      
      // Add turbulence based on air pressure
      velocity += Offset(
        (Random().nextDouble() - 0.5) * airPressure * 2.0,
        (Random().nextDouble() - 0.5) * airPressure * 2.0,
      );
      
      // Reduce air resistance when air pressure is high
      final resistance = airResistance + (airPressure * 0.01);
      velocity *= resistance;
    } else {
      // Strong resistance when no air pressure - balls settle quickly
      velocity *= 0.92;
    }
  }

  void _checkStationaryState(double airPressure) {
    // Ball becomes stationary when:
    // 1. No air pressure
    // 2. Low velocity
    // 3. Near the bottom of the sphere
    final isNearBottom = position.dy > 50; // Check if in bottom half of sphere
    
    if (airPressure <= 0.1 && speed < minMovementThreshold && isNearBottom) {
      isStationary = true;
      velocity = Offset.zero;
      isOnGround = true;
      
      // Keep current position but ensure it's visible - don't reposition randomly
      // Just clamp to ensure it stays in visible area
      final clampedX = position.dx.clamp(-100.0, 100.0);
      final clampedY = position.dy.clamp(30.0, 120.0); // Keep in visible bottom area
      position = Offset(clampedX, clampedY);
    } else if (airPressure > 0.1) {
      isStationary = false; // Wake up when air pressure returns
    }
  }

  void _applyGroundPhysics() {
    // Calculate distance from sphere center
    final distanceFromCenter = position.distance;
    
    // Check if ball is at the bottom of the sphere
    if (distanceFromCenter >= (140 - radius)) { // 140 is sphere radius
      // Ball is touching the sphere wall - treat as ground
      isOnGround = true;
      
      // Calculate normal from center to ball position
      final normal = position.distance > 0 ? position / position.distance : Offset(0, 1);
      
      // Position ball just inside the sphere
      position = normal * (140 - radius);
      
      // Apply ground bounce with energy loss
      final velocityDotNormal = velocity.dx * normal.dx + velocity.dy * normal.dy;
      if (velocityDotNormal > 0) {
        // Reflect velocity with damping
        velocity = Offset(
          velocity.dx - 2 * velocityDotNormal * normal.dx,
          velocity.dy - 2 * velocityDotNormal * normal.dy,
        ) * bounceDamping;
        
        // Apply friction
        velocity *= groundFriction;
      }
    } else {
      isOnGround = false;
    }
  }

  void applyAir([double airPressure = 0.0]) {
    // This method is kept for compatibility but now uses the new physics system
    applyPhysics(0.016, airPressure);
  }

  void update(double dt) {
    lastPosition = position;
    
    // Only update position if not stationary
    if (!isStationary) {
      position += velocity * dt * 90;
      z += velocity.dy * 0.3;
      z = z.clamp(0, 100);
      
      // Calculate speed for effects
      speed = velocity.distance;
      
      // Update rotation based on movement (faster rotation)
      rotation += speed * 0.08;
      
      // Update shine effect
      shine = (speed / 8).clamp(0, 1);
    } else {
      // Stationary balls have no movement
      speed = 0.0;
      shine = 0.0;
      // Keep slight rotation for visual appeal
      rotation += 0.001;
    }
    
    // Apply slowing down effect
    if (isSlowingDown && !isStationary) {
      velocity *= 0.96;
    }
    
    // Update spotlight effect
    if (hasSpotlight) {
      spotlightIntensity = (spotlightIntensity + 0.08).clamp(0, 1);
    }
  }

  void addAirForce(double pressure) {
    if (pressure > 0) {
      isStationary = false; // Wake up the ball
      isOnGround = false; // Lift off ground
      final r = Random();
      velocity += Offset(
        r.nextDouble() * pressure * 12 - pressure * 6,
        r.nextDouble() * pressure * 12 - pressure * 6,
      );
    }
  }

  void addTurbulence() {
    isStationary = false; // Wake up the ball
    isOnGround = false; // Lift off ground
    final r = Random();
    velocity += Offset(
      r.nextDouble() * 20 - 10,
      r.nextDouble() * 20 - 10,
    );
  }

  void prepareForSelection() {
    // Reduce velocity for selection phase but don't make stationary
    velocity *= 0.7;
  }

  void setAsWinner() {
    isWinner = true;
    hasSpotlight = true;
    isStationary = false; // Ensure winner ball moves
    isOnGround = false; // Lift off ground
    
    // Add dramatic upward movement with more force
    velocity += const Offset(0, -8);
    
    // Add some random dramatic movement
    final r = Random();
    velocity += Offset(
      (r.nextDouble() - 0.5) * 6,
      (r.nextDouble() - 0.5) * 3,
    );
  }

  void addSpotlightEffect() {
    hasSpotlight = true;
    spotlightIntensity = 0.0;
  }

  void slowDown() {
    isSlowingDown = true;
  }

  void addRandomForce() {
    isStationary = false; // Wake up the ball
    isOnGround = false; // Lift off ground
    final r = Random();
    velocity += Offset(
      r.nextDouble() * 16 - 8,
      r.nextDouble() * 16 - 8,
    );
  }

  /// Reset ball to stationary ground state at bottom of sphere
  void resetToGround() {
    velocity = Offset.zero;
    z = 0.0;
    isOnGround = true;
    isStationary = true;
    speed = 0.0;
    shine = 0.0;
    rotation = 0.0;
    
    // Position at bottom of sphere in a visible area
    final r = Random();
    final angle = r.nextDouble() * 2 * pi; // Random angle around bottom
    final bottomRadius = 80.0; // Smaller radius for better visibility
    
    position = Offset(
      cos(angle) * (bottomRadius * 0.7), // Controlled spread at bottom
      60 + (r.nextDouble() * 40), // Bottom area between y=60 and y=100
    );
  }

  /// Check if ball is effectively at rest
  bool get isAtRest => isStationary || (speed < minMovementThreshold && isOnGround);
}

// Advanced Keno machine painter with production-grade effects
class SimplePhysicsKenoPainter extends CustomPainter {
  final List<PhysicsBall> balls;
  final Offset center;
  final double radius;
  final String selectedBall;
  final double airPressure;
  final List<Offset> airVents;
  final double vibrateOffset;

  SimplePhysicsKenoPainter({
    required this.balls,
    required this.center,
    required this.radius,
    required this.selectedBall,
    this.airPressure = 0.0,
    this.airVents = const [],
    this.vibrateOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply machine vibration
    canvas.save();
    canvas.translate(vibrateOffset, vibrateOffset * 0.5);
    
    // Draw air flow effects
    if (airPressure > 0) {
      _drawAirFlow(canvas);
    }
    
    // Draw air vents
    _drawAirVents(canvas);
    
    // Sort balls by z-depth for proper rendering
    balls.sort((a, b) => a.z.compareTo(b.z));
    
    // Draw ball trails for fast-moving balls
    for (var ball in balls) {
      if (ball.speed > 5) {
        _drawBallTrail(canvas, ball);
      }
    }
    
    // Draw balls with enhanced effects
    for (var ball in balls) {
      _drawEnhancedBall(canvas, ball);
    }
    
    // Draw winner spotlight
    for (var ball in balls) {
      if (ball.hasSpotlight) {
        _drawSpotlight(canvas, ball);
      }
    }
    
    canvas.restore();
  }

  void _drawAirFlow(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1 * airPressure) // Brand color for air flow
      ..style = PaintingStyle.fill;
    
    // Draw swirling air patterns
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * pi / 12) + (DateTime.now().millisecondsSinceEpoch * 0.002);
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.9;
      
      final start = center + Offset(
        cos(angle) * startRadius,
        sin(angle) * startRadius,
      );
      final end = center + Offset(
        cos(angle + 0.5) * endRadius,
        sin(angle + 0.5) * endRadius,
      );
      
      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(
        center.dx + cos(angle + 0.25) * (startRadius + endRadius) / 2,
        center.dy + sin(angle + 0.25) * (startRadius + endRadius) / 2,
        end.dx,
        end.dy,
      );
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawAirVents(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    for (var vent in airVents) {
      final ventPos = center + vent;
      canvas.drawCircle(ventPos, 3, paint);
      
      // Draw air flow from vents
      if (airPressure > 0) {
        final flowPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.2 * airPressure) // Brand color for vent flow
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        
        for (int i = 0; i < 3; i++) {
          final angle = (i * 2 * pi / 3) + (DateTime.now().millisecondsSinceEpoch * 0.003);
          final flowEnd = ventPos + Offset(
            cos(angle) * 20 * airPressure,
            sin(angle) * 20 * airPressure,
          );
          canvas.drawLine(ventPos, flowEnd, flowPaint);
        }
      }
    }
  }

  void _drawBallTrail(Canvas canvas, PhysicsBall ball) {
    final trailPaint = Paint()
      ..color = ball.color.withValues(alpha: 0.3)
      ..strokeWidth = ball.radius * 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final trailLength = ball.speed * 2;
    final trailEnd = ball.position - ball.velocity.normalized() * trailLength;
    
    canvas.drawLine(ball.position, trailEnd, trailPaint);
  }

  void _drawEnhancedBall(Canvas canvas, PhysicsBall ball) {
    final projected = center + ball.position; // Add center offset for proper positioning
    final ballRadius = ball.radius;
    final isSelected = ball.number == selectedBall;
    
    // Enhanced ball rendering with multiple layers
    
    // 1. Outer glow for winner
    if (isSelected || ball.isWinner || ball.hasSpotlight) {
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.6 * ball.spotlightIntensity) // Brand color for winner glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(projected, ballRadius * 2, glowPaint);
    }
    
    // 2. Main ball gradient with high contrast colors
    final ballOpacity = ball.isStationary ? 0.9 : 1.0; // Keep stationary balls visible
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: isSelected || ball.isWinner
            ? [
                Colors.white.withValues(alpha: ballOpacity),
                AppColors.primary.withValues(alpha: ballOpacity), // Brand color for winner
                AppColors.lightTextPrimary.withValues(alpha: ballOpacity), // Teal for winner
                AppColors.splashBackground.withValues(alpha: 0.8 * ballOpacity), // Dark teal for winner
              ]
            : [
                Colors.white.withValues(alpha: 0.95 * ballOpacity), // Brighter highlight
                ball.color.withValues(alpha: ballOpacity),
                ball.color.withValues(alpha: 0.9 * ballOpacity), // Less fade
                ball.color.withValues(alpha: 0.8 * ballOpacity), // Keep more color
              ],
      ).createShader(Rect.fromCircle(
        center: projected,
        radius: ballRadius,
      ));

    canvas.save();
    canvas.translate(projected.dx, projected.dy);
    canvas.rotate(ball.rotation);
    canvas.translate(-projected.dx, -projected.dy);
    
    // Add a subtle border for better definition
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(projected, ballRadius, paint);
    canvas.drawCircle(projected, ballRadius, borderPaint);
    
    // 3. Shine effect for fast-moving balls with animation (not for stationary)
    if (ball.shine > 0.3 && !ball.isStationary) {
      final animatedShine = ball.shine * (0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch * 0.005));
      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: animatedShine * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      final shineOffset = projected + Offset(-ballRadius * 0.3, -ballRadius * 0.3);
      canvas.drawCircle(shineOffset, ballRadius * 0.4, shinePaint);
    }
    
    // 4. Stationary indicator (small shadow for grounded balls)
    if (ball.isStationary) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      final shadowOffset = projected + Offset(0, ballRadius * 0.8);
      canvas.drawOval(
        Rect.fromCenter(
          center: shadowOffset,
          width: ballRadius * 1.2,
          height: ballRadius * 0.4,
        ),
        shadowPaint,
      );
    }
    
    // 5. Number text with enhanced styling and better contrast
    final textPainter = TextPainter(
      text: TextSpan(
        text: ball.number,
        style: GoogleFonts.orbitron(
          fontSize: ballRadius * 0.7, // Slightly larger text
          fontWeight: FontWeight.bold,
          color: isSelected || ball.isWinner ? Colors.black87 : Colors.black87,
          shadows: [
            Shadow(
              color: Colors.white.withValues(alpha: 0.9), // Strong white shadow for contrast
              blurRadius: 1,
            ),
            Shadow(
              color: Colors.black.withValues(alpha: 0.3), // Subtle black shadow for depth
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
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

  void _drawSpotlight(Canvas canvas, PhysicsBall ball) {
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.8 * ball.spotlightIntensity),
          Colors.orange.withValues(alpha: 0.4 * ball.spotlightIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: ball.position,
        radius: ball.radius * 4,
      ));
    
    canvas.drawCircle(ball.position, ball.radius * 4, spotlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Extension for vector math operations
extension VectorMath on Offset {
  double dot(Offset other) => dx * other.dx + dy * other.dy;
  Offset operator *(double scalar) => Offset(dx * scalar, dy * scalar);
  Offset operator /(double scalar) => Offset(dx / scalar, dy / scalar);
  
  /// Returns a normalized version of this offset (unit vector)
  Offset normalized() {
    final dist = distance;
    return dist > 0 ? this / dist : Offset.zero;
  }
}