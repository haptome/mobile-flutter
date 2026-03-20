// Purpose: Simple demo to showcase the lottery draw UI animation
// Run: flutter run lib/simple_demo.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/lottery_draw_controller.dart';
import 'widgets/simple_physics_lottery_machine.dart';

void main() {
  runApp(const SimpleLotteryDemo());
}

class SimpleLotteryDemo extends StatelessWidget {
  const SimpleLotteryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lottery Draw Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.orbitron().fontFamily,
      ),
      home: const LotteryDemoScreen(),
    );
  }
}

class LotteryDemoScreen extends StatefulWidget {
  const LotteryDemoScreen({super.key});

  @override
  State<LotteryDemoScreen> createState() => _LotteryDemoScreenState();
}

class _LotteryDemoScreenState extends State<LotteryDemoScreen> {
  final LotteryDrawController controller = Get.put(LotteryDrawController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Colors.orange, Colors.red],
          ).createShader(bounds),
          child: Text(
            'Physics Lottery Demo',
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
              const Color(0xFF0A0A0A),
              const Color(0xFF050505),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Demo Instructions
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.withValues(alpha: 0.2),
                      Colors.blue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎰 Physics-Based Lottery Machine',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Start Draw" to see the physics animation!\nWatch the balls move, collide, and bounce around.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main lottery machine
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
              
              // Current result display
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Result',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Winner display
                    Obx(() => Container(
                      width: 60,
                      height: 60,
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
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          controller.selectedWinner.value.isNotEmpty
                              ? '#${controller.selectedWinner.value}'
                              : '?',
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: controller.selectedWinner.value.isNotEmpty
                                ? Colors.black87
                                : Colors.white70,
                          ),
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 12),
                    
                    // Status text
                    Obx(() => Text(
                      controller.isDrawing.value
                          ? 'Drawing in progress...'
                          : controller.selectedWinner.value.isNotEmpty
                              ? 'Winner Selected! 🎉'
                              : 'Ready to draw',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: controller.isDrawing.value
                            ? Colors.amber
                            : controller.selectedWinner.value.isNotEmpty
                                ? Colors.green.shade400
                                : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ],
                ),
              ),
              
              // Draw button
              Container(
                margin: const EdgeInsets.all(16),
                child: Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isDrawing.value
                        ? null
                        : controller.selectedWinner.value.isNotEmpty
                            ? () {
                                HapticFeedback.mediumImpact();
                                controller.resetDraw();
                              }
                            : () {
                                HapticFeedback.heavyImpact();
                                controller.startDraw();
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: controller.isDrawing.value
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.shade600,
                                  Colors.grey.shade800,
                                ],
                              )
                            : controller.selectedWinner.value.isNotEmpty
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.shade700,
                                      Colors.grey.shade900,
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Colors.amber,
                                      Colors.orange,
                                      Colors.red,
                                    ],
                                  ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: !controller.isDrawing.value && controller.selectedWinner.value.isEmpty
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          controller.isDrawing.value
                              ? 'Drawing...'
                              : controller.selectedWinner.value.isNotEmpty
                                  ? 'Draw Again'
                                  : 'Start Physics Draw',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}