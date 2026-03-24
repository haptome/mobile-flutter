// Purpose: Premium controller for the lottery draw experience with real-time API integration
// Author: Auto-generated

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/lottery_ball.dart';
import '../core/services/lottery_service.dart';
import '../core/services/group_service.dart';

class LotteryDrawController extends GetxController {
  final RxList<LotteryBall> lotteryBalls = <LotteryBall>[].obs;
  final RxList<Map<String, dynamic>> previousDraws = <Map<String, dynamic>>[].obs;
  final RxBool isDrawing = false.obs;
  final RxString selectedWinner = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Real-time countdown functionality
  final RxInt countdownSeconds = 0.obs;
  final RxBool isCountdownActive = false.obs;
  final RxString nextDrawTime = ''.obs;
  final RxString currentCycleStatus = 'loading'.obs; // loading, waiting, drawing, completed
  
  Timer? _drawTimer;
  Timer? _ballMovementTimer;
  Timer? _countdownTimer;
  Timer? _statusCheckTimer;
  final Random _random = Random();
  int _drawDuration = 0;
  
  // Group context
  String? _groupId;
  
  // Services
  final LotteryService _lotteryService = LotteryService.to;

  @override
  void onInit() {
    super.onInit();
    print('🎰 DEBUG: LotteryDrawController onInit() called');
    
    // Get group ID and drawing time from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    _groupId = arguments?['groupId'] as String?;
    final drawingTime = arguments?['drawingTime'] as DateTime?;
    
    // If drawing time is provided (from pre-draw notification), initialize countdown
    if (drawingTime != null) {
      _initializeCountdownFromDrawingTime(drawingTime);
    }
    
    if (_groupId != null) {
      _initializeWithRealData();
    } else {
      // Fallback to demo mode
      _initializeDemoMode();
    }
  }

  @override
  void onClose() {
    _drawTimer?.cancel();
    _ballMovementTimer?.cancel();
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.onClose();
  }

