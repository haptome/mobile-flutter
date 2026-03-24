// Purpose: Group Invite screen — shown when user taps an invite deep link
// Fetches group info and lets the user join with one tap.

import 'package:et_digital_equb/controllers/group_detail_controller.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
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

  Future<void> _joinGroup() async {
    if (_group == null) return;
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
                          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
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
              child: const Icon(Icons.group_add, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'ve been invited to join',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.payments_outlined, 'Contribution',
                      '${group.contributionAmount} ETB'),
                  const Divider(height: 20),
                  _infoRow(Icons.schedule, 'Frequency',
                      '${group.frequency[0].toUpperCase()}${group.frequency.substring(1)}'),
                  const Divider(height: 20),
                  _infoRow(Icons.people, 'Members',
                      '${group.currentMembers} / ${group.targetMembers}'),
                  const Divider(height: 20),
                  _infoRow(Icons.info_outline, 'Status',
                      '${group.status[0].toUpperCase()}${group.status.substring(1)}'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _joining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
