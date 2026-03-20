// Purpose: Group Detail page - shows group details, members, join button
// Author: Auto-generated

import 'package:et_digital_equb/controllers/group_detail_controller.dart';
import 'package:et_digital_equb/controllers/payment_controller.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/current_cycle_card.dart';
import 'package:et_digital_equb/core/widgets/payment_logo.dart';
import 'package:et_digital_equb/core/widgets/payment_method_card.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:et_digital_equb/features/payment/presentation/select_payment_method_view.dart';
import 'package:et_digital_equb/widgets/lottery_number_badge.dart';
import 'package:et_digital_equb/widgets/live_lottery_draw.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/group_model.dart';

// Simple number formatting function
String formatCurrencyShort(num value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

// Helper function to determine if lottery numbers should be shown
bool shouldShowLotteryNumber(String? groupStatus, String? lotteryNumber) {
  return groupStatus == 'started' &&
         lotteryNumber != null &&
         lotteryNumber.isNotEmpty;
}

class GroupDetailView extends StatelessWidget {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get group from arguments or from controller if already registered
    Group? group;
    if (Get.isRegistered<GroupDetailController>()) {
      group = Get.find<GroupDetailController>().group;
    } else {
      group = Get.arguments as Group?;
      if (group == null) {
        // If no group, show error
        return ScaffoldWithBottomBar(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.lightTextPrimary,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(child: Text('Group not found')),
        );
      }
      Get.put(GroupDetailController(group: group));
    }

    final controller = Get.find<GroupDetailController>();

    return ScaffoldWithBottomBar(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text(
          group.name,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          left: AppSizes.paddingLarge,
          right: AppSizes.paddingLarge,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image area
            SizedBox(
              // height: 100,
              child: Center(
                child: Card(
                  color: AppColors.lightBackground,
                  shadowColor: AppColors.black.withOpacity(0.4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                group.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.splashBackground,
                                ).copyWith(overflow: TextOverflow.ellipsis),
                              ),
                            ),

                            // const SizedBox(width: 6),
                            Container(
                              width: 1,
                              height: 15,
                              color: AppColors.borderLightGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)} ${group.contributionAmount}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppColors.textLightGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '№ ET-${group.id.substring(0, 9)}',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textLightGray,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(group.targetMembers / (group.frequency == 'weekly' ? 4 : 1)).toStringAsFixed(0)} M',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textLightGray,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${formatCurrencyShort(group.contributionAmount * group.targetMembers)}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: AppColors.splashBackground,
                              ),
                            ),
                          ],
                        ),
                        // the last cycle winner/winners
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Your Lottery Number card — shown when group is started
            if (group.status == 'started')
              Obx(() {
                final lotteryNum = controller.currentUserLotteryNumber;
                if (lotteryNum == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.85),
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Lottery Number',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#$lotteryNum',
                              style: GoogleFonts.montserrat(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        group!.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            // Last Winner Card
            Obx(() {
              if (controller.history.isEmpty) {
                return const SizedBox.shrink();
              }

              // Get the most recent winner(s)
              final recentWinners = controller.history.take(3).toList();

              return Card(
                color: AppColors.lightBackground,
                shadowColor: AppColors.black.withOpacity(0.4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recentWinners.length == 1 ? 'Last Winner' : 'Recent Winners',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...recentWinners.map((winner) {
                        final winnerMap = winner as Map<String, dynamic>;
                        final lotteryNumber = winnerMap['lottery_number'] as String?;
                        final cycleNumber = winnerMap['cycle_number'] ?? 0;
                        final amount = winnerMap['amount'] ?? 0;
                        final date = winnerMap['date'] ?? '';

                        // Use lottery number for display if available (privacy protection)
                        final displayName = (lotteryNumber != null && lotteryNumber.isNotEmpty) 
                            ? 'Lottery #$lotteryNumber' 
                            : 'Winner #${cycleNumber.toString().padLeft(3, '0')}';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber[700],
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cycle $cycleNumber • $date',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: AppColors.textLightGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${formatCurrencyShort(amount)} ETB',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Progress Card
            Card(
              color: AppColors.lightBackground,
              shadowColor: AppColors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ekub_progress'.tr,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // Live lottery draw button
                        Obx(() {
                          if (controller.canShowLotteryDraw) {
                            return LotteryDrawButton(
                              onPressed: () {
                                // Parse next draw date to pass as drawingTime for countdown
                                DateTime? nextDrawDateTime;
                                final nextDrawDateStr = controller.groupHistoryData['next_draw_date'] as String?;
                                if (nextDrawDateStr != null) {
                                  try {
                                    nextDrawDateTime = DateTime.parse(nextDrawDateStr);
                                  } catch (_) {}
                                }
                                Get.toNamed(
                                  '/lottery-draw',
                                  arguments: {
                                    'lotteryNumbers': controller.availableLotteryNumbers,
                                    'groupName': group?.name ?? 'Group',
                                    'groupId': group?.id,
                                    'drawingTime': nextDrawDateTime,
                                  },
                                );
                              },
                              isEnabled: true,
                              tooltip: 'Open lottery draw machine',
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Round text with proper Obx usage
                    Obx(
                      () => Text(
                        () {
                          if (group == null) return 'Round 1 of 0';

                          String roundText =
                              'Round 1 of ${group.targetMembers}';
                          if (controller.groupHistoryData.isNotEmpty &&
                              controller.groupHistoryData['current_round'] !=
                                  null) {
                            final currentRound =
                                controller.groupHistoryData['current_round']
                                    as int;
                            final scheduleCycles =
                                controller.groupHistoryData['schedule_cycles']
                                    as int? ??
                                1;
                            roundText =
                                'Round $currentRound of ${group.targetMembers * scheduleCycles}';
                          }
                          return roundText;
                        }(),
                        style: GoogleFonts.montserrat(
                          color: AppColors.textLightGray,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress indicator with proper Obx usage
                    Obx(
                      () => () {
                        if (group == null) return const SizedBox.shrink();

                        double progressValue = 0.0;
                        if (controller.groupHistoryData.isNotEmpty) {
                          final currentRound =
                              controller.groupHistoryData['current_round']
                                  as int? ??
                              0;
                          final totalRounds =
                              (controller.groupHistoryData['schedule_cycles']
                                      as int? ??
                                  1) *
                              group.targetMembers;
                          progressValue = totalRounds > 0
                              ? (currentRound / totalRounds)
                              : 0.0;
                        } else {
                          progressValue =
                              (group.currentMembers /
                              (group.targetMembers == 0
                                  ? 1
                                  : group.targetMembers));
                        }

                        return Row(
                          children: [
                            Flexible(
                              child: LinearProgressIndicator(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                value: progressValue,
                                minHeight: 8,
                                backgroundColor: Colors.purple.shade50,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progressValue * 100).round()}%',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 30,
                              child: Text(
                                'rounds_completed'.tr,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.textLightGray,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Rounds completed
                            Obx(
                              () => () {
                                if (group == null)
                                  return const SizedBox.shrink();

                                String roundsCompleted =
                                    '${group.currentMembers}';
                                if (controller.groupHistoryData.isNotEmpty &&
                                    controller
                                            .groupHistoryData['current_round'] !=
                                        null) {
                                  roundsCompleted = controller
                                      .groupHistoryData['current_round']
                                      .toString();
                                }
                                return SizedBox(
                                  width: 70,
                                  height: 30,
                                  child: Text(
                                    roundsCompleted,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 30,

                              child: Text(
                                'rounds_remaining'.tr,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.textLightGray,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Rounds remaining
                            Obx(
                              () => () {
                                if (group == null)
                                  return const SizedBox.shrink();

                                String roundsRemaining =
                                    '${(group.targetMembers - group.currentMembers).clamp(0, group.targetMembers)}';
                                if (controller.groupHistoryData.isNotEmpty &&
                                    controller
                                            .groupHistoryData['rounds_remaining'] !=
                                        null) {
                                  roundsRemaining = controller
                                      .groupHistoryData['rounds_remaining']
                                      .toString();
                                }
                                return SizedBox(
                                  width: 70,
                                  height: 30,
                                  child: Text(
                                    roundsRemaining,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 70,

                              child: Text(
                                'total_pool'.tr,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.textLightGray,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              height: 30,
                              child: Text(
                                '${formatCurrencyShort(group.contributionAmount * group.targetMembers)}',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 70,
                              child: Text(
                                'next_draw'.tr,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.textLightGray,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 30,
                              width: 70,
                              child: Obx(
                                () => () {
                                  if (group == null)
                                    return const SizedBox.shrink();

                                  String nextDraw =
                                      '${group.startDate != null ? '${_formatDate(group.startDate!)}' : 'Dec 15'}';
                                  if (controller.groupHistoryData.isNotEmpty &&
                                      controller
                                              .groupHistoryData['next_draw_date'] !=
                                          null) {
                                    try {
                                      final nextDrawDate = DateTime.parse(
                                        controller
                                            .groupHistoryData['next_draw_date'],
                                      );
                                      nextDraw = _formatDate(nextDrawDate);
                                    } catch (e) {
                                      // Keep default value
                                    }
                                  }
                                  return Text(
                                    nextDraw,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                }(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tabs (Members, Payments, History)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab('Members', 0),
                  _buildTab('Payments', 1),
                  _buildTab('History', 2),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tab Content
            Card(
              color: AppColors.lightBackground,
              shadowColor: AppColors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conditionally render content based on active tab
                    Obx(() {
                      if (!Get.isRegistered<GroupDetailController>()) {
                        return const SizedBox.shrink();
                      }

                      final controller = Get.find<GroupDetailController>();

                      switch (controller.activeTab.value) {
                        case 0: // Members Tab
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Members - ${group?.currentMembers ?? 0}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.inviteToGroup();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xffc6c92a,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        minimumSize: const Size(80, 36),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        'Invite',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey[200]),
                              // Members list - filtered to show only current user and leader
                              Obx(() {
                                if (group == null) {
                                  return const SizedBox.shrink();
                                }

                                final currentUserId = Get.find<AuthService>().currentUser.value?.id;
                                final allMembers =
                                    controller
                                        .membersWithPaymentStatus
                                        .isNotEmpty
                                    ? controller.membersWithPaymentStatus
                                    : controller.members;
                                
                                // Filter to show only current user and leader
                                final filteredMembers = allMembers.where((member) {
                                  String? userId;
                                  if (member is Map<String, dynamic>) {
                                    userId = member['user']?['id'] as String?;
                                  } else {
                                    try {
                                      userId = (member as dynamic).user?.id as String?;
                                    } catch (e) {
                                      userId = null;
                                    }
                                  }
                                  
                                  // Show if it's the current user OR the group leader
                                  return userId == currentUserId || userId == group?.leaderId;
                                }).toList();

                                final displayCount = filteredMembers.length;

                                return Column(
                                  children: [
                                    if (controller.isMembersLoading.value &&
                                        filteredMembers.isEmpty) ...[
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ] else if (filteredMembers.isEmpty) ...[
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text('No member information available'),
                                      ),
                                    ] else ...[
                                      ...List.generate(displayCount, (i) {
                                        final member = filteredMembers[i];

                                        // Determine status color and text
                                        String statusText = 'on_hold'.tr;
                                        Color statusColor = Colors.grey;
                                        bool isCurrentUserPayment = false;
                                        int? currentCycleNumber;

                                        if (member is Map<String, dynamic>) {
                                          // Check if this is the current user's payment
                                          final userId =
                                              member['user']?['id'] as String?;
                                          final currentUserId =
                                              Get.find<AuthService>()
                                                  .currentUser
                                                  .value
                                                  ?.id;
                                          isCurrentUserPayment =
                                              userId == currentUserId;

                                          // Get current cycle number from group history data
                                          currentCycleNumber =
                                              controller
                                                      .groupHistoryData['current_round']
                                                  as int?;

                                          // Check if group start date is in the future (using date-only comparison)
                                          final groupStartDate =
                                              group?.startDate;
                                          final today = DateTime.now();
                                          final isFutureGroup =
                                              groupStartDate != null &&
                                              DateTime(
                                                groupStartDate.year,
                                                groupStartDate.month,
                                                groupStartDate.day,
                                              ).isAfter(
                                                DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                ),
                                              );
                                          print(
                                            "isFutureGroup: $isFutureGroup, groupStartDate: ${groupStartDate?.toIso8601String()}, today: ${DateTime(today.year, today.month, today.day).toIso8601String()}",
                                          );

                                          if (isFutureGroup) {
                                            // Future start date - show "On Hold"
                                            statusText = 'on_hold'.tr;
                                            statusColor = Colors.grey;
                                          } else {
                                            // Past start date - check payment status
                                            final paymentStatus =
                                                member['payment_status']
                                                    as String?;

                                            if (paymentStatus == 'success') {
                                              statusText = 'Paid';
                                              statusColor = Colors.green;
                                            } else if (paymentStatus ==
                                                'failed') {
                                              statusText = 'Failed';
                                              statusColor = Colors.red;
                                            } else if (paymentStatus ==
                                                'no_payment') {
                                              // Show cycle info for unpaid members
                                              if (currentCycleNumber != null) {
                                                statusText =
                                                    'R-$currentCycleNumber Not Paid';
                                              } else {
                                                statusText = 'not_paid'.tr;
                                              }
                                              statusColor = Colors.orange;
                                            } else {
                                              // Fallback
                                              statusText = 'Unknown';
                                              statusColor = Colors.grey;
                                            }
                                          }
                                        }

                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                child:
                                                    member
                                                        is Map<String, dynamic>
                                                    ? (member['user']?['profile_pic_url'] !=
                                                                  null &&
                                                              member['user']?['profile_pic_url']!
                                                                  .isNotEmpty
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              child: Image.network(
                                                                member['user']?['profile_pic_url'],
                                                                width: 40,
                                                                height: 40,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons.person,
                                                              color: Colors
                                                                  .black54,
                                                            ))
                                                    : (member.user.profilePicUrl !=
                                                                  null &&
                                                              member
                                                                  .user
                                                                  .profilePicUrl!
                                                                  .isNotEmpty
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              child: Image.network(
                                                                member
                                                                    .user
                                                                    .profilePicUrl!,
                                                                width: 40,
                                                                height: 40,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons.person,
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(
                                                    (member is Map<String, dynamic>)
                                                        ? (member['user']?['full_name'] ??
                                                              'Unknown')
                                                        : member.user.fullName,
                                                    style: GoogleFonts.montserrat(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  // Show lottery number if group is started and lottery number exists
                                                  if (shouldShowLotteryNumber(group?.status, 
                                                      (member is Map<String, dynamic>) 
                                                          ? member['lottery_number'] as String?
                                                          : member.lotteryNumber)) ...[
                                                    const SizedBox(width: 8),
                                                    LotteryNumberBadge(
                                                      lotteryNumber: (member is Map<String, dynamic>) 
                                                          ? member['lottery_number'] as String
                                                          : member.lotteryNumber!,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (member
                                                            is Map<
                                                              String,
                                                              dynamic
                                                            >)
                                                        ? (member['user']?['phone'] ??
                                                              '')
                                                        : member.user.phone,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          color: AppColors
                                                              .textLightGray,
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                                  if (member
                                                          is Map<
                                                            String,
                                                            dynamic
                                                          > &&
                                                      member['last_payment_date'] !=
                                                          null) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      () {
                                                        try {
                                                          final date =
                                                              DateTime.parse(
                                                                member['last_payment_date'],
                                                              );
                                                          return 'Last payment: ${_formatDate(date)}';
                                                        } catch (e) {
                                                          // If date parsing fails, show raw date or fallback
                                                          return 'Last payment: ${member['last_payment_date']}';
                                                        }
                                                      }(),
                                                      style:
                                                          GoogleFonts.montserrat(
                                                            color: AppColors
                                                                .textLightGray,
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              trailing: GestureDetector(
                                                // onTap:
                                                //     isCurrentUserPayment &&
                                                //         statusText != 'Paid' &&
                                                //         statusText != 'on_hold'.tr &&
                                                //         group != null
                                                //     ? () {
                                                //         // Capture non-null group reference
                                                //         final nonNullGroup =
                                                //             group!;
                                                //         // Show payment method selection as bottom sheet
                                                //         showModalBottomSheet(
                                                //           context: Get.context!,
                                                //           builder: (context) =>
                                                //               SelectPaymentMethodView(
                                                //                 ekubId:
                                                //                     nonNullGroup
                                                //                         .id,
                                                //                 amount: nonNullGroup
                                                //                     .contributionAmount
                                                //                     .toDouble(),
                                                //                 cycleNumber:
                                                //                     currentCycleNumber,
                                                //               ),
                                                //           isScrollControlled:
                                                //               true,
                                                //           shape: const RoundedRectangleBorder(
                                                //             borderRadius:
                                                //                 BorderRadius.vertical(
                                                //                   top:
                                                //                       Radius.circular(
                                                //                         20,
                                                //                       ),
                                                //                 ),
                                                //           ),
                                                //         );
                                                //       }
                                                //     : null,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    color: statusColor,
                                                  ),
                                                  child: Text(
                                                    statusText,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey[200],
                                              indent: 72,
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          );
                        case 1: // Payments Tab
                          // Ensure PaymentController is registered
                          if (!Get.isRegistered<PaymentController>()) {
                            Get.put(PaymentController());
                          }
                          final paymentController = Get.find<PaymentController>();
                          
                          // Get current cycle information from group history data
                          final currentCycleNumber = controller.groupHistoryData['current_round'] as int?;
                          final nextDrawDate = controller.groupHistoryData['next_draw_date'] as String?;
                          
                          // Active cycle = completed draws + 1 (e.g. 0 draws done → cycle 1 is active)
                          final activeCycleNumber = (currentCycleNumber ?? 0) + 1;
                          
                          // Determine payment status for current user FOR THE ACTIVE CYCLE
                          final currentUserId = Get.find<AuthService>().currentUser.value?.id;
                          final currentUserMember = controller.membersWithPaymentStatus.firstWhereOrNull(
                            (member) {
                              if (member is Map<String, dynamic>) {
                                return member['user']?['id'] == currentUserId;
                              }
                              return false;
                            },
                          );
                          
                          String paymentStatus = 'pending';
                          if (currentUserMember != null && currentUserMember is Map<String, dynamic>) {
                            // Check payment_history_per_cycle for the active cycle first
                            final cycleHistory = currentUserMember['payment_history_per_cycle'] as List<dynamic>?;
                            if (cycleHistory != null && cycleHistory.isNotEmpty) {
                              final activeCyclePayment = cycleHistory.firstWhereOrNull(
                                (c) => c is Map<String, dynamic> && c['cycle_number'] == activeCycleNumber,
                              );
                              if (activeCyclePayment is Map<String, dynamic>) {
                                final cycleStatus = activeCyclePayment['payment_status'] as String?;
                                if (cycleStatus == 'success' || cycleStatus == 'processing' || cycleStatus == 'initiated') {
                                  paymentStatus = 'paid';
                                } else {
                                  paymentStatus = 'pending';
                                }
                              }
                              // If no record for this cycle yet → pending (need to pay)
                            } else {
                              // Fallback: use overall payment_status only if no cycle history
                              final status = currentUserMember['payment_status'] as String?;
                              if (status == 'success' || status == 'processing' || status == 'initiated') {
                                paymentStatus = 'paid';
                              }
                            }
                          }
                          
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                            child: Obx(
                              () => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Current Cycle Card — always show for started groups
                                  if (group != null && group.status == 'started')
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: CurrentCycleCard(
                                        cycleNumber: activeCycleNumber,
                                        totalCycles: group.targetMembers,
                                        dueDate: nextDrawDate != null 
                                          ? DateTime.tryParse(nextDrawDate) 
                                          : null,
                                        drawingDate: nextDrawDate != null 
                                          ? DateTime.tryParse(nextDrawDate) 
                                          : null,
                                        amount: group.contributionAmount.toDouble(),
                                        status: paymentStatus,
                                        winnerInfo: null, // Will be populated after drawing
                                        onPayNow: paymentStatus == 'pending'
                                          ? () {
                                              // Show payment method selection
                                              showModalBottomSheet(
                                                context: Get.context!,
                                                builder: (context) => SelectPaymentMethodView(
                                                  ekubId: group!.id,
                                                  amount: group.contributionAmount.toDouble(),
                                                  cycleNumber: activeCycleNumber,
                                                ),
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      ),
                                    ),
                                  
                                  // Payment Methods Section
                                  Text(
                                    'payment_methods'.tr,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Chapa
                                  PaymentMethodCard(
                                    id: 'chapa',
                                    name: 'Chapa',
                                    logo: const ChapaLogo(),
                                    description: paymentController.chapaDescription,
                                    isSelected: paymentController.selectedPaymentMethod.value == 'chapa',
                                    // onTap: () => paymentController.selectPaymentMethod('chapa'),
                                    // onProceed: () => paymentController.proceedToPayment(
                                    //   'chapa',
                                    //   group?.id,
                                    //   group?.contributionAmount.toDouble(),
                                    //   cycleNumber: activeCycleNumber,
                                    // ),
                                  ),
                                  // Arifpay
                                  PaymentMethodCard(
                                    id: 'arifpay',
                                    name: 'Arifpay',
                                    logo: const ArifpayLogo(),
                                    description: paymentController.arifpayDescription,
                                    isSelected: paymentController.selectedPaymentMethod.value == 'arifpay',
                                    // onTap: () => paymentController.selectPaymentMethod('arifpay'),
                                    // onProceed: () => paymentController.proceedToPayment(
                                    //   'arifpay',
                                    //   group?.id,
                                    //   group?.contributionAmount.toDouble(),
                                    //   cycleNumber: activeCycleNumber,
                                    // ),
                                  ),
                                  // SANTIM PAY
                                  PaymentMethodCard(
                                    id: 'santim_pay',
                                    name: 'santim_pay'.tr,
                                    logo: const SantimPayLogo(),
                                    description: paymentController.santimPayDescription,
                                    isSelected: paymentController.selectedPaymentMethod.value == 'santim_pay',
                                    // onTap: () => paymentController.selectPaymentMethod('santim_pay'),
                                    // onProceed: () => paymentController.proceedToPayment(
                                    //   'santim_pay',
                                    //   group?.id,
                                    //   group?.contributionAmount.toDouble(),
                                    //   cycleNumber: activeCycleNumber,
                                    // ),
                                  ),
                                  // Telebirr
                                  PaymentMethodCard(
                                    id: 'telebirr',
                                    name: 'Telebirr',
                                    logo: const TelebirrLogo(),
                                    description: paymentController.telebirrDescription,
                                    isSelected: paymentController.selectedPaymentMethod.value == 'telebirr',
                                    // onTap: () => paymentController.selectPaymentMethod('telebirr'),
                                    // onProceed: () => paymentController.proceedToPayment(
                                    //   'telebirr',
                                    //   group?.id,
                                    //   group?.contributionAmount.toDouble(),
                                    //   cycleNumber: activeCycleNumber,
                                    // ),
                                  ),
                               
                                ],
                              ),
                            ),
                          );
                        case 2: // History Tab
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Payment History',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Obx(() {
                                if (!Get.isRegistered<
                                  GroupDetailController
                                >()) {
                                  return const SizedBox.shrink();
                                }
                                final controller =
                                    Get.find<GroupDetailController>();

                                if (controller.isHistoryLoading.value &&
                                    controller.history.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                // Filter history to show only current user's payments
                                final currentUserId = Get.find<AuthService>().currentUser.value?.id;
                                
                                // Get payments from the payments list (which contains user payment data)
                                final userPayments = controller.payments.where((payment) {
                                  // Check if this payment belongs to the current user
                                  final memberId = payment['user_id'] as String?;
                                  return memberId == currentUserId;
                                }).toList();

                                if (userPayments.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No payment history found'),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: userPayments.length,
                                  itemBuilder: (context, index) {
                                    final payment = userPayments[index];
                                    final statusColor =
                                        payment['status'].toLowerCase() == 'success'
                                        ? Colors.green
                                        : payment['status'].toLowerCase() == 'failed'
                                        ? Colors.red
                                        : Colors.orange;

                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              payment['status'].toLowerCase() == 'success'
                                                  ? Icons.check_circle
                                                  : payment['status'].toLowerCase() == 'failed'
                                                  ? Icons.cancel
                                                  : Icons.pending,
                                              color: statusColor,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            'ETB ${payment['amount'] ?? group?.contributionAmount ?? 0}',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                payment['date'] ?? '',
                                                style: GoogleFonts.montserrat(fontSize: 12),
                                              ),
                                              if (payment['cycle_number'] != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Cycle: ${payment['cycle_number']}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    color: AppColors.textLightGray,
                                                  ),
                                                ),
                                              ],
                                              if (payment['payment_method'] != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Method: ${payment['payment_method']}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    color: AppColors.textLightGray,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: statusColor,
                                            ),
                                            child: Text(
                                              (payment['status'] ?? 'pending').toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(color: Colors.grey[200], indent: 72),
                                      ],
                                    );
                                  },
                                );
                              }),
                            ],
                          );
                        default:
                          return Text('unknown_tab'.tr);
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  // Widget _buildInfoRow(String label, String value) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         label,
  //         style: GoogleFonts.montserrat(
  //           fontSize: 14,
  //           color: AppColors.textLightGray,
  //         ),
  //       ),
  //       Text(
  //         value,
  //         style: GoogleFonts.montserrat(
  //           fontSize: 14,
  //           fontWeight: FontWeight.bold,
  //           color: AppColors.splashBackground,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTab(String label, int tabIndex) {
    return Obx(() {
      bool isSelected = false;
      if (Get.isRegistered<GroupDetailController>()) {
        final controller = Get.find<GroupDetailController>();
        isSelected = controller.activeTab.value == tabIndex;
      }

      return GestureDetector(
        onTap: () {
          if (Get.isRegistered<GroupDetailController>()) {
            final controller = Get.find<GroupDetailController>();
            controller.setActiveTab(tabIndex);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xffc6c92a) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textLightGray,
            ),
          ),
        ),
      );
    });
  }
}
