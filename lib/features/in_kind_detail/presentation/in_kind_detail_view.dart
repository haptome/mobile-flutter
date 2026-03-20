// Purpose: In-Kind Group Detail page - shows in-kind group details, members, join button
// Author: Auto-generated

import 'package:et_digital_equb/core/extensions/number_formatting.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/group_model.dart';
import '../../../../controllers/in_kind_detail_controller.dart';

// Helper functions
String _formatCurrencyShort(num value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

String _formatDate(DateTime date) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}';
}

class InKindDetailView extends StatelessWidget {
  const InKindDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InKindDetailController>();
    final InKindGroup group = controller.group;

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
            // Hero Card - Compact like group detail
            Card(
              color: AppColors.lightBackground,
              shadowColor: AppColors.black.withOpacity(0.4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            group.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.splashBackground,
                            ).copyWith(overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 15,
                          color: AppColors.borderLightGray,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)} ${group.contributionAmount.toCurrencyShort()}',
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
                          '${_formatCurrencyShort(group.contributionAmount * group.targetMembers)}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: AppColors.splashBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Progress Card - Match group detail styling
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
                    Text(
                      'ekub_progress'.tr,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final currentRound = group.currentMembers;
                        final progressValue = (group.targetMembers) > 0
                            ? (group.currentMembers / (group.targetMembers))
                                .toDouble()
                            : 0.0;
                        final roundsCompleted = group.currentMembers;
                        final roundsRemaining =
                            ((group.targetMembers - group.currentMembers))
                                .clamp(0, group.targetMembers);

                        return Column(
                          children: [
                            Text(
                              'Round $currentRound of ${group.targetMembers}',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textLightGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
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
                                    SizedBox(
                                      width: 70,
                                      height: 30,
                                      child: Text(
                                        '$roundsCompleted',
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
                                    SizedBox(
                                      width: 70,
                                      height: 30,
                                      child: Text(
                                        '$roundsRemaining',
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
                                        '${_formatCurrencyShort(group.contributionAmount * group.targetMembers)}',
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
                                      child: Text(
                                        '${group.startDate != null ? _formatDate(group.startDate!) : 'Dec 15'}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
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
                  _buildTab(controller, 'members'.tr, 0),
                  _buildTab(controller, 'payments'.tr, 1),
                  _buildTab(controller, 'History'.tr, 2),
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
                                    'total_members'.tr + ' - ${group.currentMembers} (' + 'of'.tr + ' ${group.targetMembers})',
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
                                      child: Text(
                                        'invite'.tr,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey[200]),
                              // Members list
                              Obx(() {
                                final showAll = controller.showAllMembers.value;
                                final allMembers = controller.members;
                                final displayCount = showAll
                                    ? allMembers.length
                                    : (allMembers.length > 5
                                          ? 5
                                          : allMembers.length);

                                return Column(
                                  children: [
                                    if (controller.isMembersLoading.value &&
                                        allMembers.isEmpty) ...[
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ] else ...[
                                      ...List.generate(displayCount, (i) {
                                        final member = allMembers[i];
                                        final statusColor =
                                            member.status.toLowerCase() ==
                                                'active'
                                            ? Colors.green
                                            : member.status.toLowerCase() ==
                                                  'pending'
                                            ? Colors.orange
                                            : Colors.red;
                                        final statusText =
                                            member.status.toLowerCase() ==
                                                'active'
                                            ? 'active'.tr
                                            : member.status.toLowerCase() ==
                                                  'pending'
                                            ? 'pending'.tr
                                            : 'removed'.tr;

                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                child:
                                                    member.user.profilePicUrl !=
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
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        color: Colors.black54,
                                                      ),
                                              ),
                                              title: Text(
                                                member.user.fullName,
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                member.user.phone,
                                                style: GoogleFonts.montserrat(
                                                  color:
                                                      AppColors.textLightGray,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              trailing: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: statusColor,
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: const TextStyle(
                                                    color: Colors.white,
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
                                    if (allMembers.length > 5) ...[
                                      const SizedBox(height: 8),
                                      Center(
                                        child: TextButton(
                                          onPressed:
                                              controller.toggleShowAllMembers,
                                          child: Text(
                                            controller.showAllMembers.value
                                                ? 'view_less'.tr
                                                : 'view_more'.tr,
                                            style: GoogleFonts.montserrat(
                                              color: const Color(0xffc6c92a),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          );
                        case 1: // Payments Tab
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'group_payments'.tr,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Obx(() {
                                if (controller.isPaymentsLoading.value &&
                                    controller.payments.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (controller.payments.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('no_payments_found'.tr),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.payments.length,
                                  itemBuilder: (context, index) {
                                    final payment = controller.payments[index];
                                    final statusColor =
                                        payment['status'].toLowerCase() ==
                                                'success' ||
                                            payment['status'].toLowerCase() ==
                                                'paid'
                                        ? Colors.green
                                        : payment['status'].toLowerCase() ==
                                              'failed'
                                        ? Colors.red
                                        : Colors.orange;

                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'ETB ${payment['amount']} - ${payment['member']}',
                                          ),
                                          subtitle: Text(
                                            '${payment['date']} | ${payment['status']}',
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
                                              payment['status'].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey[200],
                                          indent: 16,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                            ],
                          );
                        case 2: // History Tab
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'history'.tr,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Obx(() {
                                if (controller.isHistoryLoading.value &&
                                    controller.history.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (controller.history.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('no_history_found'.tr),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.history.length,
                                  itemBuilder: (context, index) {
                                    final event = controller.history[index];

                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.history,
                                            color: Color(0xffc6c92a),
                                          ),
                                          title: Text(event['action']),
                                          subtitle: Text(
                                            '${event['date']} - ${event['initiator']}',
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey[200],
                                          indent: 72,
                                        ),
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

  Widget _buildTab(
    InKindDetailController controller,
    String label,
    int tabIndex,
  ) {
    return Obx(() {
      bool isSelected = controller.activeTab.value == tabIndex;

      return GestureDetector(
        onTap: () {
          controller.setActiveTab(tabIndex);
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
