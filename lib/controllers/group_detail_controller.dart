// Purpose: Controller for Group Detail page
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:et_digital_equb/models/member_model.dart';
import 'package:share_plus/share_plus.dart';

class GroupDetailController extends GetxController {
  final GroupService _groupService = GroupService.to;

  final Group group;
  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;
  final RxBool showAllMembers = false.obs;
  final RxList<GroupMember> members = <GroupMember>[].obs;
  final RxBool isMembersLoading = false.obs;
  final RxInt activeTab = 0.obs; // 0: Members, 1: Payments, 2: History
  final RxBool isPaymentsLoading = false.obs;
  final RxBool isHistoryLoading = false.obs;
  final RxBool isLotteryLoading = false.obs;
  final RxList<dynamic> payments = <dynamic>[].obs;
  final RxList<dynamic> history = <dynamic>[].obs;
  final RxList<dynamic> lottery = <dynamic>[].obs;
  final RxList<dynamic> membersWithPaymentStatus = <dynamic>[].obs;
  final RxMap<String, dynamic> groupHistoryData = <String, dynamic>{}.obs;
  final RxBool showLotteryDraw = false.obs;
  final RxList<String> availableLotteryNumbers = <String>[].obs;

  GroupDetailController({required this.group});

  /// Formats winner announcement with lottery number privacy protection
  /// Uses lottery number for public announcements, real name for personalized messages
  String _formatWinnerAnnouncement(Map<String, dynamic> winnerData) {
    final userName = winnerData['user_name'] as String? ?? 'Unknown';
    final lotteryNumber = winnerData['lottery_number']?.toString();
    
    // For public announcements, use lottery number if available
    // This maintains privacy while still showing winner information
    if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
      return 'Winner: #$lotteryNumber';
    }
    
