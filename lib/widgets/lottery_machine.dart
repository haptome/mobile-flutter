// Purpose: Premium 3D immersive lottery machine with advanced effects
// Author: Auto-generated

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lottery_ball.dart';

class LotteryMachine extends StatefulWidget {
  final List<LotteryBall> balls;
  final bool isDrawing;
  final String selectedBall;
  final VoidCallback? onDrawComplete;

  const LotteryMachine({
    super.key,
    required this.balls,
    this.isDrawing = false,
    this.selectedBall = '',
    this.onDrawComplete,
  });

  @override
  State<LotteryMachine> createState() => _LotteryMachineState();
}

class _LotteryMachineState extends State<LotteryMachine>
    with TickerProviderStateMixin {
  // Core animation controllers
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _celebrationController;
  late AnimationController _ledController;
  late AnimationController _sphereController;
  
  // Animations
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _ledAnimation;
  late Animation<double> _sphereAnimation;
  
  // Particle system
  List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _ledController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sphereController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Create animations with advanced curves
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 8 * pi, // Multiple rotations for dramatic effect
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOutSine,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _ledAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ledController,
      curve: Curves.easeInOut,
    ));
    
    _sphereAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sphereController,
      curve: Curves.easeInOutQuart,
    ));
    
    // Initialize particle system
    _initializeParticles();
    
    // Start ambient animations
    _glowController.repeat(reverse: true);
    _ledController.repeat(reverse: true);
    _sphereController.repeat(reverse: true);
    
    if (widget.isDrawing) {
      _startPremiumAnimation();
    }
  }

  @override
  void didUpdateWidget(LotteryMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isDrawing && !oldWidget.isDrawing) {
      _startPremiumAnimation();
    } else if (!widget.isDrawing && oldWidget.isDrawing) {
      _stopPremiumAnimation();
    }
    
    // Trigger celebration when winner is selected
    if (widget.selectedBall.isNotEmpty && oldWidget.selectedBall.isEmpty) {
      _triggerCelebration();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _celebrationController.dispose();
    _ledController.dispose();
    _sphereController.dispose();
    super.dispose();
  }

  void _initializeParticles() {
    _particles = List.generate(50, (index) => Particle(
      position: Offset(
        _random.nextDouble() * 400 - 200,
        _random.nextDouble() * 400 - 200,
      ),
      velocity: Offset(
        _random.nextDouble() * 4 - 2,
        _random.nextDouble() * 4 - 2,
      ),
      color: Color.lerp(
        Colors.amber,
        Colors.orange,
        _random.nextDouble(),
      )!,
      size: _random.nextDouble() * 3 + 1,
      life: _random.nextDouble(),
    ));
  }

  void _startPremiumAnimation() {
    // Haptic feedback for premium feel
    HapticFeedback.mediumImpact();
    
    _rotationController.forward(from: 0);
    _particleController.forward(from: 0);
    
    // Update particles during animation
    _particleController.addListener(_updateParticles);
  }

  void _stopPremiumAnimation() {
    _rotationController.stop();
    _particleController.stop();
    _particleController.removeListener(_updateParticles);
  }

  void _triggerCelebration() {
    // Strong haptic feedback for winner selection
    HapticFeedback.heavyImpact();
    
    _celebrationController.forward(from: 0);
    
    // Generate celebration particles
    _particles.addAll(List.generate(30, (index) => Particle(
      position: const Offset(0, 0), // Center of machine
      velocity: Offset(
        _random.nextDouble() * 8 - 4,
        _random.nextDouble() * 8 - 4,
      ),
      color: Colors.amber,
      size: _random.nextDouble() * 5 + 2,
      life: 1.0,
    )));
    
    // Call completion callback
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onDrawComplete?.call();
    });
  }

  void _updateParticles() {
    setState(() {
      for (var particle in _particles) {
        particle.update();
      }
      _particles.removeWhere((particle) => particle.life <= 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Reduced from 320
      height: 420, // Reduced from 450
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particle system background
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 420), // Reduced to match overall size
                painter: ParticlePainter(_particles, _particleAnimation.value),
              );
            },
          ),
          
          // Premium machine base with advanced glow
          AnimatedBuilder(
            animation: Listenable.merge([_glowAnimation, _sphereAnimation]),
            builder: (context, child) {
              return Container(
                width: 280, // Reduced to match overall size
                height: 390, // Reduced to match overall size
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyan.withValues(alpha: 0.4 * _glowAnimation.value),
                      Colors.blue.withValues(alpha: 0.3 * _glowAnimation.value),
                      Colors.purple.withValues(alpha: 0.2 * _sphereAnimation.value),
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
                    // LED strip effects
                    _buildLEDStrips(),
                    // Premium chrome details
                    _buildChromeDetails(),
                  ],
                ),
              );
            },
          ),
          
          // Premium glass sphere with 3D effects
          Container(
            width: 260,
            height: 260,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  // 3D Balls container with enhanced physics
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateX(0.2) // 3D tilt
                          ..rotateY(widget.isDrawing ? _rotationAnimation.value * 0.3 : 0)
                          ..rotateZ(widget.isDrawing ? _rotationAnimation.value : 0),
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            children: widget.balls.map((ball) {
                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 150),
                                left: 130 + ball.position.dx - 18,
                                top: 130 + ball.position.dy - 18,
                                child: Premium3DBallWidget(
                                  ball: ball,
                                  isSelected: ball.number == widget.selectedBall,
                                  celebrationValue: _celebrationAnimation.value,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Premium glass reflections and refractions
                  _buildGlassEffects(),
                ],
              ),
            ),
          ),
          
          // Premium machine top with chrome finish
          Positioned(
            top: 0,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.grey.shade300,
                    Colors.grey.shade600,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          
          // Premium machine base with branding
          Positioned(
            bottom: 0,
            child: Container(
              width: 300, // Reduced to match overall size
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
                  Text(
                    'PREMIUM LOTTERY',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MACHINE',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status indicator LEDs
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
      ),
    );
  }

  Widget _buildLEDStrips() {
    return AnimatedBuilder(
      animation: _ledAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
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
                // Side LED strips
                Positioned(
                  top: 50,
                  bottom: 50,
                  left: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyan.withValues(alpha: _ledAnimation.value),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.5 * _ledAnimation.value),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
                Positioned(
                  top: 50,
                  bottom: 50,
                  right: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyan.withValues(alpha: _ledAnimation.value),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.5 * _ledAnimation.value),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChromeDetails() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassEffects() {
    return Stack(
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
        // Secondary reflection
        Positioned(
          top: 60,
          right: 40,
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Caustic light patterns
        Positioned(
          bottom: 40,
          left: 60,
          child: AnimatedBuilder(
            animation: _sphereAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _sphereAnimation.value * 2 * pi,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyan.withValues(alpha: 0.4 * _sphereAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

class Premium3DBallWidget extends StatelessWidget {
  final LotteryBall ball;
  final bool isSelected;
  final double celebrationValue;

  const Premium3DBallWidget({
    super.key,
    required this.ball,
    this.isSelected = false,
    this.celebrationValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 36,
      height: 36,
      child: Transform.scale(
        scale: isSelected ? 1.0 + (celebrationValue * 0.3) : 1.0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: isSelected
                  ? [
                      Colors.white,
                      Colors.amber.withValues(alpha: 0.9),
                      Colors.orange.withValues(alpha: 0.8),
                      Colors.red.withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.white,
                      ball.color.withValues(alpha: 0.9),
                      ball.color.withValues(alpha: 0.7),
                      ball.color.withValues(alpha: 0.5),
                    ],
            ),
            boxShadow: [
              // Main shadow
              BoxShadow(
                color: isSelected
                    ? Colors.amber.withValues(alpha: 0.8)
                    : ball.color.withValues(alpha: 0.6),
                blurRadius: isSelected ? 20 + (celebrationValue * 10) : 12,
                spreadRadius: isSelected ? 4 + (celebrationValue * 2) : 2,
              ),
              // Inner glow
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: -2,
              ),
              // Depth shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ball highlight
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Number text
              Center(
                child: Text(
                  ball.number,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle system for premium effects
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;
  final double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
  }) : maxLife = life;

  void update() {
    position += velocity;
    velocity *= 0.98; // Friction
    life -= 0.02;
    
    // Gravity effect
    velocity = Offset(velocity.dx, velocity.dy + 0.1);
  }

  double get alpha => (life / maxLife).clamp(0.0, 1.0);
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.life > 0) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: particle.alpha * animationValue)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            size.width / 2 + particle.position.dx,
            size.height / 2 + particle.position.dy,
          ),
          particle.size * particle.alpha,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}