// Purpose: Instruction overlay widget for camera screens
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign - Section 5.2

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/id_capture_controller.dart';

/// Widget that displays instruction text at the top of the camera screen
/// 
/// This widget shows context-appropriate instructions based on the current
/// capture state. The text updates dynamically as the user progresses through
/// the capture flow.
/// 
/// For ID capture:
/// - idle: "Place ID inside frame"
/// - detecting: "Align your ID"
/// - aligned: "Hold steady..."
/// - success: "Perfect!"
/// 
/// For liveness check:
/// - Custom instructions based on challenge type
class InstructionOverlay extends StatelessWidget {
  /// The instruction text to display
  final String text;

  /// Optional subtitle text
  final String? subtitle;

  /// Whether to show with error styling
  final bool isError;

  /// Whether to show with success styling
  final bool isSuccess;

  const InstructionOverlay({
    super.key,
    required this.text,
    this.subtitle,
    this.isError = false,
    this.isSuccess = false,
  });

  /// Factory constructor for ID capture instructions
  factory InstructionOverlay.forIDCapture({
    required CaptureState state,
    String? customText,
  }) {
    String text;
    bool isSuccess = false;
    bool isError = false;

    if (customText != null) {
      text = customText;
    } else {
      switch (state) {
        case CaptureState.idle:
          text = 'Place ID inside frame';
          break;
        case CaptureState.detecting:
          text = 'Align your ID';
          break;
        case CaptureState.aligned:
          text = 'Hold steady...';
          break;
        case CaptureState.capturing:
          text = 'Capturing...';
          break;
        case CaptureState.validating:
          text = 'Validating...';
          break;
        case CaptureState.success:
          text = 'Perfect!';
          isSuccess = true;
          break;
        case CaptureState.error:
          text = 'Please try again';
          isError = true;
          break;
      }
    }

    return InstructionOverlay(
      text: text,
      isSuccess: isSuccess,
      isError: isError,
    );
  }

  /// Factory constructor for liveness check instructions
  factory InstructionOverlay.forLiveness({
    required String instruction,
    String? subtitle,
    bool isError = false,
    bool isSuccess = false,
  }) {
    return InstructionOverlay(
      text: instruction,
      subtitle: subtitle,
      isError: isError,
      isSuccess: isSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine text color based on state
    Color textColor;
    if (isError) {
      textColor = const Color(0xFFF44336); // Red
    } else if (isSuccess) {
      textColor = const Color(0xFF4CAF50); // Green
    } else {
      textColor = Colors.white;
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main instruction text
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle (if provided)
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
