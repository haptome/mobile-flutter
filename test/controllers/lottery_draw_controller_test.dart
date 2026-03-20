// Purpose: Exploratory tests for the lottery draw result bug.
//
// These tests run against UNFIXED code and are EXPECTED TO FAIL.
// A failing test here is the SUCCESS condition — it confirms the bug exists:
//   _startAutomaticDrawSequence() never calls _checkForDrawResult() after
//   the 4-second animation completes, so selectedWinner stays empty.
//
// Validates: Requirements 1.1, 1.2, 1.3 (bug condition)

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:et_digital_equb/models/api_response.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/services/lottery_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:et_digital_equb/models/member_model.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/controllers/lottery_draw_controller.dart';

// ---------------------------------------------------------------------------
// Fake ApiService — registered so LotteryService/GroupService field
// initializers don't throw when they call ApiService.to.
// We never call init(), so no Dio or StorageService is needed.
// ---------------------------------------------------------------------------
class FakeApiService extends ApiService {}

// ---------------------------------------------------------------------------
// Fake LotteryService — tracks calls to getCurrentWinner.
// All methods are overridden so _apiService is never accessed.
// ---------------------------------------------------------------------------
class FakeLotteryService extends LotteryService {
  int getCurrentWinnerCallCount = 0;
  String? winnerToReturn;

  // Controls what getCurrentCycle returns.
  // Set to 'drawing' to trigger _handleAutomaticDrawing().
  String cycleStatus = 'waiting';

  // Optional current_winner field returned in getCurrentCycle response.
  // When non-null, _checkCurrentCycleStatus() sets selectedWinner directly.
  String? currentWinnerInCycle;

