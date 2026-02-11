// Purpose: Unit tests for LivenessChallenge model
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/liveness_challenge.dart';

void main() {
  group('ChallengeType enum', () {
    test('should have six challenge types', () {
      expect(ChallengeType.values.length, 6);
      expect(ChallengeType.values, contains(ChallengeType.blinkOnce));
      expect(ChallengeType.values, contains(ChallengeType.blinkTwice));
      expect(ChallengeType.values, contains(ChallengeType.turnLeft));
      expect(ChallengeType.values, contains(ChallengeType.turnRight));
      expect(ChallengeType.values, contains(ChallengeType.lookUp));
      expect(ChallengeType.values, contains(ChallengeType.lookDown));
    });
  });

  group('LivenessChallenge.forType', () {
    test('should create correct challenge for blinkOnce', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkOnce);

      expect(challenge.type, ChallengeType.blinkOnce);
      expect(challenge.instruction, 'Blink once');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should create correct challenge for blinkTwice', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkTwice);

      expect(challenge.type, ChallengeType.blinkTwice);
      expect(challenge.instruction, 'Blink twice');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should create correct challenge for turnLeft', () {
      final challenge = LivenessChallenge.forType(ChallengeType.turnLeft);

      expect(challenge.type, ChallengeType.turnLeft);
      expect(challenge.instruction, 'Turn your head left');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should create correct challenge for turnRight', () {
      final challenge = LivenessChallenge.forType(ChallengeType.turnRight);

      expect(challenge.type, ChallengeType.turnRight);
      expect(challenge.instruction, 'Turn your head right');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should create correct challenge for lookUp', () {
      final challenge = LivenessChallenge.forType(ChallengeType.lookUp);

      expect(challenge.type, ChallengeType.lookUp);
      expect(challenge.instruction, 'Look up');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should create correct challenge for lookDown', () {
      final challenge = LivenessChallenge.forType(ChallengeType.lookDown);

      expect(challenge.type, ChallengeType.lookDown);
      expect(challenge.instruction, 'Look down');
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('all challenges should have 10 second timeout', () {
      for (final type in ChallengeType.values) {
        final challenge = LivenessChallenge.forType(type);
        expect(challenge.timeout, const Duration(seconds: 10));
      }
    });
  });

  group('LivenessChallenge.random', () {
    test('should return a valid challenge', () {
      final challenge = LivenessChallenge.random();

      expect(challenge.type, isA<ChallengeType>());
      expect(challenge.instruction, isNotEmpty);
      expect(challenge.timeout, const Duration(seconds: 10));
    });

    test('should return different challenges over multiple calls', () {
      // Generate multiple challenges and check if we get variety
      final challenges = <ChallengeType>{};
      
      // Generate 20 challenges to increase likelihood of variety
      for (int i = 0; i < 20; i++) {
        final challenge = LivenessChallenge.random();
        challenges.add(challenge.type);
      }

      // We should get at least 2 different challenge types
      // (statistically very likely with 20 attempts and 6 types)
      expect(challenges.length, greaterThan(1));
    });
  });

  group('LivenessChallenge.isHeadMovement', () {
    test('should return true for head movement challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.turnLeft).isHeadMovement(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.turnRight).isHeadMovement(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookUp).isHeadMovement(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookDown).isHeadMovement(),
        true,
      );
    });

    test('should return false for blink challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.blinkOnce).isHeadMovement(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkTwice).isHeadMovement(),
        false,
      );
    });
  });

  group('LivenessChallenge.isBlinkChallenge', () {
    test('should return true for blink challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.blinkOnce).isBlinkChallenge(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkTwice).isBlinkChallenge(),
        true,
      );
    });

    test('should return false for head movement challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.turnLeft).isBlinkChallenge(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.turnRight).isBlinkChallenge(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookUp).isBlinkChallenge(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookDown).isBlinkChallenge(),
        false,
      );
    });
  });

  group('LivenessChallenge.getTargetAngle', () {
    test('should return correct angle for turnLeft', () {
      final challenge = LivenessChallenge.forType(ChallengeType.turnLeft);
      expect(challenge.getTargetAngle(), -30.0);
    });

    test('should return correct angle for turnRight', () {
      final challenge = LivenessChallenge.forType(ChallengeType.turnRight);
      expect(challenge.getTargetAngle(), 30.0);
    });

    test('should return correct angle for lookUp', () {
      final challenge = LivenessChallenge.forType(ChallengeType.lookUp);
      expect(challenge.getTargetAngle(), -20.0);
    });

    test('should return correct angle for lookDown', () {
      final challenge = LivenessChallenge.forType(ChallengeType.lookDown);
      expect(challenge.getTargetAngle(), 20.0);
    });

    test('should return null for blink challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.blinkOnce).getTargetAngle(),
        null,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkTwice).getTargetAngle(),
        null,
      );
    });
  });

  group('LivenessChallenge.usesYaw', () {
    test('should return true for left/right turn challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.turnLeft).usesYaw(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.turnRight).usesYaw(),
        true,
      );
    });

    test('should return false for other challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.lookUp).usesYaw(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookDown).usesYaw(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkOnce).usesYaw(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkTwice).usesYaw(),
        false,
      );
    });
  });

  group('LivenessChallenge.usesPitch', () {
    test('should return true for up/down look challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.lookUp).usesPitch(),
        true,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookDown).usesPitch(),
        true,
      );
    });

    test('should return false for other challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.turnLeft).usesPitch(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.turnRight).usesPitch(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkOnce).usesPitch(),
        false,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.blinkTwice).usesPitch(),
        false,
      );
    });
  });

  group('LivenessChallenge.getRequiredBlinks', () {
    test('should return 1 for blinkOnce', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkOnce);
      expect(challenge.getRequiredBlinks(), 1);
    });

    test('should return 2 for blinkTwice', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkTwice);
      expect(challenge.getRequiredBlinks(), 2);
    });

    test('should return null for head movement challenges', () {
      expect(
        LivenessChallenge.forType(ChallengeType.turnLeft).getRequiredBlinks(),
        null,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.turnRight).getRequiredBlinks(),
        null,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookUp).getRequiredBlinks(),
        null,
      );
      expect(
        LivenessChallenge.forType(ChallengeType.lookDown).getRequiredBlinks(),
        null,
      );
    });
  });

  group('LivenessChallenge.copyWith', () {
    test('should create a copy with updated type', () {
      final original = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final copy = original.copyWith(type: ChallengeType.turnLeft);

      expect(copy.type, ChallengeType.turnLeft);
      expect(copy.instruction, original.instruction);
      expect(copy.timeout, original.timeout);
    });

    test('should create a copy with updated instruction', () {
      final original = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final copy = original.copyWith(instruction: 'Custom instruction');

      expect(copy.type, original.type);
      expect(copy.instruction, 'Custom instruction');
      expect(copy.timeout, original.timeout);
    });

    test('should create a copy with updated timeout', () {
      final original = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final copy = original.copyWith(timeout: const Duration(seconds: 15));

      expect(copy.type, original.type);
      expect(copy.instruction, original.instruction);
      expect(copy.timeout, const Duration(seconds: 15));
    });

    test('should create a copy with all fields updated', () {
      final original = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final copy = original.copyWith(
        type: ChallengeType.turnRight,
        instruction: 'New instruction',
        timeout: const Duration(seconds: 20),
      );

      expect(copy.type, ChallengeType.turnRight);
      expect(copy.instruction, 'New instruction');
      expect(copy.timeout, const Duration(seconds: 20));
    });

    test('should create identical copy when no parameters provided', () {
      final original = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final copy = original.copyWith();

      expect(copy.type, original.type);
      expect(copy.instruction, original.instruction);
      expect(copy.timeout, original.timeout);
    });
  });

  group('LivenessChallenge equality', () {
    test('should be equal when all fields match', () {
      final challenge1 = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final challenge2 = LivenessChallenge.forType(ChallengeType.blinkOnce);

      expect(challenge1, equals(challenge2));
      expect(challenge1.hashCode, equals(challenge2.hashCode));
    });

    test('should not be equal when type differs', () {
      final challenge1 = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final challenge2 = LivenessChallenge.forType(ChallengeType.blinkTwice);

      expect(challenge1, isNot(equals(challenge2)));
    });

    test('should not be equal when instruction differs', () {
      final challenge1 = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final challenge2 = challenge1.copyWith(instruction: 'Different');

      expect(challenge1, isNot(equals(challenge2)));
    });

    test('should not be equal when timeout differs', () {
      final challenge1 = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final challenge2 = challenge1.copyWith(
        timeout: const Duration(seconds: 15),
      );

      expect(challenge1, isNot(equals(challenge2)));
    });

    test('should be equal to itself', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkOnce);

      expect(challenge, equals(challenge));
    });
  });

  group('LivenessChallenge.toString', () {
    test('should return formatted string representation', () {
      final challenge = LivenessChallenge.forType(ChallengeType.blinkOnce);
      final str = challenge.toString();

      expect(str, contains('LivenessChallenge'));
      expect(str, contains('blinkOnce'));
      expect(str, contains('Blink once'));
      expect(str, contains('0:00:10'));
    });
  });

  group('Challenge type categorization', () {
    test('each challenge should be either blink or head movement', () {
      for (final type in ChallengeType.values) {
        final challenge = LivenessChallenge.forType(type);
        final isBlink = challenge.isBlinkChallenge();
        final isHead = challenge.isHeadMovement();

        // Each challenge should be exactly one category
        expect(isBlink != isHead, true,
            reason: 'Challenge $type should be either blink or head movement');
      }
    });

    test('head movement challenges should have target angles', () {
      for (final type in ChallengeType.values) {
        final challenge = LivenessChallenge.forType(type);
        
        if (challenge.isHeadMovement()) {
          expect(challenge.getTargetAngle(), isNotNull);
          expect(challenge.getRequiredBlinks(), isNull);
        }
      }
    });

    test('blink challenges should have required blink counts', () {
      for (final type in ChallengeType.values) {
        final challenge = LivenessChallenge.forType(type);
        
        if (challenge.isBlinkChallenge()) {
          expect(challenge.getRequiredBlinks(), isNotNull);
          expect(challenge.getTargetAngle(), isNull);
        }
      }
    });

    test('yaw and pitch should be mutually exclusive', () {
      for (final type in ChallengeType.values) {
        final challenge = LivenessChallenge.forType(type);
        
        if (challenge.usesYaw()) {
          expect(challenge.usesPitch(), false);
        }
        
        if (challenge.usesPitch()) {
          expect(challenge.usesYaw(), false);
        }
      }
    });
  });

  group('Challenge angle specifications', () {
    test('left/right turns should use yaw with opposite signs', () {
      final turnLeft = LivenessChallenge.forType(ChallengeType.turnLeft);
      final turnRight = LivenessChallenge.forType(ChallengeType.turnRight);

      expect(turnLeft.usesYaw(), true);
      expect(turnRight.usesYaw(), true);
      expect(turnLeft.getTargetAngle()! < 0, true);
      expect(turnRight.getTargetAngle()! > 0, true);
      expect(
        turnLeft.getTargetAngle()!.abs(),
        equals(turnRight.getTargetAngle()!.abs()),
      );
    });

    test('up/down looks should use pitch with opposite signs', () {
      final lookUp = LivenessChallenge.forType(ChallengeType.lookUp);
      final lookDown = LivenessChallenge.forType(ChallengeType.lookDown);

      expect(lookUp.usesPitch(), true);
      expect(lookDown.usesPitch(), true);
      expect(lookUp.getTargetAngle()! < 0, true);
      expect(lookDown.getTargetAngle()! > 0, true);
      expect(
        lookUp.getTargetAngle()!.abs(),
        equals(lookDown.getTargetAngle()!.abs()),
      );
    });

    test('turn angles should be larger than look angles', () {
      final turnLeft = LivenessChallenge.forType(ChallengeType.turnLeft);
      final lookUp = LivenessChallenge.forType(ChallengeType.lookUp);

      expect(
        turnLeft.getTargetAngle()!.abs(),
        greaterThan(lookUp.getTargetAngle()!.abs()),
      );
    });
  });
}
