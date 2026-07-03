// Purpose: Group Invite screen — shown when user taps an invite deep link
// Fetches group info and lets the user join with one tap.
// For cash ekub groups the full Amharic membership contract is presented with
// dynamic fields filled before the join is finalised.

import 'package:et_digital_equb/controllers/group_detail_controller.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/equb_membership_agreement.dart';
import 'package:et_digital_equb/core/widgets/translated_text.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupInviteView extends StatefulWidget {
  const GroupInviteView({super.key});

  @override
  State<GroupInviteView> createState() => _GroupInviteViewState();
}

class _GroupInviteViewState extends State<GroupInviteView> {
  Group? _group;
  bool _loading = true;
  bool _joining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    final args = Get.arguments as Map<String, dynamic>?;
    final groupId = args?['groupId'] as String?;

    if (groupId == null) {
      setState(() {
        _error = 'Invalid invite link.';
        _loading = false;
      });
      return;
    }

    final response = await GroupService.to.getGroupById(groupId);
    if (mounted) {
      setState(() {
        _group = response.data;
        _error = response.success ? null : (response.message ?? 'Group not found.');
        _loading = false;
      });
    }
  }

  // ─── T&C helpers ─────────────────────────────────────────────────────────

  /// Build the full Amharic membership agreement with all dynamic fields filled.
  String _buildCashEqubTc(Group group) {
    return buildCashEqubTc(
      groupName: group.name,
      contributionAmount: group.contributionAmount,
      targetMembers: group.targetMembers,
      frequency: group.frequency,
      serviceChargePercent: group.serviceChargePercent,
      startDate: group.startDate,
    );
  }

  // ─── Join flow ────────────────────────────────────────────────────────────

  /// Show the Amharic T&C bottom sheet; returns true only if user explicitly accepts.
  Future<bool> _showCashEqubTermsSheet(Group group) {
    return showEqubMembershipAgreement(context, _buildCashEqubTc(group));
  }

  Future<void> _joinGroup() async {
    if (_group == null) return;

    // Show the Amharic membership contract first; block join until accepted.
    final accepted = await _showCashEqubTermsSheet(_group!);
    if (!accepted) return;

    setState(() => _joining = true);

    final response = await GroupService.to.joinGroup(_group!.id, acceptTerms: true);

    if (!mounted) return;
    setState(() => _joining = false);

    if (response.success) {
      Get.snackbar(
        'Joined',
        response.message ?? 'You have joined ${_group!.name}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate to group detail
      if (Get.isRegistered<GroupDetailController>()) {
        Get.delete<GroupDetailController>();
      }
      Get.put(GroupDetailController(group: _group!));
      Get.offAllNamed(AppRoutes.groupDetail, arguments: _group);
    } else {
      Get.snackbar(
        'Error',
        response.message ?? 'Failed to join group.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Group Invitation',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackground,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final group = _group!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_add,
                  size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'ve been invited to join',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TranslatedText(
            group.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackground,
            ),
          ),
          const SizedBox(height: 32),
          // Group details card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.payments_outlined, 'Contribution',
                      '${group.contributionAmount.toInt()} ${'etb'.tr}'),
                  const Divider(height: 20),
                  _infoRow(
                      Icons.schedule,
                      'Frequency',
                      TranslatedText(
                        '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  const Divider(height: 20),
                  _infoRow(Icons.people, 'Members',
                      '${group.currentMembers} / ${group.targetMembers}'),
                  const Divider(height: 20),
                  _infoRow(
                      Icons.info_outline,
                      'Status',
                      TranslatedText(
                        '${group.status[0].toUpperCase()}${group.status.substring(1)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // T&C hint
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'You will be asked to read and accept the Amharic membership '
                  'agreement before joining.',
                  style: GoogleFonts.montserrat(
                      fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Group Rules Card - Parse and display T&C content
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'Group Rules',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.splashBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Display first few rules from T&C
                  TranslatedText(
                    '1. Contribution Amount: ${'etb'.tr} ${group.contributionAmount.toInt()}'
                    '\n   - Each member must contribute ${'etb'.tr} ${group.contributionAmount.toInt()} ${group.frequency}.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TranslatedText(
                    '2. Contribution Frequency: ${group.frequency[0].toUpperCase()}${group.frequency.substring(1)}'
                    '\n   - Contributions are due every ${group.frequency}.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3. Service Charge: ${group.serviceChargePercent}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '4. Total Members: ${group.targetMembers}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _joining ? null : _joinGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _joining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Join Group',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Maybe later',
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label,
            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        if (value is String)
          Text(
            value,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 14),
          )
        else if (value is Widget)
          value,
      ],
    );
  }
}

// (Terms sheet is now in equb_membership_agreement.dart)