  // Controls whether triggerDrawing() returns success (for manual draw tests).
  bool triggerDrawingSuccess = false;

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCurrentCycle(
      String groupId) async {
    final data = <String, dynamic>{'status': cycleStatus};
    if (currentWinnerInCycle != null) {
      data['current_winner'] = currentWinnerInCycle;
    }
    return ApiResponse.success(data);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCurrentWinner(
      String groupId) async {
    getCurrentWinnerCallCount++;
    if (winnerToReturn != null) {
      return ApiResponse.success({'lottery_number': winnerToReturn});
    }
    return ApiResponse.error('No winner yet');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLotteryNumbers(
      String groupId) async {
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> triggerDrawing(
      String groupId) async {
    if (triggerDrawingSuccess) {
      return ApiResponse.success({'status': 'drawing'});
    }
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getDrawingSchedule(
      String groupId) async {
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPreviousCycles(
    String groupId, {
    int page = 1,
    int limit = 10,
  }) async {
    return ApiResponse.error('stubbed');
  }
}

// ---------------------------------------------------------------------------
// Fake GroupService — returns empty/error for all calls.
// ---------------------------------------------------------------------------
class FakeGroupService extends GroupService {
  @override
  Future<ApiResponse<Map<String, dynamic>>> getGroupHistory(
      String groupId) async {
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<List<GroupMember>>> getGroupMembers(
    String groupId, {
    int page = 1,
    int limit = 50,
  }) async {
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<List<category_models.Category>>> getCategories({
    String? categoryType,
    bool? isActive,
    int page = 1,
    int limit = 100,
  }) async {
    return ApiResponse.error('stubbed');
  }

  @override
  Future<ApiResponse<List<Group>>> getGroups({
    String? categoryId,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return ApiResponse.error('stubbed');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Set up GetX with fake services and a groupId argument, then create and
/// return the controller along with the fake lottery service.
///
/// IMPORTANT: FakeLotteryService and FakeGroupService must be instantiated
/// AFTER FakeApiService is registered, because their field initializers
/// call ApiService.to.
///
/// Pass [groupId] as null to trigger demo mode (no real groupId).
Future<({LotteryDrawController controller, FakeLotteryService fakeService})>
    _buildController({
  String? groupId = 'test-group-123',
  String cycleStatus = 'drawing',
  String? winnerToReturn = '042',
  String? currentWinnerInCycle,
  bool triggerDrawingSuccess = false,
}) async {
  Get.testMode = true;

  // 1. Register ApiService FIRST — other services' field initializers need it.
  Get.put<ApiService>(FakeApiService(), permanent: true);

  // 2. Now instantiate and register the fakes (ApiService.to is available).
  final fakeLotteryService = FakeLotteryService()
    ..cycleStatus = cycleStatus
    ..winnerToReturn = winnerToReturn
    ..currentWinnerInCycle = currentWinnerInCycle
    ..triggerDrawingSuccess = triggerDrawingSuccess;
  Get.put<LotteryService>(fakeLotteryService, permanent: true);
  Get.put<GroupService>(FakeGroupService(), permanent: true);

  // 3. Provide groupId via routing args (Get.arguments reads routing.args).
  //    Pass null groupId to trigger demo mode.
  if (groupId != null) {
    Get.routing.args = {'groupId': groupId};
  } else {
    Get.routing.args = <String, dynamic>{};
  }

  // 4. put() calls onInit() synchronously for GetxController.
  final controller = Get.put<LotteryDrawController>(LotteryDrawController());

  // 5. Allow async onInit work (loadLotteryNumbers, loadPreviousDraws,
  //    startCycleMonitoring → checkCurrentCycleStatus) to complete.
  await Future.delayed(Duration.zero);

  return (controller: controller, fakeService: fakeLotteryService);
}

void main() {
  // Suppress HapticFeedback platform channel errors in tests
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/haptic_feedback'),
    (call) async => null,
  );

  group('Bug Condition Exploration — Automatic Draw (unfixed code)', () {
    tearDown(() {
      Get.reset();
    });

    // -----------------------------------------------------------------------
    // Task 1.2 — selectedWinner stays empty after animation (confirms bug)
    // -----------------------------------------------------------------------
    test(
      '1.2 automatic draw: selectedWinner is set to winner number after 4-second animation',
      () async {
        // Arrange: build controller; cycleStatus='drawing' causes
        // _handleAutomaticDrawing() → _startAutomaticDrawSequence() to run.
        final (:controller, :fakeService) = await _buildController(
          cycleStatus: 'drawing',
          winnerToReturn: '042',
        );

        // Verify the animation started
        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true once animation starts');

        // Act: advance time past the 4-second animation.
        // The _ballMovementTimer fires every 80ms; after 4000ms it cancels.
        // After the fix, a 1-second Timer fires _checkForDrawResult().
        await Future.delayed(const Duration(milliseconds: 5500));

        // Assert (CORRECT behavior — will FAIL on unfixed code):
        // After the fix, _checkForDrawResult() is called and sets selectedWinner.
        // On unfixed code, selectedWinner stays '' → test FAILS → bug confirmed.
        expect(
          controller.selectedWinner.value,
          equals('042'),
          reason:
              'selectedWinner should be set to the API winner number after '
              'the animation completes and _checkForDrawResult() is called',
        );

        // Assert: getCurrentWinner was called at least once
        expect(
          fakeService.getCurrentWinnerCallCount,
          greaterThan(0),
          reason:
              'getCurrentWinner should have been called by _checkForDrawResult() '
              'after the animation completed',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Task 1.3 — isDrawing stays true after animation (secondary symptom)
    // -----------------------------------------------------------------------
    test(
      '1.3 automatic draw: isDrawing is false after winner is set',
      () async {
        // Arrange
        final (:controller, :fakeService) = await _buildController(
          cycleStatus: 'drawing',
          winnerToReturn: '042',
        );

        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true once animation starts');

        // Act: advance past the 4-second animation + 1-second delay
        await Future.delayed(const Duration(milliseconds: 5500));

        // Assert (CORRECT behavior — will FAIL on unfixed code):
        // After the fix, _selectWinnerFromAPI() sets isDrawing to false.
        // On unfixed code, isDrawing stays true → test FAILS → bug confirmed.
        expect(
          controller.isDrawing.value,
          isFalse,
          reason:
              'isDrawing should be false after _checkForDrawResult() is called '
              'and _selectWinnerFromAPI() resets it',
        );
      },
    );
  });

  // =========================================================================
  // Fix Checking — Property 1: Automatic Draw Fetches Winner After Animation
  // Validates: Requirements 2.1, 2.2, 2.3
  // =========================================================================
  group('Fix Checking — Property 1: Automatic Draw Fetches Winner After Animation', () {
    tearDown(() {
      Get.reset();
    });

    // -----------------------------------------------------------------------
    // Task 3.1 — selectedWinner equals mocked winner number after fix
    // -----------------------------------------------------------------------
    test(
      '3.1 after fix: selectedWinner is set to winner number and getCurrentWinner is called',
      () async {
        // Arrange: cycleStatus='drawing' triggers _handleAutomaticDrawing()
        // → _startAutomaticDrawSequence(); the fix schedules _checkForDrawResult()
        // after the 4-second animation + 1-second delay.
        final (:controller, :fakeService) = await _buildController(
          cycleStatus: 'drawing',
          winnerToReturn: '042',
        );

        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true once animation starts');

        // Act: wait past 4s animation + 1s delay
        await Future.delayed(const Duration(milliseconds: 5500));

        // Assert: _checkForDrawResult() was called and set the winner
        expect(
          controller.selectedWinner.value,
          equals('042'),
          reason:
              'selectedWinner should equal the API-returned winner number '
              'after _checkForDrawResult() is called by the fixed code',
        );

        expect(
          fakeService.getCurrentWinnerCallCount,
          greaterThan(0),
          reason:
              'getCurrentWinner should have been called at least once by '
              '_checkForDrawResult() after the animation completed',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Task 3.2 — isDrawing is false once winner is set after fix
    // -----------------------------------------------------------------------
    test(
      '3.2 after fix: isDrawing is false once winner is set',
      () async {
        // Arrange
        final (:controller, :fakeService) = await _buildController(
          cycleStatus: 'drawing',
          winnerToReturn: '042',
        );

        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true once animation starts');

        // Act: wait past 4s animation + 1s delay
        await Future.delayed(const Duration(milliseconds: 5500));

        // Assert: _selectWinnerFromAPI() resets isDrawing to false
        expect(
          controller.isDrawing.value,
          isFalse,
          reason:
              'isDrawing should be false after _selectWinnerFromAPI() is called '
              'by the fixed _checkForDrawResult() path',
        );
      },
    );
  });

  // =========================================================================
  // Preservation Checking — Property 2: Non-Automatic Draw Paths Unchanged
  // Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5
  // =========================================================================
  group('Preservation Checking — Property 2: Non-Automatic Draw Paths Unchanged', () {
    tearDown(() {
      Get.reset();
    });

    // -----------------------------------------------------------------------
    // Task 4.1 — Demo mode: getCurrentWinner never called, random winner set
    //
    // In demo mode (_groupId == null), the controller calls
    // _simulateDemoCountdown() which after 300 s fires _startAutomaticDrawSequence()
    // followed by Timer(4s, _selectRandomWinner).  We cannot wait 304 s in a
    // unit test, so instead we verify the invariant that is observable
    // immediately after onInit():
    //   • getCurrentWinner is never called (no API access in demo mode)
    //   • the controller is in 'waiting' / countdown state (not yet drawing)
    // We then manually trigger the draw path that demo mode would eventually
    // reach and confirm _selectRandomWinner() sets selectedWinner without
    // ever calling getCurrentWinner.
    // -----------------------------------------------------------------------
    test(
      '4.1 demo mode: getCurrentWinner is never called and a random winner is selected',
      () async {
        // Arrange: pass groupId: null → _groupId == null → demo mode
        final (:controller, :fakeService) = await _buildController(
          groupId: null,
          cycleStatus: 'waiting', // irrelevant in demo mode
          winnerToReturn: null,   // should never be consulted
        );

        // Immediately after onInit(), demo mode should be in countdown state.
        expect(
          fakeService.getCurrentWinnerCallCount,
          equals(0),
          reason: 'getCurrentWinner must not be called during demo mode init',
        );

        // The controller is in demo countdown — lotteryBalls are populated
        // from _initializeLotteryBalls() with default numbers.
        expect(
          controller.lotteryBalls.isNotEmpty,
          isTrue,
          reason: 'Demo mode should populate lotteryBalls with default numbers',
        );

        // Manually invoke startDraw() in demo mode (groupId is null so it
        // calls _startPremiumDrawSequence() → selects winner after 4.5 s).
        controller.startDraw();

        // Wait for the premium draw sequence to complete (4 s animation +
        // 500 ms dramatic pause).
        await Future.delayed(const Duration(milliseconds: 5000));

        // Assert: API was never called throughout the entire demo draw.
        expect(
          fakeService.getCurrentWinnerCallCount,
          equals(0),
          reason:
              'getCurrentWinner must never be called in demo mode — '
              'winner is selected locally via _selectRandomWinner()',
        );

        // Assert: a winner was selected (non-empty).
        expect(
          controller.selectedWinner.value,
          isNotEmpty,
          reason:
              'Demo mode should set selectedWinner to a random ball number '
              'without calling the API',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Task 4.2 — Manual draw: _triggerManualDraw() still schedules
    //            _checkForDrawResult() at 5 seconds (unchanged)
    // -----------------------------------------------------------------------
    test(
      '4.2 manual draw: startDraw() calls getCurrentWinner and sets selectedWinner to winner number',
      () async {
        // Arrange: real groupId + triggerDrawing returns success so that
        // _triggerManualDraw() proceeds to _startAutomaticDrawSequence().
        final (:controller, :fakeService) = await _buildController(
          groupId: 'test-group-123',
          cycleStatus: 'waiting', // start idle so onInit doesn't auto-draw
          winnerToReturn: '042',
          triggerDrawingSuccess: true,
        );

        // Confirm no draw is in progress yet.
        expect(controller.isDrawing.value, isFalse,
            reason: 'Should not be drawing before startDraw() is called');

        // Act: trigger manual draw.
        controller.startDraw();

        // Allow triggerDrawing() async call to complete.
        await Future.delayed(Duration.zero);

        // Animation should now be running.
        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true after manual draw starts');

        // Wait past 4 s animation + 5 s Timer in _triggerManualDraw().
        await Future.delayed(const Duration(milliseconds: 5500));

        // Assert: getCurrentWinner was called via _checkForDrawResult().
        expect(
          fakeService.getCurrentWinnerCallCount,
          greaterThan(0),
          reason:
              'Manual draw path must still call getCurrentWinner via '
              '_checkForDrawResult() after the animation',
        );

        // Assert: winner was set correctly.
        expect(
          controller.selectedWinner.value,
          equals('042'),
          reason:
              'selectedWinner should be set to the API-returned winner '
              'number after the manual draw completes',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Task 4.3 — Direct winner from cycle data: selectedWinner set immediately
    //
    // When _checkCurrentCycleStatus() receives a response that already
    // contains 'current_winner', it sets selectedWinner directly without
    // starting any animation.
    // -----------------------------------------------------------------------
    test(
      '4.3 direct winner from cycle data: selectedWinner set immediately, isDrawing stays false',
      () async {
        // Arrange: cycle status 'completed' with current_winner already set.
        // _checkCurrentCycleStatus() reads cycleData['current_winner'] and
        // calls selectedWinner.value = currentWinner directly.
        final (:controller, :fakeService) = await _buildController(
          groupId: 'test-group-123',
          cycleStatus: 'completed',
          currentWinnerInCycle: '007',
          winnerToReturn: null, // getCurrentWinner should not be needed
        );

        // Allow onInit async work (_checkCurrentCycleStatus) to complete.
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: winner was set directly from cycle data — no animation.
        expect(
          controller.selectedWinner.value,
          equals('007'),
          reason:
              'selectedWinner should be set directly from current_winner in '
              'cycle data without waiting for an animation',
        );

        // Assert: no draw animation was started.
        expect(
          controller.isDrawing.value,
          isFalse,
          reason:
              'isDrawing should remain false when winner comes directly '
              'from cycle data (no animation needed)',
        );

        // Assert: getCurrentWinner API was not called for this path.
        expect(
          fakeService.getCurrentWinnerCallCount,
          equals(0),
          reason:
              'getCurrentWinner should not be called when current_winner is '
              'already present in the cycle data response',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Task 4.4 — onClose() cancels all timers without error
    // -----------------------------------------------------------------------
    test(
      '4.4 onClose() cancels all timers without throwing after fix',
      () async {
        // Arrange: start an automatic draw so timers are active.
        final (:controller, :fakeService) = await _buildController(
          cycleStatus: 'drawing',
          winnerToReturn: '042',
        );

        // Animation should be running.
        expect(controller.isDrawing.value, isTrue,
            reason: 'isDrawing should be true once animation starts');

        // Wait 1 second — animation is in progress, timers are live.
        await Future.delayed(const Duration(seconds: 1));

        // Act: close the controller — should cancel all timers cleanly.
        expect(
          () => controller.onClose(),
          returnsNormally,
          reason: 'onClose() must not throw even when timers are active',
        );

        // Give any pending timer callbacks a chance to fire (they should be
        // cancelled and therefore silent).
        await Future.delayed(const Duration(milliseconds: 500));

        // If we reach here without hanging or throwing, timers were cancelled.
      },
    );
  });
}
