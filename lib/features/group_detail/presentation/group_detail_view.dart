 // Purpose: Group Detail page - shows group details, members, join button
// Author: Auto-generated

import 'package:et_digital_equb/controllers/group_detail_controller.dart';
import 'package:et_digital_equb/controllers/payment_controller.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/current_cycle_card.dart';
import 'package:et_digital_equb/core/widgets/payment_logo.dart';
import 'package:et_digital_equb/core/widgets/payment_method_card.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:et_digital_equb/core/widgets/translated_text.dart';
import 'package:et_digital_equb/features/payment/presentation/select_payment_method_view.dart';
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
          body: Center(child: Text('group_not_found'.tr)),
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
        title: TranslatedText(
          group.name,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackground,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                              child: TranslatedText(
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

            // Start date & status banner
            _buildStartDateStatusBanner(group),

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
                      TranslatedText(
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
              final recentWinners = controller.history.toList();

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
                        final lotteryNumber = winnerMap['lottery_number']?.toString();
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
                                '${formatCurrencyShort(amount)} ${'etb'.tr}',
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
                              isReady: () {
                                final s = controller.groupHistoryData['next_draw_date'] as String?;
                                if (s == null) return false;
                                try {
                                  final t = DateTime.parse(s);
                                  final diff = t.difference(DateTime.now()).inMinutes;
                                  return diff >= 0 && diff <= 5;
                                } catch (_) {
                                  return false;
                                }
                              }(),
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
                          if (group == null) {
                            return '${'round'.tr} 1 ${'of'.tr} 0';
                          }

                          String roundText =
                              '${'round'.tr} 1 ${'of'.tr} ${group.targetMembers}';
                          if (controller.groupHistoryData.isNotEmpty &&
                              controller.groupHistoryData['current_round'] !=
                                  null) {
                            final currentRound =
                                controller.groupHistoryData['current_round']
                                    as int;
                            roundText =
                                '${'round'.tr} $currentRound ${'of'.tr} ${group.targetMembers}';
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
                          final roundsCompleted =
                              controller.groupHistoryData['current_round']
                                  as int? ??
                              0;
                          final roundsRemaining =
                              controller.groupHistoryData['rounds_remaining']
                                  as int? ??
                              0;
                          final totalRounds = roundsCompleted + roundsRemaining;
                          progressValue = totalRounds > 0
                              ? (roundsCompleted / totalRounds)
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

            // Tabs (Payments, History)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab('Payments', 0),
                  _buildTab('History', 1),
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
                        case 0: // Payments Tab
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
                                // Only 'success' means the payment was confirmed by the gateway.
                                // 'processing' / 'initiated' mean a session was opened but not
                                // yet confirmed — treat as pending so the user can still pay.
                                paymentStatus = cycleStatus == 'success' ? 'paid' : 'pending';
                              }
                              // If no record for this cycle yet → pending (need to pay)
                            } else {
                              // Fallback: use overall payment_status only if no cycle history
                              final status = currentUserMember['payment_status'] as String?;
                              if (status == 'success') {
                                paymentStatus = 'paid';
                              }
                            }
                          }
                          
                          // Drawing deadline for the active cycle — always means
                          // "pay before this date to be eligible for the draw".
                          // • started groups: use the exact date from DrawingSchedule.
                          // • active (pre-start) groups: no DrawingSchedule yet, so
                          //   estimate from start_date + cycle duration
                          //   (monthly → 30 d, weekly/daily → 7 d).
                          final drawDeadline = nextDrawDate != null
                              ? DateTime.tryParse(nextDrawDate)
                              : (group?.status == 'active' && group?.startDate != null
                                  ? group!.startDate!.add(
                                      group.frequency == 'monthly'
                                          ? const Duration(days: 30)
                                          : const Duration(days: 7),
                                    )
                                  : null);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                            child: Obx(
                              () => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Show the cycle card for:
                                  //  • 'active'  — group approved, waiting for start_date.
                                  //                Members can pre-pay cycle 1 so they are
                                  //                eligible the moment the first drawing fires.
                                  //  • 'started' — group running, normal mid-cycle payment.
                                  if (group != null && (group.status == 'started' || group.status == 'active'))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: CurrentCycleCard(
                                        cycleNumber: activeCycleNumber,
                                        totalCycles: group.targetMembers,
                                        dueDate: drawDeadline,
                                        drawingDate: drawDeadline,
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
                                  
                                  // AddisPay
                                  PaymentMethodCard(
                                    id: 'addispay',
                                    name: 'AddisPay',
                                    logo: const AddisPayLogo(),
                                    description: paymentController.addisPayDescription,
                                    isSelected: paymentController.selectedPaymentMethod.value == 'addispay',
                                    // onTap: () => paymentController.selectPaymentMethod('addispay'),
                                    // onProceed: () => paymentController.proceedToPayment(
                                    //   'addispay',
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
                        case 1: // History Tab
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
                                  return Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('no_payment_history_found'.tr),
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
                                            '${'etb'.tr} ${payment['amount'] ?? group?.contributionAmount ?? 0}',
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
    ), // closes RefreshIndicator
  );
}

  Widget _buildStartDateStatusBanner(Group group) {
    final isStarted = group.status == 'started';
    final isActive = group.status == 'active';

    if (!isStarted && !isActive) return const SizedBox.shrink();

    final statusColor = isStarted ? Colors.green : Colors.teal;
    final statusIcon = isStarted ? Icons.play_circle_fill : Icons.lock_open;
    final statusLabel = isStarted ? 'Ekub Started' : 'Open to Join';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
                if (group.startDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Starts: ${_formatDateTime(group.startDate!)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textLightGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (group.startDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(group.startDate!),
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year}  $hour:$minute $period';
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
