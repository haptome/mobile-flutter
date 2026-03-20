// Purpose: Premium 3D immersive lottery draw experience
// Author: Auto-generated

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/lottery_draw_controller.dart';
import '../../../widgets/simple_physics_lottery_machine.dart';
import '../../../core/theme/app_colors.dart';

class LotteryDrawPage extends StatefulWidget {
  const LotteryDrawPage({super.key});

  @override
  State<LotteryDrawPage> createState() => _LotteryDrawPageState();
}

class _LotteryDrawPageState extends State<LotteryDrawPage> {
  late LotteryDrawController controller;
  Timer? _countdownTimer;
  Duration? _timeUntilDraw;
  bool _showCountdownView = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LotteryDrawController());
    _initializeCountdown();
  }

  void _initializeCountdown() {
    final args = Get.arguments as Map<String, dynamic>?;
    final drawingTime = args?['drawingTime'] as DateTime?;

    if (drawingTime != null) {
      final now = DateTime.now();
      if (drawingTime.isAfter(now)) {
        _timeUntilDraw = drawingTime.difference(now);
        _showCountdownView = true;
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilDraw != null && _timeUntilDraw!.inSeconds > 0) {
          _timeUntilDraw = _timeUntilDraw! - Duration(seconds: 1);
        } else {
          timer.cancel();
          _timeUntilDraw = null;
          _showCountdownView = false;
          // Transition to drawing animation
          _transitionToDrawing();
        }
      });
    });
  }

  void _transitionToDrawing() {
    // Start the drawing animation
    if (mounted) {
      controller.startDraw();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // Show countdown view if arriving early before drawing
    if (_showCountdownView && _timeUntilDraw != null) {
      return _buildCountdownView(context);
    }

    return Scaffold(
      backgroundColor: AppColors.splashBackground, // Brand dark teal background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Colors.orange, Colors.red],
          ).createShader(bounds),
          child: Text(
            'Lottery Draw',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.amber,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.splashBackground.withValues(alpha: 0.9), // Dark teal
              AppColors.lightTextPrimary.withValues(alpha: 0.8), // Medium teal
              AppColors.splashBackground, // Full dark teal
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium countdown section (when countdown is active)
              Obx(() => controller.isCountdownActive.value
                  ? Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3), // Brand yellow-green
                            AppColors.lightTextPrimary.withValues(alpha: 0.2), // Teal
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5), // Brand yellow-green border
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3), // Brand glow
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next Draw In',
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                controller.nextDrawTime.value,
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.lightTextPrimary], // Brand colors
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4), // Brand glow
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              controller.countdownDisplay,
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              
              // Premium previous draws section
              Container(
                height: 115, // Increased from 110 to give more space
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3, // Reduced from 4
                          height: 16, // Reduced from 20
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8), // Reduced from 12
                        Text(
                          'Previous Draws',
                          style: GoogleFonts.orbitron(
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Reduced from 12
                    Expanded(
                      child: Obx(() {
                        if (controller.previousDraws.isEmpty) {
                          return Center(
                            child: Text(
                              'No draws yet',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.previousDraws.length,
                        itemBuilder: (context, index) {
                          final draw = controller.previousDraws[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12), // Reduced from 16
                            padding: const EdgeInsets.all(8), // Reduced from 12
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12), // Reduced from 16
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  blurRadius: 8, // Reduced from 10
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  ).createShader(bounds),
                                  child: Text(
                                    '#${draw['number']}',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 14, // Reduced from 16
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.0, // Tight line height
                                    ),
                                  ),
                                ),
                                Text(
                                  draw['time'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 8, // Reduced from 9
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0, // Tight line height
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      }),
                    ),
                  ],
                ),
              ),
              
              // Main premium lottery machine section
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
                  child: Center(
                    child: Obx(() => SimplePhysicsLotteryMachine(
                      balls: controller.lotteryBalls,
                      isDrawing: controller.isDrawing.value,
                      selectedBall: controller.selectedWinner.value,
                      onDrawComplete: controller.onDrawComplete,
                    )),
                  ),
                ),
              ),
              
              // Premium current result section
              Container(
                height: 180, // Reduced from 200
                padding: const EdgeInsets.all(12), // Reduced from 16
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3, // Reduced from 4
                          height: 14, // Reduced from 16
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6), // Reduced from 8
                        Text(
                          'Current Result',
                          style: GoogleFonts.orbitron(
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), // Reduced from 16
                    
                    // Premium winner display
                    Obx(() => Container(
                      height: 30, // Reduced from 80
                      width: 30, // Reduced from 80
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: controller.selectedWinner.value.isNotEmpty
                            ? RadialGradient(
                                colors: [
                                  Colors.white,
                                  Colors.amber,
                                  Colors.orange,
                                  Colors.red.withValues(alpha: 0.8),
                                ],
                              )
                            : RadialGradient(
                                colors: [
                                  Colors.grey.shade600,
                                  Colors.grey.shade800,
                                  Colors.grey.shade900,
                                ],
                              ),
                        boxShadow: controller.selectedWinner.value.isNotEmpty
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.6),
                                  blurRadius: 20, // Reduced from 25
                                  spreadRadius: 4, // Reduced from 6
                                ),
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.4),
                                  blurRadius: 30, // Reduced from 40
                                  spreadRadius: 8, // Reduced from 12
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10, // Reduced from 12
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          controller.selectedWinner.value.isNotEmpty
                              ? '#${controller.selectedWinner.value}'
                              : '?',
                          style: GoogleFonts.orbitron(
                            fontSize: 20, // Reduced from 24
                            fontWeight: FontWeight.bold,
                            color: controller.selectedWinner.value.isNotEmpty
                                ? Colors.black87
                                : Colors.white70,
                            shadows: controller.selectedWinner.value.isNotEmpty
                                ? [
                                    Shadow(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      blurRadius: 3,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 3), // Reduced from 12
                    
                    // Premium status text with cycle information
                    Obx(() => Column(
                      children: [
                        Text(
                          _getStatusText(controller),
                          style: GoogleFonts.orbitron(
                            fontSize: 12, // Reduced from 14
                            color: _getStatusColor(controller),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (controller.isCountdownActive.value)
                          Text(
                            'Automatic draw in ${controller.countdownDisplay}',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        // Debug info
                        Text(
                          'Balls: ${controller.lotteryBalls.length} | Status: ${controller.currentCycleStatus.value}',
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    )),
                    
                    const SizedBox(height: 5), // Reduced from 12
                    
                    // Status display only - no manual buttons for automatic system
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownView(BuildContext context) {
    final minutes = _timeUntilDraw!.inMinutes;
    final seconds = _timeUntilDraw!.inSeconds % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Colors.orange, Colors.red],
          ).createShader(bounds),
          child: Text(
            'Lottery Draw',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.splashBackground.withValues(alpha: 0.9),
              AppColors.lightTextPrimary.withValues(alpha: 0.8),
              AppColors.splashBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Drawing Starts In',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Countdown timer display in MM:SS format
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.lightTextPrimary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    formattedTime,
                    style: GoogleFonts.orbitron(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Motivational message
                Text(
                  'Get ready to see the winner!',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Animated pulse indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Lottery Draw Info',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This lottery system automatically draws winners based on the group\'s cycle schedule. The countdown shows when the next draw will occur.',
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: GoogleFonts.montserrat(
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(LotteryDrawController controller) {
    if (controller.isDrawing.value) {
      return 'Drawing in progress...';
    } else if (controller.selectedWinner.value.isNotEmpty) {
      return 'Winner Selected! 🎉';
    } else if (controller.isCountdownActive.value) {
      return 'Waiting for next draw...';
    } else if (controller.currentCycleStatus.value == 'completed') {
      return 'Cycle completed';
    } else if (controller.isLoading.value) {
      return 'Loading...';
    } else {
      return 'Ready to draw';
    }
  }

  Color _getStatusColor(LotteryDrawController controller) {
    if (controller.isDrawing.value) {
      return Colors.amber;
    } else if (controller.selectedWinner.value.isNotEmpty) {
      return Colors.green.shade400;
    } else if (controller.isCountdownActive.value) {
      return Colors.orange;
    } else if (controller.isLoading.value) {
      return Colors.blue;
    } else {
      return Colors.white70;
    }
  }
}