// Purpose: Invitation acceptance screen
// Author: Generated for ET Digital Equb
// Handles group invitations received via deep links

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../controllers/invitation_controller.dart';

class InvitationView extends StatefulWidget {
  const InvitationView({super.key});

  @override
  State<InvitationView> createState() => _InvitationViewState();
}

class _InvitationViewState extends State<InvitationView> {
  late final InvitationController _controller;

  @override
  void initState() {
    super.initState();

    // Get arguments passed from deep link
    final args = Get.arguments as Map<String, dynamic>?;
    final groupId = args?['groupId'] as String?;
    final inviteCode = args?['inviteCode'] as String?;

    // Initialize controller with invitation data
    _controller = Get.put(
      InvitationController(groupId: groupId, inviteCode: inviteCode),
    );

    // Load invitation details
    if (groupId != null && inviteCode != null) {
      _controller.loadInvitationDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'group_invitation'.tr,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.lightError,
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  _controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: AppColors.lightError,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingLarge),
                AppButton(
                  text: 'go_back'.tr,
                  onPressed: () => Get.back(),
                  width: 150,
                ),
              ],
            ),
          );
        }

        final groupData = _controller.groupData;
        if (groupData.isEmpty) {
          return Center(child: Text('no_invitation_data'.tr));
        }

        final group = groupData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.groups,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group['name'] ?? 'group_name'.tr,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSizes.spacingXSmall),
                              Text(
                                '${group['memberCount'] ?? 0} members',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
                    if (group['description'] != null)
                      Text(
                        group['description'],
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spacingLarge),

              // Invitation details
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'invitation_details'.tr,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
                    _buildDetailRow('Amount', '${group['amount']} ETB'),
                    _buildDetailRow(
                      'Frequency',
                      group['frequency'] ?? 'Monthly',
                    ),
                    _buildDetailRow('duration'.tr, '${group['rounds']} ' + 'rounds'.tr),
                    if (group['startDate'] != null)
                      _buildDetailRow('start_date'.tr, group['startDate']),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spacingLarge),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Decline',
                      onPressed: _controller.declineInvitation,
                      type: ButtonType.outlined,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: AppButton(
                      text: 'Accept',
                      onPressed: _controller.acceptInvitation,
                      isLoading: _controller.isProcessing.value,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
