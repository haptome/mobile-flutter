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

/// Simple lottery draw button for compact spaces
class LotteryDrawButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String? tooltip;

  const LotteryDrawButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'live_lottery_draw'.tr,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [Colors.amber, Colors.orange]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.casino,
                    size: 16,
                    color: isEnabled ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'draw'.tr,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}