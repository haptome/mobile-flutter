// Purpose: Transaction card widget (expandable)
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

enum TransactionType {
  deposit,
  withdrawal,
  failed,
  rewards,
}

class TransactionCard extends StatefulWidget {
  final String id;
  final TransactionType type;
  final String amount;
  final String date;
  final String source;
  final String? ekubName;
  final String? transactionId;
  final String? rounds;
  final bool initiallyExpanded;

  const TransactionCard({
    super.key,
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.source,
    this.ekubName,
    this.transactionId,
    this.rounds,
    this.initiallyExpanded = false,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Color _getIconColor() {
    switch (widget.type) {
      case TransactionType.deposit:
        return const Color(0xFF4CAF50); // Green
      case TransactionType.withdrawal:
        return const Color(0xFFFFC107); // Yellow
      case TransactionType.failed:
        return const Color(0xFFF44336); // Red
      case TransactionType.rewards:
        return const Color(0xFF8BC34A); // Light green
    }
  }

  Widget _getIcon() {
    switch (widget.type) {
      case TransactionType.deposit:
        return const Icon(
          Icons.arrow_downward_outlined,
          color: Colors.white,
          size: 20,
        );
      case TransactionType.withdrawal:
        return const Icon(
          Icons.arrow_upward_outlined,
          color: Colors.white,
          size: 20,
        );
      case TransactionType.failed:
        return const Icon(
          Icons.close_outlined,
          color: Colors.white,
          size: 20,
        );
      case TransactionType.rewards:
        return Stack(
          alignment: Alignment.center,
          children: [
            // Square background
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Circle inside
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
    }
  }

  String _getTypeLabel() {
    switch (widget.type) {
      case TransactionType.deposit:
        return 'deposit'.tr;
      case TransactionType.withdrawal:
        return 'withdrawal'.tr;
      case TransactionType.failed:
        return 'failed'.tr;
      case TransactionType.rewards:
        return 'rewards'.tr;
    }
  }

  bool _isSquareIcon() {
    return widget.type == TransactionType.rewards;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();
    final isSquare = _isSquareIcon();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isSquare ? BorderRadius.circular(8) : null,
                    ),
                    child: Center(child: _getIcon()),
                  ),
                  const SizedBox(width: 12),
                  // Transaction info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.source,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.amount,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        color: AppColors.textLightGray,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded && (widget.ekubName != null || widget.transactionId != null || widget.rounds != null)) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (widget.ekubName != null) ...[
                    _buildDetailRow('equb_name_colon'.tr, widget.ekubName!),
                    const SizedBox(height: 12),
                  ],
                  _buildDetailRow('date_colon'.tr, widget.date),
                  if (widget.transactionId != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('transaction_id_colon'.tr, widget.transactionId!),
                  ],
                  if (widget.rounds != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('rounds_colon'.tr, widget.rounds!),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailRow('amount_colon'.tr, widget.amount),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}