    // Fallback to user name if lottery number is not available
    return 'Winner: $userName';
  }

  void setActiveTab(int tabIndex) {
    activeTab.value = tabIndex;
    // 0 = Payments, 1 = History
    if (tabIndex == 0) {
      loadPayments();
    } else if (tabIndex == 1) {
      loadHistory();
    }
  }

  Future<void> loadPayments() async {
    if (payments.isNotEmpty) return; // Don't reload if already loaded

    try {
      isPaymentsLoading.value = true;
      final response = await _groupService.getGroupHistory(group.id);

      if (response.success && response.data != null) {
        final groupData = response.data!;
        groupHistoryData.value = groupData;

        final paymentsData = groupData['payments'] as List<dynamic>?;
        final membersData = groupData['members'] as List<dynamic>?;

        if (paymentsData != null) {
          // Convert payment data to the expected format
          final paymentList = <Map<String, dynamic>>[];
          for (final payment in paymentsData) {
            final paymentMap = payment as Map<String, dynamic>;
            paymentList.add({
              'id': paymentMap['id'],
              'user_id': paymentMap['user_id'],
              'amount': paymentMap['amount'],
              'date': DateTime.parse(
                paymentMap['created_at'],
              ).toString().split(' ')[0],
              'status': paymentMap['status'],
              'member': paymentMap['user_name'] ?? 'Unknown',
              'cycle_number': paymentMap['cycle_number'],
            });
          }
          payments.assignAll(paymentList);
        }

        // Store members with payment status for detailed display
        if (membersData != null) {
          membersWithPaymentStatus.assignAll(membersData);
        }
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to load payments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPaymentsLoading.value = false;
    }
  }

  Future<void> loadHistory() async {
    if (history.isNotEmpty) return; // Don't reload if already loaded

    try {
      isHistoryLoading.value = true;
      final response = await _groupService.getGroupHistory(group.id);

      if (response.success && response.data != null) {
        final groupData = response.data!;
        groupHistoryData.value = groupData;

        final winnersData = groupData['winners'] as List<dynamic>?;
        final membersData = groupData['members'] as List<dynamic>?;

        if (winnersData != null) {
          // Convert winner data to the expected format
          final historyList = <Map<String, dynamic>>[];
          for (final winner in winnersData) {
            final winnerMap = winner as Map<String, dynamic>;
            historyList.add({
              'action': _formatWinnerAnnouncement(winnerMap),
              'winner_name': winnerMap['user_name'] ?? 'Unknown',
              'lottery_number': winnerMap['lottery_number']?.toString(),
              'date': DateTime.parse(
                winnerMap['payout_date'],
              ).toString().split(' ')[0],
              'initiator': 'System',
              'cycle_number': winnerMap['cycle_number'],
              'amount': winnerMap['amount'],
              'turn_position': winnerMap['turn_position'],
            });
          }
          history.assignAll(historyList);
        }

        // Store members with payment status for detailed display
        if (membersData != null) {
          membersWithPaymentStatus.assignAll(membersData);
        }
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to load history',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isHistoryLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadMembers();
    loadGroupDetails();
    _updateLotteryNumbers();
  }

  /// Pull-to-refresh — reloads all group data
  Future<void> refresh() async {
    members.clear();
    payments.clear();
    history.clear();
    membersWithPaymentStatus.clear();
    groupHistoryData.clear();
    await Future.wait([
      loadMembers(),
      loadGroupDetails(),
    ]);
  }

  /// Update available lottery numbers based on group members
  void _updateLotteryNumbers() {
    if (group.status == 'started') {
      // Extract lottery numbers from members with payment status
      final numbers = <String>[];
      for (final member in membersWithPaymentStatus) {
        if (member is Map<String, dynamic>) {
          final lotteryNumber = member['lottery_number']?.toString();
          if (lotteryNumber != null && lotteryNumber.isNotEmpty) {
            numbers.add(lotteryNumber);
          }
        }
      }
      availableLotteryNumbers.assignAll(numbers);
    }
  }

  /// Returns the current user's lottery number from membersWithPaymentStatus
  String? get currentUserLotteryNumber {
    try {
      final currentUserId = Get.find<AuthService>().currentUser.value?.id;
      if (currentUserId == null) return null;

      for (final member in membersWithPaymentStatus) {
        if (member is Map<String, dynamic>) {
          final userId = member['user']?['id'] as String?;
          if (userId == currentUserId) {
            final raw = member['lottery_number'];
            if (raw == null) return null;
            // lottery_number comes as int from the backend — format to 3-digit string
            if (raw is int) return raw.toString().padLeft(3, '0');
            final s = raw.toString();
            return s.isNotEmpty ? s.padLeft(3, '0') : null;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Toggle lottery draw visibility
  void toggleLotteryDraw() {
    showLotteryDraw.value = !showLotteryDraw.value;
  }

  /// Check if lottery draw should be available
  bool get canShowLotteryDraw {
    // Access observable variables to make this getter reactive
    // This ensures GetX can track changes to these observables
    availableLotteryNumbers.length; // Access to make reactive
    return true; // For demo purposes, always show
    // return group.status == 'started' && availableLotteryNumbers.isNotEmpty; // Uncomment for production
  }

  Future<void> loadGroupDetails() async {
    try {
      print('GroupDetailController.loadGroupDetails - Loading group history for ${group.id}');
      final response = await _groupService.getGroupHistory(group.id);

      if (response.success && response.data != null) {
        final groupData = response.data!;
        print('GroupDetailController.loadGroupDetails - Success, updating groupHistoryData');
        
        // Store the complete group history data
        groupHistoryData.value = groupData;
        
        // Also store members with payment status for the Members tab
        final membersData = groupData['members'] as List<dynamic>?;
        if (membersData != null) {
          print('GroupDetailController.loadGroupDetails - Found ${membersData.length} members with payment status');
          membersWithPaymentStatus.assignAll(membersData);
          _updateLotteryNumbers(); // Update lottery numbers when member data is loaded
        }
        
        // Pre-populate payments data (so it's available when switching tabs)
        final paymentsData = groupData['payments'] as List<dynamic>?;
        if (paymentsData != null) {
          print('GroupDetailController.loadGroupDetails - Found ${paymentsData.length} payments');
          final paymentList = <Map<String, dynamic>>[];
          for (final payment in paymentsData) {
            final paymentMap = payment as Map<String, dynamic>;
            paymentList.add({
              'id': paymentMap['id'],
              'user_id': paymentMap['user_id'],
              'amount': paymentMap['amount'],
              'date': DateTime.parse(
                paymentMap['created_at'],
              ).toString().split(' ')[0],
              'status': paymentMap['status'],
              'member': paymentMap['user_name'] ?? 'Unknown',
              'cycle_number': paymentMap['cycle_number'],
            });
          }
          payments.assignAll(paymentList);
        }
        
        // Pre-populate history data (so it's available when switching tabs)
        final winnersData = groupData['winners'] as List<dynamic>?;
        if (winnersData != null) {
          print('GroupDetailController.loadGroupDetails - Found ${winnersData.length} winners');
          final historyList = <Map<String, dynamic>>[];
          for (final winner in winnersData) {
            final winnerMap = winner as Map<String, dynamic>;
            historyList.add({
              'action': _formatWinnerAnnouncement(winnerMap),
              'winner_name': winnerMap['user_name'] ?? 'Unknown',
              'lottery_number': winnerMap['lottery_number']?.toString(),
              'date': DateTime.parse(
                winnerMap['payout_date'],
              ).toString().split(' ')[0],
              'initiator': 'System',
              'cycle_number': winnerMap['cycle_number'],
              'amount': winnerMap['amount'],
              'turn_position': winnerMap['turn_position'],
            });
          }
          history.assignAll(historyList);
        }
        
        print('GroupDetailController.loadGroupDetails - Data loaded successfully');
        print('GroupDetailController.loadGroupDetails - current_round: ${groupData['current_round']}');
        print('GroupDetailController.loadGroupDetails - rounds_remaining: ${groupData['rounds_remaining']}');
      } else {
        print('GroupDetailController.loadGroupDetails - Failed: ${response.message}');
      }
    } catch (e) {
      print('GroupDetailController.loadGroupDetails - Error: $e');
      // Silently handle errors since this is just for additional details
    }
  }

  Future<void> joinGroup() async {
    try {
      isJoining.value = true;

      final response = await _groupService.joinGroup(
        group.id,
        acceptTerms: true,
      );

      if (response.success) {
        String message = response.message ?? 'Successfully joined group';

        // Handle different group types
        if (group.type == 'private') {
          message = 'Join request sent! Waiting for group leader approval.';
        } else if (group.type == 'invite') {
          message =
              'This group is invitation-only. Please contact the group leader.';
        }

        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // For public groups, navigate back immediately
        // For private groups, show message and stay on page
        if (group.type == 'public') {
          Get.back();
        }
      } else {
        // Improved error messages
        String errorMessage = response.message ?? 'Failed to join group';

        // Handle specific error cases
        if (errorMessage.toLowerCase().contains('already a member')) {
          errorMessage = 'You are already a member of this group.';
        } else if (errorMessage.toLowerCase().contains('full')) {
          errorMessage = 'This group is full. Please try another group.';
        } else if (errorMessage.toLowerCase().contains('permission')) {
          errorMessage = 'You do not have permission to join this group.';
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to join group';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 400) {
          errorMessage = 'Invalid request. Please check the group details.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to join this group.';
        } else if (statusCode == 404) {
          errorMessage = 'Group not found.';
        } else if (statusCode == 409) {
          errorMessage = 'You are already a member of this group.';
        } else {
          errorMessage = e.response?.data['message'] as String? ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => joinGroup(), // Retry
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isJoining.value = false;
    }
  }

  void toggleShowAllMembers() {
    showAllMembers.value = !showAllMembers.value;
  }

  Future<void> loadMembers() async {
    try {
      isMembersLoading.value = true;
      final response = await _groupService.getGroupMembers(group.id);

      if (response.success && response.data != null) {
        members.assignAll(response.data!);
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to load members',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isMembersLoading.value = false;
    }
  }

  Future<void> leaveGroup() async {
    final currentUserId = Get.find<AuthService>().currentUser.value?.id;
    if (currentUserId == null) return;

    final myMember = members.firstWhereOrNull(
      (m) => m.user.id == currentUserId && m.status == 'active',
    );
    if (myMember == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Leave Group'),
        content: const Text(
          'Are you sure you want to leave this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      final response = await _groupService.leaveGroup(group.id, myMember.id);

      if (response.success) {
        Get.back(); // pop group detail
        Get.snackbar(
          'Left Group',
          response.message ?? 'You have left the group.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to leave group.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> inviteToGroup() async {
    final String inviteLink = 'https://etequb.com/invite/${group.id}';
    final String message =
        'Join my Equb group "${group.name}" on ET Digital Equb!\n\n'
        'Tap to join: $inviteLink';

    Share.share(
      message,
      subject: 'Join ${group.name} on ET Digital Equb',
    );
  }
}
