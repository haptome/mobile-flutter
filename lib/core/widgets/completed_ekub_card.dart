// Purpose: Completed Ekub card widget (expandable)
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'translated_text.dart';

class CompletedEkubCard extends StatefulWidget {
  final String id;
  final String name;
  final String amount;
  final int round;
  final String frequency;
  final String duration;
  final String totalAmount;
  final VoidCallback? onTap;

  const CompletedEkubCard({
    super.key,
    required this.id,
    required this.name,
    required this.amount,
    required this.round,
    required this.frequency,
    required this.duration,
    required this.totalAmount,
    this.onTap,
  });

  @override
  State<CompletedEkubCard> createState() => _CompletedEkubCardState();
}

class _CompletedEkubCardState extends State<CompletedEkubCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              widget.onTap?.call();
            },
            borderRadius: _isExpanded 
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Ekub Name
                  TranslatedText(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Round info in light green/yellow
                  Expanded(
                    child: Text(
                      '${widget.amount} ${'in_round'.tr} ${widget.round}.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary, // Light green/yellow
                      ),
                    ),
                  ),
                  // Chevron icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    color: AppColors.darkTextPrimary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Divider (only when expanded)
          if (_isExpanded)
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lightBorder.withOpacity(0.3),
              indent: 16,
              endIndent: 16,
            ),
          // Expanded content
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Paid Weekly
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.sync_outlined,
                      isTranslatable: true,
                      label: '${'paid'.tr} ${widget.frequency}',
                      iconColor: AppColors.lightTextPrimary, // Dark teal
                    ),
                  ),
                  // Duration
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.access_time_outlined,
                      label: widget.duration,
                      iconColor: AppColors.lightTextPrimary, // Dark teal
                    ),
                  ),
                  // Total Amount
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.attach_money_outlined,
                      label: widget.totalAmount,
                      iconColor: AppColors.lightTextPrimary, // Dark teal
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    bool isTranslatable = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Flexible(
          child: isTranslatable
              ? TranslatedText(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
