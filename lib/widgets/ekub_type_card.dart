// Purpose: Ekub Type card widget (expandable)
// Author: haptome H.
// Linked Spec Section: Ekub Type Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class EkubTypeCard extends StatefulWidget {
  final String id;
  final String name;
  final String frequency;
  final String amount;
  final String duration;
  final int memberCount;
  final List<String>? memberAvatars;
  final VoidCallback? onJoin;
  final bool initiallyExpanded;

  const EkubTypeCard({
    super.key,
    required this.id,
    required this.name,
    required this.frequency,
    required this.amount,
    required this.duration,
    required this.memberCount,
    this.memberAvatars,
    this.onJoin,
    this.initiallyExpanded = false,
  });

  @override
  State<EkubTypeCard> createState() => _EkubTypeCardState();
}

class _EkubTypeCardState extends State<EkubTypeCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

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
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Title and frequency
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary, // Dark teal/green
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '| ${widget.frequency}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLightGray,
                          ),
                        ),
                      ],
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
              child: Column(
                children: [
                  // Details row - three items horizontally
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Paid Weekly
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.sync_outlined,
                          label: '${'paid'.tr} ${widget.frequency}',
                        ),
                      ),
                      // Duration
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.access_time_outlined,
                          label: widget.duration,
                        ),
                      ),
                      // Amount
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.attach_money_outlined,
                          label: widget.amount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Footer row - Members and Join button
                  Row(
                    children: [
                      // Member avatars
                      ...List.generate(
                        (widget.memberAvatars?.length ?? 0).clamp(0, 4),
                        (index) => Container(
                          margin: const EdgeInsets.only(right: -8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundWhite,
                              width: 2,
                            ),
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          child: widget.memberAvatars != null &&
                                  index < widget.memberAvatars!.length
                              ? ClipOval(
                                  child: Image.network(
                                    widget.memberAvatars![index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Member count text
                      Text(
                        '+${widget.memberCount} ${'members'.tr}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      // Join button
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary, // Olive-green
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onJoin,
                            borderRadius: BorderRadius.circular(18),
                            child: Center(
                              child: Text(
                                'join'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.secondary, // Dark teal/green for icons
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
