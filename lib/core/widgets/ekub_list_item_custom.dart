import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'translated_text.dart';

import '../../models/group_model.dart';
import '../../controllers/language_controller.dart';
import '../../core/utils/ethiopian_date.dart';

/// Custom ekub list item widget matching the specified design
class EkubListItemCustom extends StatelessWidget {
  final String title;
  final String amountLabel;
  final String frequency;
  final int currentMembers;
  final int targetMembers;
  final double totalPoolAmount;
  final DateTime? startDate;
  final String status;
  final VoidCallback? onTap;
  final String? groupId;

  /// Optional override for the action button label. When null, the label is
  /// derived from [status] via [_getButtonText] (e.g. "View Details").
  final String? actionLabel;

  const EkubListItemCustom({
    super.key,
    required this.title,
    required this.amountLabel,
    required this.frequency,
    this.currentMembers = 0,
    this.targetMembers = 0,
    this.totalPoolAmount = 0.0,
    this.startDate,
    this.status = 'active',
    this.onTap,
    this.groupId,
    this.actionLabel,
  });

  /// Compatibility constructor to build from a `Group` model
  factory EkubListItemCustom.fromGroup(
    Group group, {
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    // Total pool = full pool size when the group completes: contribution × target members
    final totalPool = group.contributionAmount * group.targetMembers;

    return EkubListItemCustom(
      title: group.name,
      amountLabel: '${group.contributionAmount.toStringAsFixed(0)} ${'etb'.tr}',
      frequency: _prettyFrequency(group.frequency),
      currentMembers: group.currentMembers,
      targetMembers: group.targetMembers,
      totalPoolAmount: totalPool,
      startDate: group.startDate,
      status: group.status,
      onTap: onTap,
      groupId: group.id,
      actionLabel: actionLabel,
    );
  }

  /// Builds the card from either a [Group] (cash) or an [InKindGroup].
  /// In-kind groups have no `currentMembers`, so the members line falls back
  /// to 0 (same behaviour as the Your Ekubs screen); Total Pool still uses
  /// contribution × target members.
  factory EkubListItemCustom.fromAnyGroup(
    dynamic group, {
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    if (group is Group) {
      return EkubListItemCustom.fromGroup(
        group,
        onTap: onTap,
        actionLabel: actionLabel,
      );
    }
    final g = group as InKindGroup;
    return EkubListItemCustom(
      title: g.name,
      amountLabel: '${g.contributionAmount.toStringAsFixed(0)} ${'etb'.tr}',
      frequency: _prettyFrequency(g.frequency),
      currentMembers: 0,
      targetMembers: g.targetMembers,
      totalPoolAmount: g.contributionAmount * g.targetMembers,
      startDate: g.startDate,
      status: g.status,
      onTap: onTap,
      groupId: g.id,
      actionLabel: actionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format start date
    final startDateStr = startDate != null
        ? _formatDate(startDate!)
        : 'N/A';

    // Action label: explicit override (e.g. "Join") or status-derived default.
    final buttonText = actionLabel ?? _getButtonText(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 16,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title/Amount header
            TranslatedText(
              '$frequency | $amountLabel',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.splashBackground,
              ),
            ),
            const SizedBox(height: 16),
            // Details section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Members count
                _buildDetailLine(
                  'members'.tr,
                  '$targetMembers',
                ),
                const SizedBox(height: 8),
                // Total pool amount
                _buildDetailLine(
                  'total_pool'.tr,
                  '${totalPoolAmount.toStringAsFixed(0)} ${'etb'.tr}',
                ),
                const SizedBox(height: 8),
                // Start date
                _buildDetailLine(
                  'start_date'.tr,
                  startDateStr,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: TranslatedText(
                  buttonText,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a detail line with label and value
  Widget _buildDetailLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        TranslatedText(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.splashBackground,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    if (LanguageController.to.isAmharic()) {
      return formatStartDate(date, amharic: true);
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName';
  }

  /// Get button text based on group status
  static String _getButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'view_details'.tr;
      case 'pending':
        return 'pending_action'.tr;
      case 'completed':
        return 'completed_status'.tr;
      case 'suspended':
        return 'suspended_status'.tr;
      default:
        return 'view_details'.tr;
    }
  }

  static String _prettyFrequency(String f) {
    if (f.isEmpty) return f;
    return f[0].toUpperCase() + f.substring(1);
  }
}
