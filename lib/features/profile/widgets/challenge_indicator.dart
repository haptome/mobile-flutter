// Purpose: Challenge indicator widget for liveness checks
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign - Section 5.3

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/liveness_challenge.dart';

/// Widget that displays an animated indicator for liveness challenges
/// 
/// This widget shows an icon and instruction for the current liveness challenge.
/// The icon animates to draw attention and guide the user:
/// - Blink challenges: Eye icon with blink animation
/// - Turn challenges: Arrow icon pointing in the direction to turn
/// - Look challenges: Arrow icon pointing up or down
/// 
/// The widget includes a pulsing animation to make it more noticeable.
class ChallengeIndicator extends StatefulWidget {
  /// The current liveness challenge
  final LivenessChallenge challenge;

  /// Size of the indicator icon
  final double size;

  /// Whether to show the instruction text
  final bool showInstruction;

  const ChallengeIndicator({
    super.key,
    required this.challenge,
    this.size = 80.0,
    this.showInstruction = true,
  });

  @override
  State<ChallengeIndicator> createState() => _ChallengeIndicatorState();
}

class _ChallengeIndicatorState extends State<ChallengeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getIconForChallenge() {
    switch (widget.challenge.type) {
      case ChallengeType.blinkOnce:
      case ChallengeType.blinkTwice:
        return Icons.remove_red_eye;
      case ChallengeType.turnLeft:
        return Icons.arrow_back;
      case ChallengeType.turnRight:
        return Icons.arrow_forward;
      case ChallengeType.lookUp:
        return Icons.arrow_upward;
      case ChallengeType.lookDown:
        return Icons.arrow_downward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _getIconForChallenge(),
              size: widget.size * 0.5,
              color: const Color(0xFF2196F3), // Blue
            ),
          ),
        ),

        // Instruction text
        if (widget.showInstruction) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.challenge.instruction,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget that displays a progress indicator for liveness check
/// 
/// Shows the current step and total steps in the liveness verification process.
class LivenessProgressIndicator extends StatelessWidget {
  /// Current step (0-indexed)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  const LivenessProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isCurrent ? 32.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }),
      ),
    );
  }
}
