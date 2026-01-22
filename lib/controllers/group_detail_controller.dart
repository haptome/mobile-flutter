// Purpose: Controller for Group Detail page
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
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

  GroupDetailController({required this.group});

  void setActiveTab(int tabIndex) {
    activeTab.value = tabIndex;
    // Load data for the selected tab if needed
    if (tabIndex == 1) {
      // Payments tab
      loadPayments();
    } else if (tabIndex == 2) {
      // History tab
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
        final paymentsData = groupData['payments'] as List<dynamic>?;

        if (paymentsData != null) {
          // Convert payment data to the expected format
          final paymentList = <Map<String, dynamic>>[];
          for (final payment in paymentsData) {
            final paymentMap = payment as Map<String, dynamic>;
            paymentList.add({
              'amount': paymentMap['amount'],
              'date': DateTime.parse(
                paymentMap['created_at'],
              ).toString().split(' ')[0],
              'status': paymentMap['status'],
              'member': paymentMap['user']?['full_name'] ?? 'Unknown',
            });
          }
          payments.assignAll(paymentList);
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
        final winnersData = groupData['winners'] as List<dynamic>?;

        if (winnersData != null) {
          // Convert winner data to the expected format
          final historyList = <Map<String, dynamic>>[];
          for (final winner in winnersData) {
            final winnerMap = winner as Map<String, dynamic>;
            historyList.add({
              'action':
                  'Winner Selected: ${winnerMap['user']?['full_name'] ?? 'Unknown'}',
              'date': DateTime.parse(
                winnerMap['drawn_at'],
              ).toString().split(' ')[0],
              'initiator': 'System',
              'round': winnerMap['round_number'],
            });
          }
          history.assignAll(historyList);
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
  }

  Future<void> loadGroupDetails() async {
    try {
      final response = await _groupService.getGroupHistory(group.id);

      if (response.success && response.data != null) {
        final groupData = response.data!;

        // Update group with actual data from history
        if (groupData.containsKey('current_round')) {
          // Note: We can't modify the immutable group object directly here
          // This is just for future enhancement
        }
      }
    } catch (e) {
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

  Future<void> inviteToGroup() async {
    try {
      // Generate or get the invite link from the backend
      final response = await _groupService.generateInviteLink(group.id);

      if (response.success && response.data != null) {
        final String inviteLink = response.data!;
        final String message =
            'Join our Ekub group! ${group.name}. Click the link to join: $inviteLink';

        Share.share(
          message,
          subject: 'Invite to join ${group.name} Ekub Group',
        );
      } else {
        // Fallback to a default link if the API call fails
        final String inviteLink = 'https://et-ekub.com/join-group/${group.id}';
        final String message =
            'Join our Ekub group! ${group.name}. Click the link to join: $inviteLink';

        Share.share(
          message,
          subject: 'Invite to join ${group.name} Ekub Group',
        );
      }
    } catch (e) {
      // Fallback to a default link if there's an error
      final String inviteLink = 'https://et-ekub.com/join-group/${group.id}';
      final String message =
          'Join our Ekub group! ${group.name}. Click the link to join: $inviteLink';

      Share.share(message, subject: 'Invite to join ${group.name} Ekub Group');
    }
  }
}
