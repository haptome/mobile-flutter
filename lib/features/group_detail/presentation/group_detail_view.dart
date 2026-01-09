// Purpose: Group Detail page - shows group details, members, join button
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/group_model.dart';
import '../../../../models/member_model.dart';
import '../../../../controllers/group_detail_controller.dart';

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
        return Scaffold(
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
    final String? imageUrl = group is InKindGroup
        ? (group as InKindGroup).imageUrl
        : null;

    return Scaffold(
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
              height: 160,
              child: Center(
                child: Card(
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
                              '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)} ${group.contributionAmount.toStringAsFixed(0)} Birr',
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
                                  '${(group.targetMembers / (group.frequency == 'weekly' ? 4 : 1)).toStringAsFixed(0)} Months',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textLightGray,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(group.contributionAmount * group.targetMembers).toStringAsFixed(0)} ETB',
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

            const SizedBox(height: 96),

            // Progress Card
            Card(
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
                    Text(
                      'Round ${1} of ${group.targetMembers}',
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
                            value:
                                (group.currentMembers /
                                    (group.targetMembers == 0
                                        ? 1
                                        : group.targetMembers)) *
                                0.1,
                            minHeight: 8,
                            backgroundColor: Colors.purple.shade50,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${group.currentMembers}%',
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
                              '${group.currentMembers}',
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
                              '${(group.targetMembers - group.currentMembers).clamp(0, group.targetMembers)}',
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
                              '${(group.contributionAmount * group.targetMembers).toStringAsFixed(0)}',
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
                              '${group.startDate != null ? '${group.startDate!.month}/${group.startDate!.day}' : 'Dec 15'}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
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

            // Tabs (Members, Lottery, Payments, History)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTab('Members', true),
                  _buildTab('Lottery', false),
                  _buildTab('Payments', false),
                  _buildTab('History', false),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Members Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Members - ${group.currentMembers}',
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
                              backgroundColor: const Color(0xffc6c92a),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
                    const Divider(),
                    // Members list
                    Obx(() {
                      if (group == null) {
                        return const SizedBox.shrink();
                      }

                      final showAll = controller.showAllMembers.value;
                      final allMembers = controller.members;
                      final displayCount = showAll
                          ? allMembers.length
                          : (allMembers.length > 5 ? 5 : allMembers.length);

                      return Column(
                        children: [
                          if (controller.isMembersLoading.value &&
                              allMembers.isEmpty) ...[
                            const Center(child: CircularProgressIndicator()),
                          ] else ...[
                            ...List.generate(displayCount, (i) {
                              final member = allMembers[i];
                              final statusColor =
                                  member.status.toLowerCase() == 'active'
                                  ? Colors.green
                                  : member.status.toLowerCase() == 'pending'
                                  ? Colors.orange
                                  : Colors.red;
                              final statusText =
                                  member.status.toLowerCase() == 'active'
                                  ? 'Active'
                                  : member.status.toLowerCase() == 'pending'
                                  ? 'Pending'
                                  : 'Removed';

                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade200,
                                      child:
                                          member.user.profilePicUrl != null &&
                                              member
                                                  .user
                                                  .profilePicUrl!
                                                  .isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                member.user.profilePicUrl!,
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
                                        color: AppColors.textLightGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                  const Divider(indent: 72),
                                ],
                              );
                            }),
                          ],
                          if (allMembers.length > 5) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: controller.toggleShowAllMembers,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppColors.textLightGray,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffc6c92a) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textLightGray,
        ),
      ),
    );
  }
}
