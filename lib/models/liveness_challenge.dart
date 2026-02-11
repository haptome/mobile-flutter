// Purpose: Liveness challenge model for face liveness verification
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'dart:math' show Random;

/// Enum representing the types of liveness challenges
/// 
/// These challenges are used during active liveness verification to ensure
/// the user is physically present and not using a photo or video.
enum ChallengeType {
  /// User must blink once
  blinkOnce,

  /// User must blink twice in succession
  blinkTwice,

  /// User must turn their head to the left
  turnLeft,

  /// User must turn their head to the right
  turnRight,

  /// User must look up
  lookUp,

  /// User must look down
  lookDown,
}

/// Model representing a liveness challenge
/// 
/// This model encapsulates all information about a liveness challenge,
/// including the type of challenge, user-facing instruction text, and
/// timeout duration for completing the challenge.
class LivenessChallenge {
  /// The type of challenge to perform
  final ChallengeType type;

  /// User-facing instruction text for the challenge
  final String instruction;

  /// Maximum time allowed to complete the challenge
  final Duration timeout;

  const LivenessChallenge({
    required this.type,
    required this.instruction,
    required this.timeout,
  });

  /// Check if this challenge involves head movement
  bool isHeadMovement() {
    return type == ChallengeType.turnLeft ||
        type == ChallengeType.turnRight ||
        type == ChallengeType.lookUp ||
        type == ChallengeType.lookDown;
  }

  /// Check if this challenge involves blinking
  bool isBlinkChallenge() {
    return type == ChallengeType.blinkOnce || type == ChallengeType.blinkTwice;
  }

  /// Get the target angle for head movement challenges
  /// Returns null for blink challenges
  /// 
  /// Angles are in degrees:
  /// - Positive yaw: turn right
  /// - Negative yaw: turn left
  /// - Positive pitch: look down
  /// - Negative pitch: look up
  double? getTargetAngle() {
    switch (type) {
      case ChallengeType.turnLeft:
        return -30.0; // yaw
      case ChallengeType.turnRight:
        return 30.0; // yaw
      case ChallengeType.lookUp:
        return -20.0; // pitch
      case ChallengeType.lookDown:
        return 20.0; // pitch
      case ChallengeType.blinkOnce:
      case ChallengeType.blinkTwice:
        return null;
    }
  }

  /// Check if this challenge uses yaw angle (left/right turns)
  bool usesYaw() {
    return type == ChallengeType.turnLeft || type == ChallengeType.turnRight;
  }

  /// Check if this challenge uses pitch angle (up/down looks)
  bool usesPitch() {
    return type == ChallengeType.lookUp || type == ChallengeType.lookDown;
  }

  /// Get the number of blinks required for blink challenges
  /// Returns null for head movement challenges
  int? getRequiredBlinks() {
    switch (type) {
      case ChallengeType.blinkOnce:
        return 1;
      case ChallengeType.blinkTwice:
        return 2;
      case ChallengeType.turnLeft:
      case ChallengeType.turnRight:
      case ChallengeType.lookUp:
      case ChallengeType.lookDown:
        return null;
    }
  }

  /// Create a random liveness challenge
  /// 
  /// This method randomly selects one of the available challenge types
  /// and returns a configured LivenessChallenge instance with appropriate
  /// instruction text and timeout.
  static LivenessChallenge random() {
    final challenges = ChallengeType.values;
    final random = Random();
    final randomIndex = random.nextInt(challenges.length);
    final type = challenges[randomIndex];

    return forType(type);
  }

  /// Create a liveness challenge for a specific type
  /// 
  /// Returns a configured LivenessChallenge with appropriate instruction
  /// text and timeout for the given challenge type.
  static LivenessChallenge forType(ChallengeType type) {
    switch (type) {
      case ChallengeType.blinkOnce:
        return const LivenessChallenge(
          type: ChallengeType.blinkOnce,
          instruction: 'Blink once',
          timeout: Duration(seconds: 10),
        );
      case ChallengeType.blinkTwice:
        return const LivenessChallenge(
          type: ChallengeType.blinkTwice,
          instruction: 'Blink twice',
          timeout: Duration(seconds: 10),
        );
      case ChallengeType.turnLeft:
        return const LivenessChallenge(
          type: ChallengeType.turnLeft,
          instruction: 'Turn your head left',
          timeout: Duration(seconds: 10),
        );
      case ChallengeType.turnRight:
        return const LivenessChallenge(
          type: ChallengeType.turnRight,
          instruction: 'Turn your head right',
          timeout: Duration(seconds: 10),
        );
      case ChallengeType.lookUp:
        return const LivenessChallenge(
          type: ChallengeType.lookUp,
          instruction: 'Look up',
          timeout: Duration(seconds: 10),
        );
      case ChallengeType.lookDown:
        return const LivenessChallenge(
          type: ChallengeType.lookDown,
          instruction: 'Look down',
          timeout: Duration(seconds: 10),
        );
    }
  }

  /// Create a copy of this challenge with updated values
  LivenessChallenge copyWith({
    ChallengeType? type,
    String? instruction,
    Duration? timeout,
  }) {
    return LivenessChallenge(
      type: type ?? this.type,
      instruction: instruction ?? this.instruction,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  String toString() {
    return 'LivenessChallenge(type: $type, instruction: "$instruction", '
        'timeout: $timeout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LivenessChallenge &&
        other.type == type &&
        other.instruction == instruction &&
        other.timeout == timeout;
  }

  @override
  int get hashCode {
    return Object.hash(type, instruction, timeout);
  }
}