  /// Initialize countdown from drawing time (called from pre-draw notification)
  void _initializeCountdownFromDrawingTime(DateTime drawingTime) {
    final now = DateTime.now();
    final timeUntilDraw = drawingTime.difference(now);
    
    if (timeUntilDraw.inSeconds > 0) {
      // Drawing is in the future, start countdown
      countdownSeconds.value = timeUntilDraw.inSeconds;
      isCountdownActive.value = true;
      currentCycleStatus.value = 'waiting';
      
      print('🎰 DEBUG: Starting countdown - ${timeUntilDraw.inSeconds} seconds until draw');
      
      // Start countdown timer
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (countdownSeconds.value > 0) {
          countdownSeconds.value--;
        } else {
          // Countdown complete, drawing should start
          timer.cancel();
          isCountdownActive.value = false;
          print('🎰 DEBUG: Countdown complete, drawing should start');
        }
      });
    } else {
      // Drawing time has passed or is now, start drawing immediately
      isCountdownActive.value = false;
      print('🎰 DEBUG: Drawing time has passed, starting immediately');
    }
  }

  /// Initialize with real API data
  Future<void> _initializeWithRealData() async {
    if (_groupId == null) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Load lottery numbers for the group
      await _loadLotteryNumbers();
      
      // Load previous draws
      await _loadPreviousDraws();
      
      // Start real-time cycle monitoring
      await _startCycleMonitoring();
      
    } catch (e) {
      errorMessage.value = 'Failed to load lottery data: $e';
      print('🎰 ERROR: Failed to initialize real data: $e');
      // Fallback to demo mode
      _initializeDemoMode();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load lottery numbers from API
  Future<void> _loadLotteryNumbers() async {
    if (_groupId == null) return;
    
    try {
      // Try rotation service first
      final response = await _lotteryService.getLotteryNumbers(_groupId!);
      
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        lotteryBalls.clear();
        
        for (var numberData in response.data!) {
          lotteryBalls.add(LotteryBall(
            number: numberData['lottery_number'] ?? numberData['number'] ?? '000',
            position: _generateRandomPosition(),
            isSelected: false,
            color: _generateBallColor(numberData['lottery_number'] ?? numberData['number'] ?? '000'),
          ));
        }
        
        print('🎰 DEBUG: Loaded ${lotteryBalls.length} lottery numbers from rotation service');
        return;
      } else {
        print('🎰 DEBUG: No lottery numbers from rotation service, trying group members');
      }
    } catch (e) {
      print('🎰 ERROR: Failed to load from rotation service: $e');
    }
    
    // Fallback: Try to get lottery numbers from group members
    await _loadLotteryNumbersFromGroupMembers();
  }

  /// Load lottery numbers from group members as fallback
  Future<void> _loadLotteryNumbersFromGroupMembers() async {
    if (_groupId == null) return;
    
    try {
      // First try to get lottery numbers from group history (includes member lottery numbers)
      print('🎰 DEBUG: Loading lottery numbers from group history');
      
      final groupService = Get.find<GroupService>();
      final response = await groupService.getGroupHistory(_groupId!);
      
      if (response.success && response.data != null) {
        final groupData = response.data!;
        final membersData = groupData['members'] as List<dynamic>? ?? [];
        
        lotteryBalls.clear();
        
        // Extract lottery numbers from members in group history
        for (var member in membersData) {
          final memberMap = member as Map<String, dynamic>;
          final lotteryNumberRaw = memberMap['lottery_number'];
          String? lotteryNumber;
          if (lotteryNumberRaw is int) {
            lotteryNumber = lotteryNumberRaw.toString().padLeft(3, '0');
          } else if (lotteryNumberRaw is String && lotteryNumberRaw.isNotEmpty) {
            lotteryNumber = lotteryNumberRaw;
          }
          
          if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
            lotteryBalls.add(LotteryBall(
              number: lotteryNumber,
              position: _generateRandomPosition(),
              isSelected: false,
              color: _generateBallColor(lotteryNumber),
            ));
          }
        }
        
        print('🎰 DEBUG: Loaded ${lotteryBalls.length} lottery numbers from group history members');
        
        // If still no lottery numbers, try regular group members endpoint
        if (lotteryBalls.isEmpty) {
          await _loadLotteryNumbersFromGroupMembersEndpoint();
        }
        
      } else {
        print('🎰 DEBUG: Group history failed, trying group members endpoint');
        await _loadLotteryNumbersFromGroupMembersEndpoint();
      }
    } catch (e) {
      print('🎰 ERROR: Failed to load from group history: $e');
      await _loadLotteryNumbersFromGroupMembersEndpoint();
    }
  }

  /// Load lottery numbers from group members endpoint
  Future<void> _loadLotteryNumbersFromGroupMembersEndpoint() async {
    if (_groupId == null) return;
    
    try {
      final groupService = Get.find<GroupService>();
      final response = await groupService.getGroupMembers(_groupId!);
      
      if (response.success && response.data != null) {
        final members = response.data!;
        lotteryBalls.clear();
        
        // Extract lottery numbers from members
        for (var member in members) {
          final lotteryNumber = member.lotteryNumber;
          if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
            lotteryBalls.add(LotteryBall(
              number: lotteryNumber,
              position: _generateRandomPosition(),
              isSelected: false,
              color: _generateBallColor(lotteryNumber),
            ));
          }
        }
        
        print('🎰 DEBUG: Loaded ${lotteryBalls.length} lottery numbers from group members endpoint');
        
        // If still no lottery numbers, generate from member positions
        if (lotteryBalls.isEmpty) {
          _generateLotteryNumbersFromMembers(members);
        }
        
      } else {
        print('🎰 DEBUG: Failed to load group members, using default numbers');
        _generateDefaultLotteryNumbers();
      }
    } catch (e) {
      print('🎰 ERROR: Failed to load from group members: $e');
      _generateDefaultLotteryNumbers();
    }
  }

  /// Generate lottery numbers from member positions if no lottery numbers assigned
  void _generateLotteryNumbersFromMembers(List<dynamic> members) {
    print('🎰 DEBUG: Generating lottery numbers from member positions');
    
    lotteryBalls.clear();
    for (int i = 0; i < members.length; i++) {
      final lotteryNumber = (i + 1).toString().padLeft(3, '0'); // 001, 002, 003, etc.
      
      lotteryBalls.add(LotteryBall(
        number: lotteryNumber,
        position: _generateRandomPosition(),
        isSelected: false,
        color: _generateBallColor(lotteryNumber),
      ));
    }
    
    print('🎰 DEBUG: Generated ${lotteryBalls.length} lottery numbers from member positions');
  }

  /// Generate default lottery numbers for demo
  void _generateDefaultLotteryNumbers() {
    print('🎰 DEBUG: Generating default lottery numbers');
    
    lotteryBalls.clear();
    for (int i = 1; i <= 25; i++) {
      final lotteryNumber = i.toString().padLeft(3, '0');
      lotteryBalls.add(LotteryBall(
        number: lotteryNumber,
        position: _generateRandomPosition(),
        isSelected: false,
        color: _generateBallColor(lotteryNumber),
      ));
    }
    
    print('🎰 DEBUG: Generated ${lotteryBalls.length} default lottery numbers');
  }

  /// Load previous draws (real data from API or group history)
  Future<void> _loadPreviousDraws() async {
    try {
      // Use group history endpoint directly (this is the correct source)
      await _loadPreviousDrawsFromGroupHistory();
      
    } catch (e) {
      print('🎰 ERROR: Failed to load previous draws: $e');
      // Final fallback to demo data
      _loadDemoPreviousDraws();
    }
  }

  /// Load previous draws from group history (same as group detail page)
  Future<void> _loadPreviousDrawsFromGroupHistory() async {
    if (_groupId == null) {
      _loadDemoPreviousDraws();
      return;
    }
    
    try {
      // Use the group history endpoint directly
      print('🎰 DEBUG: Loading previous draws from group history: /groups/$_groupId/history');
      
      final groupService = Get.find<GroupService>();
      final response = await groupService.getGroupHistory(_groupId!);
      
      if (response.success && response.data != null) {
        final groupData = response.data!;
        final winnersData = groupData['winners'] as List<dynamic>? ?? [];
        
        previousDraws.clear();
        
        // Process winners data to extract lottery numbers
        for (var winner in winnersData.take(10)) { // Take last 10 winners
          final winnerMap = winner as Map<String, dynamic>;
          final lotteryNumberRaw = winnerMap['lottery_number'];
          String? lotteryNumber;
          if (lotteryNumberRaw is int) {
            lotteryNumber = lotteryNumberRaw.toString().padLeft(3, '0');
          } else if (lotteryNumberRaw is String && lotteryNumberRaw.isNotEmpty) {
            lotteryNumber = lotteryNumberRaw;
          }
          
          if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
            previousDraws.add({
              'number': lotteryNumber,
              'time': _formatDrawTime(winnerMap['payout_date'] ?? winnerMap['created_at']),
              'cycle_number': winnerMap['cycle_number'] ?? 0,
            });
          }
        }
        
        print('🎰 DEBUG: Loaded ${previousDraws.length} previous draws from group history');
        print('🎰 DEBUG: Sample previous draws: ${previousDraws.take(3).toList()}');
        
        // If no winners found, still show something
        if (previousDraws.isEmpty) {
          print('🎰 DEBUG: No winners found in group history, using demo data');
          _loadDemoPreviousDraws();
        }
        
      } else {
        print('🎰 DEBUG: Group history API failed: ${response.message}');
        _loadDemoPreviousDraws();
      }
    } catch (e) {
      print('🎰 ERROR: Failed to load from group history: $e');
      _loadDemoPreviousDraws();
    }
  }

  /// Load demo previous draws data
  void _loadDemoPreviousDraws() {
    // Show empty state — no fake numbers
    previousDraws.clear();
    print('🎰 DEBUG: No previous draws found, showing empty state');
  }

  /// Start real-time cycle monitoring with adaptive frequency
  Future<void> _startCycleMonitoring() async {
    if (_groupId == null) return;
    
    // Initial status check
    await _checkCurrentCycleStatus();
    
    // Also get the drawing schedule for more detailed information
    await _loadDrawingSchedule();
    
    // Set up adaptive status checking
    _startAdaptiveStatusChecking();
  }

  /// Start adaptive status checking - more frequent when close to draw time
  void _startAdaptiveStatusChecking() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkCurrentCycleStatus();
      
      // If countdown is active and less than 2 minutes, check more frequently
      if (isCountdownActive.value && countdownSeconds.value <= 120) {
        timer.cancel();
        _startFrequentStatusChecking();
      }
    });
  }

  /// Start frequent status checking when close to draw time
  void _startFrequentStatusChecking() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkCurrentCycleStatus();
      
      // If countdown is no longer active or more than 2 minutes, go back to normal frequency
      if (!isCountdownActive.value || countdownSeconds.value > 120) {
        timer.cancel();
        _startAdaptiveStatusChecking();
      }
    });
  }

  /// Load drawing schedule for more detailed timing information
  Future<void> _loadDrawingSchedule() async {
    if (_groupId == null) return;
    
    try {
      final response = await _lotteryService.getDrawingSchedule(_groupId!);
      
      if (response.success && response.data != null) {
        final scheduleData = response.data!;
        print('🎰 DEBUG: Drawing schedule loaded: $scheduleData');
        
        // Extract schedule information for better countdown context
        final frequency = scheduleData['frequency'] as String?;
        final nextDrawing = scheduleData['next_drawing'] as Map<String, dynamic>?;
        
        if (nextDrawing != null) {
          final scheduledAt = nextDrawing['scheduled_at'] as String?;
          if (scheduledAt != null) {
            print('🎰 DEBUG: Next scheduled drawing: $scheduledAt (Frequency: $frequency)');
          }
        }
      }
    } catch (e) {
      print('🎰 ERROR: Failed to load drawing schedule: $e');
    }
  }

  /// Check current cycle status and update countdown
  Future<void> _checkCurrentCycleStatus() async {
    if (_groupId == null) return;
    
    try {
      final response = await _lotteryService.getCurrentCycle(_groupId!);
      
      if (response.success && response.data != null) {
        final cycleData = response.data!;
        final status = cycleData['status'] as String? ?? 'unknown';
        final nextDrawAt = cycleData['next_draw_at'] as String?;
        final currentWinner = cycleData['current_winner']?.toString();
        final cycleNumber = cycleData['cycle_number'] as int?;
        final groupName = cycleData['group_name'] as String?;
        final frequency = cycleData['frequency'] as String?;
        
        currentCycleStatus.value = status;
        
        // Update winner if available
        if (currentWinner != null && currentWinner.isNotEmpty) {
          selectedWinner.value = currentWinner;
          _markWinnerBall(currentWinner);
        }
        
        // Handle countdown based on status and real schedule
        if (status == 'waiting' && nextDrawAt != null) {
          _startCountdownToScheduledDraw(nextDrawAt, cycleNumber, groupName, frequency);
        } else if (status == 'drawing') {
          _handleAutomaticDrawing();
        } else if (status == 'completed') {
          _handleDrawCompleted();
        }
        
        print('🎰 DEBUG: Cycle status: $status, Next draw: $nextDrawAt, Cycle: $cycleNumber');
      }
    } catch (e) {
      print('🎰 ERROR: Failed to check cycle status: $e');
    }
  }

  /// Start countdown to scheduled draw based on real backend schedule
  void _startCountdownToScheduledDraw(String nextDrawTime, int? cycleNumber, String? groupName, String? frequency) {
    try {
      final nextDraw = DateTime.parse(nextDrawTime);
      final now = DateTime.now();
      final difference = nextDraw.difference(now);
      
      if (difference.inSeconds > 0) {
        countdownSeconds.value = difference.inSeconds;
        isCountdownActive.value = true;
        
        // Format next draw time with more context
        this.nextDrawTime.value = _formatNextDrawTime(nextDrawTime, cycleNumber, groupName, frequency);
        
        // Start countdown timer
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (countdownSeconds.value > 0) {
            countdownSeconds.value--;
          } else {
            timer.cancel();
            isCountdownActive.value = false;
            // Check if drawing has started automatically
            _checkCurrentCycleStatus();
          }
        });
        
        print('🎰 DEBUG: Real countdown started: ${difference.inSeconds} seconds to ${_formatDrawTime(nextDrawTime)}');
      } else {
        // Draw time has passed, check current status
        isCountdownActive.value = false;
        _checkCurrentCycleStatus();
      }
    } catch (e) {
      print('🎰 ERROR: Failed to parse next draw time: $e');
      // Fallback to checking status more frequently
      isCountdownActive.value = false;
    }
  }

  /// Format next draw time with additional context
  String _formatNextDrawTime(String nextDrawTime, int? cycleNumber, String? groupName, String? frequency) {
    try {
      final drawTime = DateTime.parse(nextDrawTime);
      final now = DateTime.now();
      final difference = drawTime.difference(now);
      
      String timeInfo;
      if (difference.inMinutes < 60) {
        timeInfo = 'in ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        timeInfo = 'in ${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        timeInfo = 'in ${difference.inDays} days';
      }
      
      String contextInfo = '';
      if (cycleNumber != null) {
        contextInfo += 'Cycle $cycleNumber';
      }
      if (frequency != null) {
        contextInfo += ' ($frequency)';
      }
      
      return contextInfo.isNotEmpty ? '$timeInfo - $contextInfo' : timeInfo;
    } catch (e) {
      return 'Scheduled Draw';
    }
  }

  /// Handle automatic drawing state
  void _handleAutomaticDrawing() {
    if (!isDrawing.value) {
      print('🎰 DEBUG: Handling automatic drawing');
      _startAutomaticDrawSequence();
    }
  }

  /// Handle draw completed state
  void _handleDrawCompleted() {
    isDrawing.value = false;
    isCountdownActive.value = false;
    
    // Refresh data to get latest results
    _loadPreviousDraws();
    
    print('🎰 DEBUG: Draw completed');
  }

  /// Start automatic draw sequence (visual animation)
  void _startAutomaticDrawSequence() {
    print('🎰 DEBUG: Starting automatic draw sequence');
    
    // Initial haptic feedback
    HapticFeedback.mediumImpact();
    
    isDrawing.value = true;
    selectedWinner.value = '';
    _drawDuration = 0;
    
    // Reset all balls
    for (var ball in lotteryBalls) {
      ball.isSelected = false;
      ball.position = _generateRandomPosition();
    }
    lotteryBalls.refresh();
    
    // Start the 4-second animation sequence
    _ballMovementTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      _drawDuration += 80;
      
      // Update ball positions with physics
      for (var ball in lotteryBalls) {
        ball.position = _generateRandomPosition();
      }
      lotteryBalls.refresh();
      
      // Haptic feedback every 500ms during drawing
      if (_drawDuration % 500 == 0) {
        HapticFeedback.lightImpact();
      }
      
      // End after 4 seconds
      if (_drawDuration >= 4000) {
        timer.cancel();
        print('🎰 DEBUG: Animation completed, fetching draw result');
        // Fix: schedule result fetch, mirroring _triggerManualDraw()
        Timer(const Duration(seconds: 1), () {
          _checkForDrawResult();
        });
      }
    });
  }

  /// Check for draw result from API
  Future<void> _checkForDrawResult({int retries = 0}) async {
    if (_groupId == null) return;
    
    try {
      final response = await _lotteryService.getCurrentWinner(_groupId!);
      
      if (response.success && response.data != null) {
        final winnerData = response.data!;
        final winnerNumber = winnerData['lottery_number']?.toString();
        
        if (winnerNumber != null && winnerNumber.isNotEmpty) {
          _selectWinnerFromAPI(winnerNumber);
        } else if (retries < 5) {
          Timer(const Duration(seconds: 2), () {
            _checkForDrawResult(retries: retries + 1);
          });
        } else {
          print('🎰 DEBUG: Max retries reached, falling back to random winner');
          _selectRandomWinner();
        }
      } else if (retries < 5) {
        Timer(const Duration(seconds: 2), () {
          _checkForDrawResult(retries: retries + 1);
        });
      } else {
        _selectRandomWinner();
      }
    } catch (e) {
      print('🎰 ERROR: Failed to check draw result: $e');
      _selectRandomWinner();
    }
  }

  /// Select winner based on API result
  void _selectWinnerFromAPI(String winnerNumber) {
    print('🎰 DEBUG: API winner selected: $winnerNumber');
    
    // Strong haptic feedback for winner selection
    HapticFeedback.heavyImpact();
    
    selectedWinner.value = winnerNumber;
    isDrawing.value = false;
    
    _markWinnerBall(winnerNumber);
    
    // Start celebration sequence
    _startCelebrationSequence();
    
    // Refresh previous draws
    Timer(const Duration(seconds: 2), () {
      _loadPreviousDraws();
    });
  }

  /// Mark the winner ball as selected
  void _markWinnerBall(String winnerNumber) {
    for (var ball in lotteryBalls) {
      ball.isSelected = ball.number == winnerNumber;
    }
    lotteryBalls.refresh();
  }

  /// Fallback to demo mode
  void _initializeDemoMode() {
    print('🎰 DEBUG: Initializing demo mode');
    _initializeLotteryBalls();
    _loadPreviousDraws(); // This will now try group history first, then fall back to demo
    
    // Simulate countdown for demo
    _simulateDemoCountdown();
  }

  /// Simulate demo countdown for testing (more realistic timing)
  void _simulateDemoCountdown() {
    // Simulate a more realistic countdown based on typical group frequencies
    // For demo, use 5 minutes (300 seconds) to show realistic timing
    final demoCountdownSeconds = 300; // 5 minutes
    countdownSeconds.value = demoCountdownSeconds;
    isCountdownActive.value = true;
    currentCycleStatus.value = 'waiting';
    nextDrawTime.value = 'Demo Mode - Next draw in 5 min';
    
    print('🎰 DEBUG: Demo countdown started: $demoCountdownSeconds seconds (5 minutes)');
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
        
        // Update display text as countdown progresses
        final remaining = countdownSeconds.value;
        if (remaining > 60) {
          final minutes = remaining ~/ 60;
          nextDrawTime.value = 'Demo Mode - Next draw in ${minutes}m ${remaining % 60}s';
        } else {
          nextDrawTime.value = 'Demo Mode - Next draw in ${remaining}s';
        }
      } else {
        timer.cancel();
        isCountdownActive.value = false;
        nextDrawTime.value = 'Demo Mode - Drawing now!';
        _startAutomaticDrawSequence();
        
        // Select random winner after animation
        Timer(const Duration(seconds: 4), () {
          _selectRandomWinner();
        });
      }
    });
  }

  /// Select random winner for demo/fallback
  void _selectRandomWinner() {
    if (lotteryBalls.isEmpty) return;
    
    final winnerIndex = _random.nextInt(lotteryBalls.length);
    final winner = lotteryBalls[winnerIndex];
    
    _selectWinnerFromAPI(winner.number);
  }

  /// Initialize lottery balls with numbers from arguments or default
  void _initializeLotteryBalls() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final List<String> numbers = arguments?['lotteryNumbers'] ?? _generateDefaultNumbers();
    
    print('🎰 DEBUG: Initializing lottery balls');
    print('🎰 DEBUG: Arguments: $arguments');
    print('🎰 DEBUG: Numbers: $numbers');
    
    lotteryBalls.clear();
    for (int i = 0; i < numbers.length; i++) {
      lotteryBalls.add(LotteryBall(
        number: numbers[i],
        position: _generateRandomPosition(),
        isSelected: false,
        color: _generateBallColor(numbers[i]),
      ));
    }
    
    print('🎰 DEBUG: Created ${lotteryBalls.length} lottery balls');
  }

  /// Generate default lottery numbers for demo
  List<String> _generateDefaultNumbers() {
    final numbers = <String>[];
    for (int i = 1; i <= 25; i++) {
      numbers.add(i.toString().padLeft(3, '0'));
    }
    return numbers;
  }

  /// Generate ball color based on number using enhanced high-contrast colors
  Color _generateBallColor(String number) {
    final int numValue = int.tryParse(number) ?? 0;
    
    // Use high-contrast colors that work well against dark teal background
    final colors = [
      const Color(0xFFFFD700), // Bright gold
      const Color(0xFFFF6B35), // Bright orange
      const Color(0xFF00E676), // Bright green
      const Color(0xFF2196F3), // Bright blue
      const Color(0xFFE91E63), // Bright pink
      const Color(0xFF9C27B0), // Bright purple
      const Color(0xFFFF9800), // Bright amber
      const Color(0xFF4CAF50), // Bright green
      const Color(0xFFFF5722), // Deep orange
      const Color(0xFF03DAC6), // Bright cyan
      const Color(0xFFFFEB3B), // Bright yellow
      const Color(0xFFFF1744), // Bright red
      const Color(0xFF00BCD4), // Bright cyan
      const Color(0xFF8BC34A), // Light green
      const Color(0xFFFF4081), // Pink accent
    ];
    return colors[numValue % colors.length];
  }

  /// Generate random position for ball in the machine with physics constraints
  Offset _generateRandomPosition() {
    // Create more realistic circular distribution
    final angle = _random.nextDouble() * 2 * pi;
    final radius = _random.nextDouble() * 80 + 20; // 20-100 radius
    return Offset(
      cos(angle) * radius,
      sin(angle) * radius,
    );
  }



  /// Format draw time for display
  String _formatDrawTime(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      final drawTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(drawTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get formatted countdown display with enhanced information
  String get countdownDisplay {
    final totalSeconds = countdownSeconds.value;
    
    if (totalSeconds >= 3600) {
      // More than 1 hour - show hours and minutes
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else if (totalSeconds >= 60) {
      // More than 1 minute - show minutes and seconds
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Less than 1 minute - show seconds only
      return '${totalSeconds}s';
    }
  }

  /// Manual start draw (for testing/demo purposes)
  void startDraw() {
    print('🎰 DEBUG: Manual startDraw() called');
    
    if (isDrawing.value || lotteryBalls.isEmpty) {
      print('🎰 DEBUG: Early return - isDrawing: ${isDrawing.value}, isEmpty: ${lotteryBalls.isEmpty}');
      return;
    }
    
    if (_groupId != null) {
      // In production mode, trigger via API
      _triggerManualDraw();
    } else {
      // Demo mode
      _startPremiumDrawSequence();
    }
  }

  /// Trigger manual draw via API (for testing)
  Future<void> _triggerManualDraw() async {
    if (_groupId == null) return;
    
    try {
      isLoading.value = true;
      final response = await _lotteryService.triggerDrawing(_groupId!);
      
      if (response.success) {
        _startAutomaticDrawSequence();
        
        // Check for result after animation
        Timer(const Duration(seconds: 5), () {
          _checkForDrawResult();
        });
      } else {
        errorMessage.value = response.message ?? 'Failed to trigger drawing';
      }
    } catch (e) {
      errorMessage.value = 'Failed to trigger drawing: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Premium draw sequence with multiple phases (demo mode)
  void _startPremiumDrawSequence() {
    print('🎰 DEBUG: Starting premium draw sequence');
    
    // Initial haptic feedback
    HapticFeedback.mediumImpact();
    
    isDrawing.value = true;
    selectedWinner.value = '';
    _drawDuration = 0;
    
    print('🎰 DEBUG: Set isDrawing to true');
    
    // Reset all balls
    for (var ball in lotteryBalls) {
      ball.isSelected = false;
      ball.position = _generateRandomPosition();
    }
    lotteryBalls.refresh();
    
    print('🎰 DEBUG: Reset ${lotteryBalls.length} balls');
    
    // Start premium animation sequence
    _ballMovementTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      _drawDuration += 80;
      
      // Update ball positions with physics
      for (var ball in lotteryBalls) {
        ball.position = _generateRandomPosition();
      }
      lotteryBalls.refresh();
      
      // Haptic feedback every 500ms during drawing
      if (_drawDuration % 500 == 0) {
        HapticFeedback.lightImpact();
        print('🎰 DEBUG: Draw duration: ${_drawDuration}ms');
      }
      
      // End after 4 seconds to match machine animation
      if (_drawDuration >= 4000) {
        print('🎰 DEBUG: Moving to winner selection');
        timer.cancel();
        _selectWinnerWithDrama();
      }
    });
  }

  /// Select winner with dramatic effect (demo mode)
  void _selectWinnerWithDrama() {
    if (lotteryBalls.isEmpty) return;
    
    // Stop all ball movement first
    _ballMovementTimer?.cancel();
    
    // Dramatic pause (matches machine selection timing)
    Future.delayed(const Duration(milliseconds: 500), () {
      // Strong haptic feedback for winner selection
      HapticFeedback.heavyImpact();
      
      final winnerIndex = _random.nextInt(lotteryBalls.length);
      final winner = lotteryBalls[winnerIndex];
      
      winner.isSelected = true;
      selectedWinner.value = winner.number;
      isDrawing.value = false;
      
      lotteryBalls.refresh();
      
      // Add to previous draws
      previousDraws.insert(0, {
        'number': winner.number,
        'time': 'Just now',
        'cycle_number': (previousDraws.isNotEmpty ? (previousDraws[0]['cycle_number'] ?? 0) + 1 : 1),
      });
      
      // Keep only last 10 draws
      if (previousDraws.length > 10) {
        previousDraws.removeRange(10, previousDraws.length);
      }
      
      // Celebration sequence
      _startCelebrationSequence();
    });
  }

  /// Premium celebration sequence
  void _startCelebrationSequence() {
    // Multiple haptic pulses for celebration
    HapticFeedback.heavyImpact();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.mediumImpact();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Reset the draw for another round
  void resetDraw() {
    selectedWinner.value = '';
    isDrawing.value = false;
    _drawTimer?.cancel();
    _ballMovementTimer?.cancel();
    _drawDuration = 0;
    
    // Light haptic feedback for reset
    HapticFeedback.lightImpact();
    
    // Reset all balls with smooth animation
    for (var ball in lotteryBalls) {
      ball.isSelected = false;
      ball.position = _generateRandomPosition();
    }
    lotteryBalls.refresh();
    
    // Restart countdown in demo mode
    if (_groupId == null) {
      _simulateDemoCountdown();
    }
  }

  /// Test method to verify controller is working
  void testController() {
    print('🎰 TEST: Controller test called');
    print('🎰 TEST: Balls count: ${lotteryBalls.length}');
    print('🎰 TEST: Is drawing: ${isDrawing.value}');
    print('🎰 TEST: Selected winner: ${selectedWinner.value}');
    print('🎰 TEST: Group ID: $_groupId');
    print('🎰 TEST: Countdown: ${countdownSeconds.value}');
    print('🎰 TEST: Status: ${currentCycleStatus.value}');
    print('🎰 TEST: Previous draws count: ${previousDraws.length}');
    print('🎰 TEST: Previous draws data: ${previousDraws.take(3).toList()}');
    
    // Force reload previous draws for testing
    _loadPreviousDraws();
    
    // Simple state change test
    isDrawing.value = !isDrawing.value;
    Future.delayed(const Duration(seconds: 1), () {
      isDrawing.value = !isDrawing.value;
    });
  }

  /// Refresh data manually
  Future<void> refreshData() async {
    if (_groupId != null) {
      await _initializeWithRealData();
    } else {
      await _loadPreviousDraws(); // Ensure previous draws are loaded even in demo mode
    }
  }

  void onDrawComplete() {
    // Premium celebration notification
    Get.snackbar(
      '🎉 Winner Selected!',
      'Lottery #${selectedWinner.value} has been drawn!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A1A1A),
      colorText: Colors.amber,
      duration: const Duration(seconds: 4),
      borderRadius: 15,
      margin: const EdgeInsets.all(20),
      boxShadows: [
        BoxShadow(
          color: Colors.amber.withValues(alpha: 0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
        ),
        child: const Icon(
          Icons.emoji_events,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}