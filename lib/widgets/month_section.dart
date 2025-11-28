// Purpose: Expandable month section widget
// Author: haptome H.
// Linked Spec Section: Upcoming Payments Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'payment_item.dart';

class MonthSection extends StatefulWidget {
  final String month;
  final List<Map<String, dynamic>> payments;
  final Function(String paymentId)? onPaymentTap;

  const MonthSection({
    super.key,
    required this.month,
    required this.payments,
    this.onPaymentTap,
  });

  @override
  State<MonthSection> createState() => _MonthSectionState();
}

class _MonthSectionState extends State<MonthSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Text(
                  widget.month,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
        ),
        // Payments list
        if (_isExpanded)
          ...widget.payments.map((payment) => PaymentItem(
                payment: payment,
                onTap: () => widget.onPaymentTap?.call(
                  payment['id'] ?? '',
                ),
              )),
      ],
    );
  }
}
