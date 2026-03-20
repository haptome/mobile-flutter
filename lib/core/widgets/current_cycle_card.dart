// Purpose: Current Cycle Card widget - displays prominent cycle information
// Author: Auto-generated

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CurrentCycleCard extends StatelessWidget {
  final int cycleNumber;
  final int totalCycles;
  final DateTime? dueDate;
  final DateTime? drawingDate;
  final double amount;
  final String status; // 'pending', 'paid', 'overdue'
  final String? winnerInfo;
  final VoidCallback? onPayNow;

  const CurrentCycleCard({
    super.key,
    required this.cycleNumber,
    required this.totalCycles,
    this.dueDate,
    this.drawingDate,
    required this.amount,
    required this.status,
    this.winnerInfo,
    this.onPayNow,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.warning;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      color: AppColors.lightBackground,
      shadowColor: AppColors.black.withOpacity(0.4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'current_cycle'.tr,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackground,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'payment_$status'.tr,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cycle Number
            Text(
              'cycle_x_of_y'.trParams({'x': cycleNumber.toString(), 'y': totalCycles.toString()}),
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.splashBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Info Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.payments,
                    label: 'amount'.tr,
                    value: '${amount.toStringAsFixed(0)} ETB',
                  ),
                ),
                if (dueDate != null)
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.event,
                      label: 'due_date'.tr,
                      value: _formatDate(dueDate!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                if (drawingDate != null)
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.casino,
                      label: 'drawing_date'.tr,
                      value: _formatDate(drawingDate!),
                    ),
                  ),
                if (winnerInfo != null)
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.emoji_events,
                      label: 'cycle_winner'.tr,
                      value: winnerInfo!,
                    ),
                  ),
              ],
            ),

            // Pay Now Button
            if (status.toLowerCase() == 'pending' && onPayNow != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'pay_now'.tr,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Overdue Warning
            if (status.toLowerCase() == 'overdue') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'payment_overdue_warning'.tr,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textLightGray),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppColors.textLightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.splashBackground,
          ),
        ),
      ],
    );
  }
}
