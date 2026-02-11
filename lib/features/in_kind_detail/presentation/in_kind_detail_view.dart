// Purpose: In-Kind Group Detail page - shows in-kind group details, members, join button
// Author: Auto-generated

import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/group_model.dart';
import '../../../../controllers/in_kind_detail_controller.dart';

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
            // Hero image area
            SizedBox(
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (group.imageUrl != null &&
                            group.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                group.imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          ),
                        if (group.description != null &&
                            group.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              group.description!,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppColors.textLightGray,
                              ),
                            ),
                          ),
                        // Show inventory item details for in-kind groups
                        if (group.inventoryItemName != null &&
                            group.inventoryItemName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                if (group.inventoryItemImageUrl != null &&
                                    group.inventoryItemImageUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        group.inventoryItemImageUrl!,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.error,
                                                size: 40,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    group.inventoryItemName!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.splashBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.splashBackground,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 1,
                              height: 15,
                              color: AppColors.borderLightGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)} Group',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppColors.textLightGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                                  'Duration: ${(group.targetMembers / (group.frequency == 'weekly' ? 4 : 1))} months',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textLightGray,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Pool: ETB ${((group.contributionAmount * group.targetMembers).toStringAsFixed(0))}',
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
              ),
            ),

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equb Progress',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress section - no Obx needed since group data is static
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
                                    Text(
                                      'Rounds Completed',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textLightGray,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$roundsCompleted',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rounds Remaining',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textLightGray,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$roundsRemaining',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Pool',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textLightGray,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${((group.contributionAmount * group.targetMembers).toStringAsFixed(0))}',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Draw',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textLightGray,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${group.startDate != null ? '${group.startDate!.month}/${group.startDate!.day}' : 'Soon'}',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
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
                  _buildTab(controller, 'Members', 0),
                  _buildTab(controller, 'Payments', 1),
                  _buildTab(controller, 'History', 2),
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
                                    'Total Members - ${group.currentMembers} (Of ${group.targetMembers})',
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
                                            ? 'Active'
                                            : member.status.toLowerCase() ==
                                                  'pending'
                                            ? 'Pending'
                                            : 'Removed';

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
                                                ? 'View Less'
                                                : 'View More',
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
                                'Group Payments',
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
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No payments found'),
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
                                'Group History',
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
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No history found'),
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
                          return const Text('Unknown tab');
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
