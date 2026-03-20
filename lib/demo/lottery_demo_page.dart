// Purpose: Interactive demo page for the Physics-Based Lottery Draw System
// Author: Auto-generated for demonstration purposes

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lottery_draw_controller.dart';
import '../widgets/simple_physics_lottery_machine.dart';

class LotteryDemoPage extends StatefulWidget {
  const LotteryDemoPage({super.key});

  @override
  State<LotteryDemoPage> createState() => _LotteryDemoPageState();
}

class _LotteryDemoPageState extends State<LotteryDemoPage> {
  final LotteryDrawController controller = Get.put(LotteryDrawController());
  final PageController _pageController = PageController();
  int _currentDemo = 0;
  Timer? _autoDemo;
  bool _isAutoMode = false;

  final List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': 'Standard Draw',
      'description': 'Regular lottery draw with 25 balls',
      'numbers': List.generate(25, (i) => (i + 1).toString().padLeft(3, '0')),
      'duration': 4000,
    },
    {
      'title': 'Quick Draw',
      'description': 'Fast-paced draw with 15 balls',
      'numbers': ['001', '005', '010', '015', '020', '025', '030', '035', '040', '045', '050', '055', '060', '065', '070'],
      'duration': 2500,
    },
    {
      'title': 'Premium Draw',
      'description': 'Extended draw with dramatic effects',
      'numbers': List.generate(30, (i) => (i + 1).toString().padLeft(3, '0')),
      'duration': 6000,
    },
    {
      'title': 'Mini Draw',
      'description': 'Compact draw with 10 balls',
      'numbers': ['100', '200', '300', '400', '500', '600', '700', '800', '900', '999'],
      'duration': 3000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDemoScenario(0);
  }

  @override
  void dispose() {
    _autoDemo?.cancel();
    super.dispose();
  }

  void _loadDemoScenario(int index) {
    final scenario = _demoScenarios[index];
    
    // Update controller with scenario data
    controller.lotteryBalls.clear();
    for (final number in scenario['numbers']) {
      controller.lotteryBalls.add(
        controller.lotteryBalls.isNotEmpty 
          ? controller.lotteryBalls.first.copyWith(number: number)
          : controller.lotteryBalls.first, // This will need proper initialization
      );
    }
    controller.lotteryBalls.refresh();
  }

  void _startAutoDemo() {
    setState(() {
      _isAutoMode = true;
    });
    
    _autoDemo = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_currentDemo < _demoScenarios.length - 1) {
        _nextDemo();
        Future.delayed(const Duration(milliseconds: 500), () {
          controller.startDraw();
        });
      } else {
        _stopAutoDemo();
      }
    });
    
    // Start first draw
    controller.startDraw();
  }

  void _stopAutoDemo() {
    _autoDemo?.cancel();
    setState(() {
      _isAutoMode = false;
    });
  }

  void _nextDemo() {
    if (_currentDemo < _demoScenarios.length - 1) {
      setState(() {
        _currentDemo++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadDemoScenario(_currentDemo);
    }
  }

  void _previousDemo() {
    if (_currentDemo > 0) {
      setState(() {
        _currentDemo--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadDemoScenario(_currentDemo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
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
            colors: [Colors.cyan, Colors.blue, Colors.purple],
          ).createShader(bounds),
          child: Text(
            'Lottery Demo',
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
                  colors: _isAutoMode
                      ? [Colors.red.withValues(alpha: 0.3), Colors.red.withValues(alpha: 0.2)]
                      : [Colors.green.withValues(alpha: 0.3), Colors.green.withValues(alpha: 0.2)],
                ),
              ),
              child: Icon(
                _isAutoMode ? Icons.stop : Icons.play_arrow,
                color: _isAutoMode ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_isAutoMode) {
                _stopAutoDemo();
              } else {
                _startAutoDemo();
              }
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
              const Color(0xFF0A0A0A),
              const Color(0xFF050505),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          children: [
            // Demo scenario selector
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Demo Scenarios',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentDemo = index;
                        });
                        _loadDemoScenario(index);
                      },
                      itemCount: _demoScenarios.length,
                      itemBuilder: (context, index) {
                        final scenario = _demoScenarios[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                scenario['title'],
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scenario['description'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${scenario['numbers'].length} balls • ${scenario['duration']}ms',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8,
                                  color: Colors.cyan.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _demoScenarios.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentDemo
                        ? Colors.cyan
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
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
            
            // Demo controls
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Navigation controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _currentDemo > 0 ? _previousDemo : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _currentDemo > 0
                                ? const LinearGradient(colors: [Colors.blue, Colors.purple])
                                : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade800]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      // Manual draw button
                      Obx(() => ElevatedButton(
                        onPressed: !_isAutoMode && !controller.isDrawing.value
                            ? () {
                                HapticFeedback.heavyImpact();
                                controller.startDraw();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: !_isAutoMode && !controller.isDrawing.value
                                ? const LinearGradient(colors: [Colors.amber, Colors.orange, Colors.red])
                                : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade800]),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            controller.isDrawing.value ? 'Drawing...' : 'Draw Now',
                            style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                      
                      ElevatedButton(
                        onPressed: _currentDemo < _demoScenarios.length - 1 ? _nextDemo : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _currentDemo < _demoScenarios.length - 1
                                ? const LinearGradient(colors: [Colors.blue, Colors.purple])
                                : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade800]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Next',
                            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Demo status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Demo Status',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusItem('Mode', _isAutoMode ? 'Auto' : 'Manual'),
                            _buildStatusItem('Scenario', '${_currentDemo + 1}/${_demoScenarios.length}'),
                            Obx(() => _buildStatusItem('Status', controller.isDrawing.value ? 'Drawing' : 'Ready')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
      ],
    );
  }
}