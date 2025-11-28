// Purpose: Completed Ekub card widget (expandable)
// Author: haptome H.
// Linked Spec Section: Completed Ekubs Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

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
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              widget.onTap?.call();
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Ekub Name
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Round info in light green/yellow
                  Expanded(
                    child: Text(
                      '${widget.amount} ${'in_round'.tr} ${widget.round}.',
                      style: const TextStyle(
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
                    color: AppColors.textDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Divider
          if (_isExpanded)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderLightGray,
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
                      label: '${'paid'.tr} ${widget.frequency}',
                      iconColor: AppColors.secondary, // Dark teal
                    ),
                  ),
                  // Duration
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.access_time_outlined,
                      label: widget.duration,
                      iconColor: AppColors.secondary, // Dark teal
                    ),
                  ),
                  // Total Amount
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.attach_money_outlined,
                      label: widget.totalAmount,
                      iconColor: AppColors.secondary, // Dark teal
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
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
