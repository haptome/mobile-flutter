// Purpose: Group Detail page - shows group details, members, join button
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../models/group_model.dart';
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
              icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(
            child: Text('Group not found'),
          ),
        );
      }
      Get.put(GroupDetailController(group: group));
    }
    
    final controller = Get.find<GroupDetailController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
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
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: group.type == 'public'
                    ? Colors.green
                    : group.type == 'private'
                        ? Colors.orange
                        : Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                group.type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            
            // Contribution Amount
            _buildInfoRow(
              'Contribution Amount',
              '${group.contributionAmount.toStringAsFixed(0)} ETB',
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            
            // Frequency
            _buildInfoRow(
              'Frequency',
              group.frequency.toUpperCase(),
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            
            // Members
            _buildInfoRow(
              'Members',
              '${group.currentMembers} / ${group.targetMembers}',
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            
            // Rotation Method
            _buildInfoRow(
              'Rotation Method',
              group.rotationMethod.toUpperCase(),
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            
            // Service Charge
            _buildInfoRow(
              'Service Charge',
              '${group.serviceChargePercent.toStringAsFixed(2)}%',
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            
            // Status
            _buildInfoRow(
              'Status',
              group.status.toUpperCase(),
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            
            // Join Button (only for public groups)
            if (group.type == 'public' && group.status == 'active')
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isJoining.value
                      ? null
                      : () => controller.joinGroup(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  child: controller.isJoining.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Join Group',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),
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
}

