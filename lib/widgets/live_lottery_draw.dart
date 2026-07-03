// Purpose: Live lottery draw widget for visualizing winner selection
// Author: Auto-generated

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class LiveLotteryDraw extends StatefulWidget {
  final List<String> lotteryNumbers;
  final String? selectedWinner;
  final VoidCallback? onDrawComplete;
  final bool autoStart;
  final Duration animationDuration;

  const LiveLotteryDraw({
    super.key,
    required this.lotteryNumbers,
    this.selectedWinner,
    this.onDrawComplete,
    this.autoStart = false,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<LiveLotteryDraw> createState() => _LiveLotteryDrawState();
}

class _LiveLotteryDrawState extends State<LiveLotteryDraw>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _fadeController;
  late Animation<double> _spinAnimation;
  late Animation<double> _fadeAnimation;
  
  Timer? _numberTimer;
  String _currentNumber = '000';
  bool _isDrawing = false;
  bool _drawComplete = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _spinController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startDraw();
      });
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _fadeController.dispose();
    _numberTimer?.cancel();
    super.dispose();
  }

  void startDraw() {
    if (_isDrawing || widget.lotteryNumbers.isEmpty) return;
    
    setState(() {
      _isDrawing = true;
      _drawComplete = false;
      _currentNumber = '000';
    });

    _fadeController.forward();
    _spinController.forward();

    // Animate through random numbers
    _numberTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentNumber = widget.lotteryNumbers[
          _random.nextInt(widget.lotteryNumbers.length)
        ];
      });
    });

    // Stop animation and show final result
    Timer(widget.animationDuration, () {
      _numberTimer?.cancel();
      
      setState(() {
        _currentNumber = widget.selectedWinner ?? 
          widget.lotteryNumbers[_random.nextInt(widget.lotteryNumbers.length)];
        _isDrawing = false;
        _drawComplete = true;
      });

      _spinController.stop();
      widget.onDrawComplete?.call();
    });
  }

  void resetDraw() {
    _numberTimer?.cancel();
    _spinController.reset();
    _fadeController.reset();
    
    setState(() {
      _isDrawing = false;
      _drawComplete = false;
      _currentNumber = '000';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'live_lottery_draw'.tr,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lottery Number Display
          AnimatedBuilder(
            animation: _spinAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _spinAnimation.value * 2 * pi,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.8),
                        Colors.orange.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '#$_currentNumber',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Status Text
          if (_isDrawing)
            Text(
              'drawing_winner'.tr,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.textLightGray,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (_drawComplete)
            Column(
              children: [
                Text(
                  'winner_selected'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'congratulations_winner'.tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.textLightGray,
                  ),
                ),
              ],
            )
          else
            Text(
              'tap_to_start_draw'.tr,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.textLightGray,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isDrawing && !_drawComplete)
                ElevatedButton.icon(
                  onPressed: widget.lotteryNumbers.isNotEmpty ? startDraw : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text('start_draw'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              
              if (_drawComplete)
                ElevatedButton.icon(
                  onPressed: resetDraw,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text('draw_again'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
          
          // Participants Count
          if (widget.lotteryNumbers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'participants_count'.tr.replaceAll(
                  '{count}', 
                  widget.lotteryNumbers.length.toString(),
                ),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textLightGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Draw button that pulses green when a draw is imminent (isReady = true),
/// and stays amber/grey otherwise.
class LotteryDrawButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isReady; // true when next draw is within ~5 minutes
  final String? tooltip;

  const LotteryDrawButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isReady = false,
    this.tooltip,
  });

  @override
  State<LotteryDrawButton> createState() => _LotteryDrawButtonState();
}

class _LotteryDrawButtonState extends State<LotteryDrawButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(LotteryDrawButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isReady != widget.isReady) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isReady && widget.isEnabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colour scheme: green when ready, amber when enabled, grey when disabled
    final List<Color> gradientColors = widget.isReady
        ? [const Color(0xFF00C853), const Color(0xFF69F0AE)] // vivid green
        : widget.isEnabled
            ? [Colors.amber, Colors.orange]
            : [Colors.grey.shade300, Colors.grey.shade400];

    final Color glowColor = widget.isReady
        ? const Color(0xFF00C853)
        : Colors.amber;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Tooltip(
          message: widget.tooltip ?? 'live_lottery_draw'.tr,
          child: Transform.scale(
            scale: (widget.isReady && widget.isEnabled)
                ? _scaleAnim.value
                : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: widget.isReady ? 0.7 : 0.3,
                          ),
                          blurRadius: widget.isReady
                              ? _glowAnim.value
                              : 8,
                          spreadRadius: widget.isReady ? 2 : 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Green dot indicator when ready
                        if (widget.isReady) ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Icon(
                          Icons.casino,
                          size: 16,
                          color: widget.isEnabled
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isReady ? 'Draw Now!' : 'draw'.tr,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.isEnabled
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}